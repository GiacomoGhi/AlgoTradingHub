#include "../BaseIndicator.mqh";
#include "./Models/MovingAvarageSignalsEnum.mqh";

class MovingAvarage : public BaseSignalProvider<MovingAvarageSignalsEnum>
{
public:
    /**
     * Constructor
     */
    MovingAvarage(
        Logger &logger,
        string symbol,
        ObjectList<CKeyValuePair<TradeSignalTypeEnum, MovingAvarageSignalsEnum>> &signalTypeTriggerStore,
        ENUM_TIMEFRAMES timeFrame,
        int period,
        int shift,
        ENUM_MA_METHOD method,
        ENUM_APPLIED_PRICE appliedPrice)
        : BaseSignalProvider(
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

protected:
    /**
     * Base class method override.
     */
    bool IsIndicatorValidSignal(MovingAvarageSignalsEnum signalType) override
    {
        switch (signalType)
        {
        case MovingAvarageSignalsEnum::PRICE_CLOSE_ABOVE:
            return IsCloseAboveSignal();

        case MovingAvarageSignalsEnum::PRICE_CLOSE_BELOW:
            return IsCloseBelowSignal();

        case MovingAvarageSignalsEnum::PRICE_UPWARD_CROSS:
            return IsPriceUpwardCrossSignal();

        case MovingAvarageSignalsEnum::PRICE_DOWNWARD_CROSS:
            return IsPriceDownwardCrossSignal();

        case MovingAvarageSignalsEnum::UPWARD_DIRECTION:
            return IsUpwardDirectionSignal();

        case MovingAvarageSignalsEnum::DOWNWARD_DIRECTION:
            return IsDownwardDirectionSignal();

        case MovingAvarageSignalsEnum::UPWARD_TURNAROUND:
            return IsUpwardTurnAroundSignal();

        case MovingAvarageSignalsEnum::DOWNWARD_TURNAROUND:
            return IsDownwardTurnAroundSignal();

        default:
            return false;
        };
    };

private:
    /**
     * Check if previous candle close price is above the moving avarage
     */
    bool IsCloseAboveSignal()
    {
        return MarketHelper::GetClosePrice(_symbol, 1, _timeFrame) > this.GetIndicatorValue(1);
    };

    /**
     * Check if previous candle close price is below the moving avarage
     */
    bool IsCloseBelowSignal()
    {
        return MarketHelper::GetClosePrice(_symbol, 1, _timeFrame) < this.GetIndicatorValue(1);
    };

    /**
     * Check if, in the previous two closure the first one was below and
     * the second was above the moving avarage
     */
    bool IsPriceUpwardCrossSignal()
    {
        // Check close below of candle with shift of 2 from current one
        return MarketHelper::GetClosePrice(_symbol, 2, _timeFrame) < this.GetIndicatorValue(2)
               // Check close above candle with shift of 1 from current one
               && MarketHelper::GetClosePrice(_symbol, 1, _timeFrame) > this.GetIndicatorValue(1);
    };

    /**
     * Check if price previous close was above and price current close is below
     */
    bool IsPriceDownwardCrossSignal()
    {
        // Check close above of candle with shift of 2 from current one
        return MarketHelper::GetClosePrice(_symbol, 2, _timeFrame) > this.GetIndicatorValue(2)
               // Check close below candle with shift of 1 from current one
               && MarketHelper::GetClosePrice(_symbol, 1, _timeFrame) < this.GetIndicatorValue(1);
    };

    /**
     * Check if moving avarage is in upward direction
     */
    bool IsUpwardDirectionSignal()
    {
        return this.GetIndicatorValue(2) < this.GetIndicatorValue(1);
    };

    /**
     * Check if moving avarage is in downward direction
     */
    bool IsDownwardDirectionSignal()
    {
        return this.GetIndicatorValue(2) > this.GetIndicatorValue(1);
    };

    /**
     * Check if moving avarage turned from downward to an upward direction
     */
    bool IsUpwardTurnAroundSignal()
    {
        // Check that third previous close were above the second
        return this.GetIndicatorValue(3) > this.GetIndicatorValue(2)
               // Check last close is above the second
               && this.GetIndicatorValue(1) > this.GetIndicatorValue(2);
    };

    /**
     * Check if moving avarage turned from upward to a downward direction
     */
    bool IsDownwardTurnAroundSignal()
    {
        // Check that third previous close were above the second
        return this.GetIndicatorValue(3) < this.GetIndicatorValue(2)
               // Check last close is above the second
               && this.GetIndicatorValue(1) < this.GetIndicatorValue(2);
    };
}