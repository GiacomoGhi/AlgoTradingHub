#include "../BaseIndicator.mqh";
#include "./Models/TimeIndicatorSignalsEnum.mqh";

class TimeIndicator : public BaseIndicator<TimeIndicatorSignalsEnum>
{
private:
    /**
     * Open trade hour.
     */
    int _openTradeHour;

    /**
     * Close trade hour.
     */
    int _closeTradeHour;

    /**
     * Range start hour.
     */
    int _rangeStartHour;

    /**
     * Range end hour.
     */
    int _rangeEndHour;

public:
    /**
     * Constructor
     */
    TimeIndicator(
        Logger &logger,
        string symbol,
        ObjectList<CKeyValuePair<TradeSignalTypeEnum, TimeIndicatorSignalsEnum>> &signalTypeTriggerStore,
        int openTradeHour,
        int closeTradeHour,
        int rangeStartHour = 0,
        int rangeStopHour = 0)
        : _openTradeHour(openTradeHour),
          _closeTradeHour(closeTradeHour),
          _rangeStartHour(rangeStartHour),
          _rangeEndHour(rangeStopHour),
          BaseIndicator(&logger, symbol, signalTypeTriggerStore)
    {
        _logger.LogInitCompleted(__FUNCTION__);
    }

    /**
     * Deconstructor
     */
    ~TimeIndicator()
    {
        this.BaseIndicatorDeconstructor();
    }

protected:
    /**
     * Base class method override.
     */
    bool IsIndicatorValidSignal(TimeIndicatorSignalsEnum signalType)
    {
        switch (signalType)
        {
        case CURRENT_HOUR_IS_OPEN_HOUR:
            return IsCurrentHourOpenHour();

        case CURRENT_HOUR_IS_CLOSE_HOUR:
            return IsCurrentHourCloseHour();

        case CURRENT_TIME_IS_IN_RANGE:
            return IsCurrentTimeInRange();

        default:
            return false;
        };
    };

private:
    /**
     * Current hour equal to open trade hour
     */
    bool IsCurrentHourOpenHour()
    {
        return GetCurrentHour() == _openTradeHour;
    };

    /**
     * Current hour equals to close trade hour
     */
    bool IsCurrentHourCloseHour()
    {
        return GetCurrentHour() == _closeTradeHour;
    };

    /**
     * Range start hour <= Current time < Range end hour
     */
    bool IsCurrentTimeInRange()
    {
        int currentHour = GetCurrentHour();
        return _rangeStartHour <= currentHour && currentHour < _rangeEndHour;
    };

    /**
     * Returns the current hour
     */
    int GetCurrentHour()
    {
        MqlDateTime timeStruct;

        TimeToStruct(iTime(_symbol, PERIOD_H1, 0), timeStruct);

        return timeStruct.hour;
    };
}