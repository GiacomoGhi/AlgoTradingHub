#include <Trade/AccountInfo.mqh>
#include <Trade/SymbolInfo.mqh>

#include "../../../Libraries/List/BasicList.mqh";
#include "../../Shared/Helpers/MathHelper.mqh";
#include "../../Shared/Logger/Logger.mqh";
#include "../../Shared/Models/ContextParams.mqh";
#include "./Models/PeriodDrawdownItem.mqh";
#include "./Models/RiskManagerParams.mqh";
#include "./Models/SizeCalculationTypeEnum.mqh";

class RiskManager
{
public:
    /**
     * Flags to check after object init. Is false in case of invalid input params.
     */
    const bool IsInitCompleted;

private:
    /**
     * Logger.
     */
    Logger *_logger;

    /**
     * Context params.
     */
    ContextParams *_contextParams;

    /**
     * Risk manager params.
     */
    RiskManagerParams *_params;

    /**
     * Symbol info utility object.
     */
    CSymbolInfo _symbolInfo;

    /**
     * Account info utility object.
     */
    CAccountInfo _accountInfo;

    /**
     * List of max allowed darwdown (value) during the selected period (time frame)
     */
    ObjectList<PeriodDrawdownItem> *_periodAllowedDrawdownStore;

public:
    /**
     * Constructor
     */
    RiskManager(
        Logger &logger,
        ContextParams &contextParams,
        RiskManagerParams &riskManagerParams)
        : _logger(&logger),
          _contextParams(&contextParams),
          _params(&riskManagerParams),
          // Validate period allowed drawdown store
          IsInitCompleted(this.InitPeriodAllowedDrawdownStore(riskManagerParams.PeriodAllowedDrawdownStore))
    {
        if (!IsInitCompleted)
        {
            _logger.LogInitFailed(__FUNCTION__);
            return;
        }

        // Set symbol info symbol name
        _symbolInfo.Name(contextParams.Symbol);

        _logger.LogInitCompleted(__FUNCTION__);
    }

    /**
     * Deconstructor
     */
    ~RiskManager()
    {
        // Risk manager params
        delete _params;

        // Period allowed draw down store
        delete _periodAllowedDrawdownStore;
    }

    /**
     * Calculate position size based on required risk percentage
     */
    double GetTradeVolume(
        TradeSignalTypeEnum tradeSignalType,
        double entryPrice = 0,
        double stopLossPrice = 0)
    {
        bool isLong = TradeSignalTypeEnumHelper::IsOpenBuyType(tradeSignalType);

        const SizeCalculationTypeEnum sizeCalculationType = _params.UseLongValueForBoth
                                                                ? _params.SizeCalculationTypeLong
                                                            : isLong
                                                                ? _params.SizeCalculationTypeLong
                                                                : _params.SizeCalculationTypeShort;

        const double sizeValueOrPercentage = _params.UseLongValueForBoth
                                                 ? _params.SizeValueOrPercentageLong
                                             : isLong
                                                 ? _params.SizeValueOrPercentageLong
                                                 : _params.SizeValueOrPercentageShort;

        // Fixed lot size
        if (sizeCalculationType == FIXED_LOT_SIZE)
        {
            return NormalizeVolume(sizeValueOrPercentage);
        }

        // Match opposite direction trading volume
        if (sizeCalculationType == MATCH_OPPOSITE_DIRECTION_VOLUME)
        {
            return NormalizeVolume(GetOppositeDirectionTotalVolume(isLong));
        }

        if (sizeCalculationType == ONE_LOT_EVERY)
        {
            return NormalizeVolume(
                MathHelper::SafeDivision(
                    _logger,
                    _accountInfo.Balance(),
                    sizeValueOrPercentage));
        }

        // Validate stop size
        const double stopSize = MathAbs(entryPrice - stopLossPrice);
        if (stopSize <= 0)
        {
            _logger.Log(ERROR, __FUNCTION__, "Invalid stop size: " + DoubleToString(stopSize));
            return 0;
        }

        double calculatedProfit = 0;
        if (OrderCalcProfit(
                ORDER_TYPE_BUY,
                _contextParams.Symbol,
                _symbolInfo.LotsMax(),
                entryPrice,
                stopLossPrice,
                calculatedProfit))
        {
            const double positionRisk = sizeCalculationType == FIXED_MONEY_AMOUNT
                                            // Fixed money amount
                                            ? sizeValueOrPercentage
                                            // Balance percentage
                                            : _accountInfo.Balance() * (sizeValueOrPercentage / 100);

            // Calculate lots using calculated profit
            calculatedProfit = isLong
                                   ? -calculatedProfit
                                   : calculatedProfit;
            const double calculatedLots = round(MathHelper::SafeDivision(
                                              _logger,
                                              positionRisk * _symbolInfo.LotsMax(),
                                              (calculatedProfit * _symbolInfo.LotsStep()))) *
                                          _symbolInfo.LotsStep();

            return NormalizeVolume(calculatedLots);
        }
        _logger.Log(ERROR, __FUNCTION__, "OrderCalcProfit: " + (string)GetLastError());
        return 0;
    }

    /**
     * Checks drawdown limits, return true if one of the limit is exceeded
     */
    bool IsDrawdownLimitExceeded()
    {
        if (_periodAllowedDrawdownStore.Count() == 0)
        {
            return false;
        }

        const double currentEquity = _accountInfo.Equity();
        const double currentBalance = _accountInfo.Balance();
        const datetime currentTime = TimeCurrent();
        bool result = false;
        for (int i = 0; i < _periodAllowedDrawdownStore.Count(); i++)
        {
            // Get item
            PeriodDrawdownItem *periodDrawdownItem = _periodAllowedDrawdownStore.Get(i);
            result |= periodDrawdownItem.IsLimitExceeded;

            // Check drawdown is below the limit
            if (!result)
            {
                const double balanceAtPeriodStart = periodDrawdownItem.BalanceAtPeriodStart;
                const double floatingPnL = (MathHelper::SafeDivision(
                                               _logger,
                                               currentEquity - balanceAtPeriodStart,
                                               balanceAtPeriodStart)) *
                                           100;
                if (floatingPnL <= (-1) * (periodDrawdownItem.MaxAllowedDrawdownPercent))
                {
                    result |= true;
                    periodDrawdownItem.IsLimitExceeded = true;
                    _logger.Log(DEBUG, __FUNCTION__, "Limit exceeded, periodDrawdownItem: " + periodDrawdownItem.ToString());
                }
            }

            // Update values if item period is expired
            datetime periodExpiration = periodDrawdownItem.PeriodStartTime + (datetime)periodDrawdownItem.PeriodDurationInSeconds;
            if (periodExpiration <= currentTime)
            {
                periodDrawdownItem.PeriodStartTime = currentTime;
                periodDrawdownItem.BalanceAtPeriodStart = currentBalance;
                periodDrawdownItem.IsLimitExceeded = false;
            }
        }

        return result;
    }

private:
    /**
     * Normalize lot size.
     * Round volume to the closest number that is a multiple of symbol volume step.
     */
    double NormalizeVolume(double volume)
    {
        // Get symbol volume step
        double volumeStep = SymbolInfoDouble(_contextParams.Symbol, SYMBOL_VOLUME_STEP);

        return MathRound(MathHelper::SafeDivision(_logger, volume, volumeStep)) * volumeStep;
    }

    /**
     * Validate period drawdown input params to check that there is not the same timeframe twice
     */
    bool InitPeriodAllowedDrawdownStore(ObjectList<CKeyValuePair<ENUM_TIMEFRAMES, double>> &periodAllowedDrawdownStore)
    {
        // Initialize class property
        _periodAllowedDrawdownStore = new ObjectList<PeriodDrawdownItem>();

        // Early exit
        if (periodAllowedDrawdownStore.Count() == 0)
        {
            delete &periodAllowedDrawdownStore;
            return true;
        }

        // Temporary list to store time frames
        BasicList<int> *periodsList = new BasicList<int>();

        // Store each time frame in the list
        double currentBalance = _accountInfo.Balance();
        datetime currentTime = TimeCurrent();
        for (int i = 0; i < periodAllowedDrawdownStore.Count(); i++)
        {
            CKeyValuePair<ENUM_TIMEFRAMES, double> *periodDrawdown = periodAllowedDrawdownStore.Get(i);

            // Return false if time frame is found twice
            if (periodsList.Contains((int)periodDrawdown.Key()))
            {
                return false;
            }

            // Append to temp list
            periodsList.Append((int)periodDrawdown.Key());

            // Append to period drawdowns store
            _periodAllowedDrawdownStore.Append(
                new PeriodDrawdownItem(
                    periodDrawdown.Key(),
                    periodDrawdown.Value(),
                    currentBalance,
                    currentTime));
        }

        // Delete dtos
        delete periodsList;
        delete &periodAllowedDrawdownStore;

        return true;
    };

    /**
     * Get total volume of open position in the opposite direction.
     */
    double GetOppositeDirectionTotalVolume(bool isLong)
    {
        double totalVolumeAmount = 0;

        // For all open positions
        for (int i = PositionsTotal() - 1; i >= 0; i--)
        {
            // Select current position
            ulong ticket = PositionGetTicket(i);
            if (PositionSelectByTicket(ticket))
            {
                // Compare magic and symbol of position
                if (PositionGetInteger(POSITION_MAGIC) == _contextParams.MagicNumber && PositionGetString(POSITION_SYMBOL) == _contextParams.Symbol)
                {
                    // Get position type
                    ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)(PositionGetInteger(POSITION_TYPE));

                    if (!isLong && POSITION_TYPE_BUY)
                    {
                        totalVolumeAmount += PositionGetDouble(POSITION_VOLUME);
                    }
                    else if (isLong && POSITION_TYPE_SELL)
                    {
                        totalVolumeAmount += PositionGetDouble(POSITION_VOLUME);
                    }
                }
            }
        }

        return totalVolumeAmount;
    }
}