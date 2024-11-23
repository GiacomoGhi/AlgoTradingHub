#include "../BaseIndicator.mqh";
#include "./Models/TimeIndicatorSignalsEnum.mqh";

class TimeIndicator : public BaseIndicator
{
private:
    TimeIndicatorSignalsEnum _buySignalType;
    TimeIndicatorSignalsEnum _closeBuySignalType;
    TimeIndicatorSignalsEnum _sellSignalType;
    TimeIndicatorSignalsEnum _closeSellSignalType;
    int _openTradeHour;
    int _closeTradeHour;
    int _rangeStartHour;
    int _rangeEndHour;

public:
    // Constructor
    TimeIndicator(
        string symbol,
        ENUM_TIMEFRAMES timeFrame,
        BinFlags &produceSignalType,
        int openTradeHour,
        int closeTradeHour,
        TimeIndicatorSignalsEnum buySignal,
        TimeIndicatorSignalsEnum buySignalClose,
        TimeIndicatorSignalsEnum sellSignal,
        TimeIndicatorSignalsEnum sellSignalClose,
        int rangeStartHour = 0,
        int rangeStopHour = 0)
        : _buySignalType(buySignal),
          _closeBuySignalType(buySignalClose),
          _sellSignalType(sellSignal),
          _closeSellSignalType(sellSignalClose),
          _openTradeHour(openTradeHour),
          _closeTradeHour(closeTradeHour),
          _rangeStartHour(rangeStartHour),
          _rangeEndHour(rangeStopHour),
          // Call base class constructor
          BaseIndicator(symbol, timeFrame, &produceSignalType)
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
        case CurrentHourIsOpenHour:
            return IsCurrentHourOpenHour();

        case CurrentHourIsCloseHour:
            return IsCurrentHourCloseHour();

        case CurrentTimeIsInRange:
            return IsCurrentTimeInRange();

        case AlwaysTrue:
            return true;

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