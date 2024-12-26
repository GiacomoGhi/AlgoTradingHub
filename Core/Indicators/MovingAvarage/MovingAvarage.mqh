#include "../BaseIndicator.mqh";
#include "./Models/MovingAvarageSignalsEnum.mqh";
#include "../IndicatorSignals.mqh";

class MovingAvarage : public BaseIndicator<MovingAvarageSignalsEnum>
{
private:
    const string _className;

public:
    // Constructor
    MovingAvarage(
        Logger &logger,
        string symbol,
        ENUM_TIMEFRAMES timeFrame,
        IndicatorSignals<MovingAvarageSignalsEnum> &indicatorSignals,
        int period,
        int shift,
        ENUM_MA_METHOD method,
        ENUM_APPLIED_PRICE appliedPrice)
        : _className("MovingAvarage"),
          BaseIndicator(
              "MovingAvarage",
              &logger,
              symbol,
              indicatorSignals,
              timeFrame,
              iMA(
                  symbol,
                  timeFrame,
                  period,
                  shift,
                  method,
                  appliedPrice))
    {
        _logger.LogInitCompleted(_className);
    }

    // Base class ITradeSignal implementation
    bool IsValidSignal(TradeSignalTypeEnum signalType) override
    {
        switch (signalType)
        {
        case OPEN_BUY_MARKET:
        case OPEN_BUY_LIMIT_ORDER:
        case OPEN_BUY_STOP_ORDER:
            return IsMovingAvarageValidSignal(this._openBuySignal);

        case CLOSE_BUY_MARKET:
        case DELETE_BUY_ORDER:
            return IsMovingAvarageValidSignal(this._closeBuySignal);

        case OPEN_SELL_MARKET:
        case OPEN_SELL_LIMIT_ORDER:
        case OPEN_SELL_STOP_ORDER:
            return IsMovingAvarageValidSignal(this._openSellSignal);

        case CLOSE_SELL_MARKET:
        case DELETE_SELL_ORDER:
            return IsMovingAvarageValidSignal(this._closeSellSignal);
        default:
            return false;
        }
    };

private:
    // Return signal method result given a signal type
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

    // Check if previous candle close price is above the moving avarage
    bool IsCloseAboveSignal()
    {
        return MarketHelper::GetClosePrice(this._symbol) > this.GetIndicatorValue(_handle, 1);
    };

    // Check if previous candle close price is below the moving avarage
    bool IsCloseBelowSignal()
    {
        return MarketHelper::GetClosePrice(this._symbol) < this.GetIndicatorValue(_handle, 1);
    };

    // Check if price previous close was below and price current close is below
    bool IsPriceUpwardCrossSignal()
    {
        return false;
    };

    // Check if price previous close was above and price current close is below
    bool IsPriceDownwardCrossSignal()
    {
        return false;
    };

    // Check if moving avarage is in upward direction
    bool IsUpwardDirectionSignal()
    {
        return false;
    };

    // Check if moving avarage is in downward direction
    bool IsDownwardDirectionSignal()
    {
        return false;
    };

    // Check if moving avarage turned from downward to an upward direction
    bool IsUpwardTurnAroundSignal()
    {
        return false;
    };

    // Check if moving avarage turned from upward to a downward direction
    bool IsDownwardTurnAroundSignal()
    {
        return false;
    };
}