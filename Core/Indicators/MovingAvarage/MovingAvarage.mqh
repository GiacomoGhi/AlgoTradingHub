#include "../BaseIndicator.mqh";
#include "./Models/MovingAvarageSignalsEnum.mqh";

class MovingAvarage : public BaseIndicator<MovingAvarageSignalsEnum>
{
public:
    /**
     * Constructor
     */
    MovingAvarage(
        Logger &logger,
        string symbol,
        CHashMap<TradeSignalTypeEnum, MovingAvarageSignalsEnum> &signalTypeTriggerStore,
        ENUM_TIMEFRAMES timeFrame,
        int period,
        int shift,
        ENUM_MA_METHOD method,
        ENUM_APPLIED_PRICE appliedPrice)
        : BaseIndicator(
              &logger,
              symbol,
              signalTypeTriggerStore,
              timeFrame,
              iMA(symbol,
                  timeFrame,
                  period,
                  shift,
                  method,
                  appliedPrice))
    {
        _logger.LogInitCompleted(__FUNCTION__);
    }

    /**
     * Deconstructor
     */
    ~MovingAvarage()
    {
        this.BaseIndicatorDeconstructor();
    }

    /**
     * Base class ITradeSignalProvider implementation
     */
    void UpdateSignalStore(CHashMap<TradeSignalTypeEnum, bool> &signalsStore) override
    {
        for (int i = 0; i < _signalsStoreArraySize; i++)
        {
            // Variable for readability
            TradeSignalTypeEnum signalType = _signalsStoreArray[i].Key();

            // Add entry if missing
            bool isValidSignal = true;
            if (!signalsStore.TryGetValue(signalType, isValidSignal))
            {
                signalsStore.Add(signalType, isValidSignal);
            }

            // Update signal validity
            isValidSignal &= IsMovingAvarageValidSignal(_signalsStoreArray[i].Value());
            signalsStore.TrySetValue(signalType, isValidSignal);
        }
    };

private:
    /**
     * Return signal method result given a signal type
     */
    bool IsMovingAvarageValidSignal(MovingAvarageSignalsEnum signalType)
    {
        switch (signalType)
        {
        case PRICE_CLOSE_ABOVE:
            return IsCloseAboveSignal();

        case PRICE_CLOSE_BELOW:
            return IsCloseBelowSignal();

        case PRICE_UPWARD_CROSS:
            return IsPriceUpwardCrossSignal();

        case PRICE_DOWNWARD_CROSS:
            return IsPriceDownwardCrossSignal();

        case UPWARD_DIRECTION:
            return IsUpwardDirectionSignal();

        case DOWNWARD_DIRECTION:
            return IsDownwardDirectionSignal();

        case UPWARD_TURNAROUND:
            return IsUpwardTurnAroundSignal();

        case DOWNWARD_TURNAROUND:
            return IsDownwardTurnAroundSignal();

        default:
            return false;
        };
    };

    /**
     * Check if previous candle close price is above the moving avarage
     */
    bool IsCloseAboveSignal()
    {
        return MarketHelper::GetClosePrice(this._symbol) > this.GetIndicatorValue(1);
    };

    /**
     * Check if previous candle close price is below the moving avarage
     */
    bool IsCloseBelowSignal()
    {
        return MarketHelper::GetClosePrice(this._symbol) < this.GetIndicatorValue(_handle, 1);
    };

    /**
     * Check if price previous close was below and price current close is below
     */
    bool IsPriceUpwardCrossSignal()
    {
        return false;
    };

    /**
     * Check if price previous close was above and price current close is below
     */
    bool IsPriceDownwardCrossSignal()
    {
        return false;
    };

    /**
     * Check if moving avarage is in upward direction
     */
    bool IsUpwardDirectionSignal()
    {
        return false;
    };

    /**
     * Check if moving avarage is in downward direction
     */
    bool IsDownwardDirectionSignal()
    {
        return false;
    };

    /**
     * Check if moving avarage turned from downward to an upward direction
     */
    bool IsUpwardTurnAroundSignal()
    {
        return false;
    };

    /**
     * Check if moving avarage turned from upward to a downward direction
     */
    bool IsDownwardTurnAroundSignal()
    {
        return false;
    };
}