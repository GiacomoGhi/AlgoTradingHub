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

    /**
     * Range start day.
     */
    int _rangeStartDay;

    /**
     * Range end day.
     */
    int _rangeEndDay;

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
        int rangeEndHour = 0,
        int rangeStartDay = 0,
        int rangeEndDay = 0)
        : _openTradeHour(openTradeHour),
          _closeTradeHour(closeTradeHour),
          _rangeStartHour(rangeStartHour),
          _rangeEndHour(rangeEndHour),
          _rangeStartDay(rangeStartDay),
          _rangeEndDay(rangeEndDay),
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
            return IsCurrentHour(_openTradeHour);

        case CURRENT_HOUR_IS_CLOSE_HOUR:
            return IsCurrentHour(_closeTradeHour);

        case CURRENT_DAY_IS_START_DAY:
            return IsCurrentDay(_rangeStartDay);

        case CURRENT_DAY_IS_END_DAY:
            return IsCurrentDay(_rangeEndDay);

        case CURRENT_DAY_IS_NOT_START_DAY:
            return !IsCurrentDay(_rangeStartDay);

        case CURRENT_DAY_IS_NOT_END_DAY:
            return !IsCurrentDay(_rangeEndDay);

        case CURRENT_TIME_IS_IN_TIME_RANGE:
            return IsCurrentTimeInTimeRange();

        case CURRENT_TIME_IS_IN_DAY_RANGE:
            return IsCurrentTimeInDayRange();

        default:
            return false;
        };
    };

private:
    /**
     * Current hour equal to open trade hour
     */
    bool IsCurrentHour(int hourToCompare)
    {
        return GetCurrentTimeStruct().hour == hourToCompare;
    };

    /**
     * Current hour equal to open trade hour
     */
    bool IsCurrentDay(int dayToCompare)
    {
        return GetCurrentTimeStruct().day == dayToCompare;
    };

    /**
     * Range start hour <= Current time < Range end hour
     */
    bool IsCurrentTimeInTimeRange()
    {
        int currentHour = GetCurrentTimeStruct().hour;
        return _rangeStartHour <= currentHour && currentHour < _rangeEndHour;
    };

    /**
     * Range start day <= Current time < Range end day
     */
    bool IsCurrentTimeInDayRange()
    {
        int currentDay = GetCurrentTimeStruct().day;
        return _rangeStartDay <= currentDay && currentDay < _rangeEndDay;
    };

    /**
     * Returns the current time struct
     */
    MqlDateTime GetCurrentTimeStruct()
    {
        MqlDateTime timeStruct;

        TimeToStruct(iTime(_symbol, PERIOD_H1, 0), timeStruct);

        return timeStruct;
    };
}