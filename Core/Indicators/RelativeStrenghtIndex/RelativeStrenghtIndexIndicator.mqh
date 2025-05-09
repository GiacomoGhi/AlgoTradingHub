#include "../BaseIndicator.mqh";
#include "./Models/RelativeStrenghtIndexSignalsEnum.mqh";

class RelativeStrenghtIndexIndicator : public BaseIndicator<RelativeStrenghtIndexSignalsEnum>
{
private:
    /**
     * Overbought level.
     */
    double _overboughtLevel;

    /**
     * Oversold level.
     */
    double _oversoldLevel;

public:
    /**
     * Constructor
     */
    RelativeStrenghtIndexIndicator(
        Logger &logger,
        string symbol,
        ENUM_TIMEFRAMES timeFrame,
        ObjectList<CKeyValuePair<TradeSignalTypeEnum, RelativeStrenghtIndexSignalsEnum>> &signalTypeTriggerStore,
        int maPeriod,
        ENUM_APPLIED_PRICE appliedPrice,
        double overboughtLevel,
        double oversoldLevel)
        : _overboughtLevel(overboughtLevel),
          _oversoldLevel(oversoldLevel),
          BaseIndicator(
              &logger,
              symbol,
              signalTypeTriggerStore,
              timeFrame,
              iRSI(symbol, timeFrame, maPeriod, appliedPrice))
    {
        _logger.LogInitCompleted(__FUNCTION__);
    }

    /**
     * Deconstructor
     */
    ~RelativeStrenghtIndexIndicator()
    {
        this.BaseIndicatorDeconstructor();
    }

protected:
    /**
     * Base class method override.
     */
    bool IsIndicatorValidSignal(RelativeStrenghtIndexSignalsEnum signalType) override
    {
        switch (signalType)
        {
        case RSI_OVERBOUGHT:
            return GetIndicatorValue() > _overboughtLevel;

        case RSI_NOT_OVERBOUGHT:
            return GetIndicatorValue() <= _overboughtLevel;

        case RSI_OVERSOLD:
            return GetIndicatorValue() < _oversoldLevel;

        case RSI_NOT_OVERSOLD:
            return GetIndicatorValue() >= _oversoldLevel;

        default:
            return false;
        };
    };
}