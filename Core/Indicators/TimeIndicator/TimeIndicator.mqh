#include "../BaseIndicator.mqh";
#include "../IndicatorSignals.mqh";
#include "./Models/TimeIndicatorSignalsEnum.mqh";

class TimeIndicator : public BaseIndicator<TimeIndicatorSignalsEnum>
{
private:
    int _openTradeHour;
    int _closeTradeHour;
    int _rangeStartHour;
    int _rangeEndHour;

public:
    // Constructor
    TimeIndicator(
        string symbol,
        IndicatorSignals<TimeIndicatorSignalsEnum> &indicatorSignals,
        int openTradeHour,
        int closeTradeHour,
        int rangeStartHour = 0,
        int rangeStopHour = 0)
        : _openTradeHour(openTradeHour),
          _closeTradeHour(closeTradeHour),
          _rangeStartHour(rangeStartHour),
          _rangeEndHour(rangeStopHour),
          BaseIndicator(symbol, indicatorSignals)
    {
    }

    // Base class ITradeSignal implementation
    bool IsValidSignal(TradeSignalTypeEnum signalType) override
    {
        switch (signalType)
        {
        // case BUY_SIGNAL:
        //     return IsTimeIndicatorValidSignal(_buySignalType);

        // case CLOSE_BUY_SIGNAL:
        //     return IsTimeIndicatorValidSignal(_closeBuySignalType);

        // case SELL_SIGNAL:
        //     return IsTimeIndicatorValidSignal(_sellSignalType);

        // case CLOSE_SELL_SIGNAL:
        //     return IsTimeIndicatorValidSignal(_closeSellSignalType);
        default:
            return false;
        }
    };

    // Private methods
private:
    // Return signal method result given a signal type
    bool IsTimeIndicatorValidSignal(TimeIndicatorSignalsEnum signalType)
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

    // Current hour equal to open trade hour
    bool IsCurrentHourOpenHour()
    {
        return GetCurrentHour() == _openTradeHour;
    };

    // Current hour equals to close trade hour
    bool IsCurrentHourCloseHour()
    {
        return GetCurrentHour() == _closeTradeHour;
    };

    // Range start hour <= Current time < Range end hour
    bool IsCurrentTimeInRange()
    {
        int currentHour = GetCurrentHour();
        return _rangeStartHour <= currentHour && currentHour < _rangeEndHour;
    };

    // Returns the current hour
    int GetCurrentHour()
    {
        MqlDateTime timeStruct;

        TimeToStruct(iTime(_symbol, PERIOD_H1, 0), timeStruct);

        return timeStruct.hour;
    };
}