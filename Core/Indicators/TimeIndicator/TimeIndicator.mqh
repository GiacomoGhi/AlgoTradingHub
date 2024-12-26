#include "../BaseIndicator.mqh";
#include "../IndicatorSignals.mqh";
#include "./Models/TimeIndicatorSignalsEnum.mqh";

class TimeIndicator : public BaseIndicator<TimeIndicatorSignalsEnum>
{
private:
    const string _className;
    int _openTradeHour;
    int _closeTradeHour;
    int _rangeStartHour;
    int _rangeEndHour;

public:
    // Constructor
    TimeIndicator(
        Logger &logger,
        string symbol,
        IndicatorSignals<TimeIndicatorSignalsEnum> &indicatorSignals,
        int openTradeHour,
        int closeTradeHour,
        int rangeStartHour = 0,
        int rangeStopHour = 0)
        : _className("TimeIndicator"),
          _openTradeHour(openTradeHour),
          _closeTradeHour(closeTradeHour),
          _rangeStartHour(rangeStartHour),
          _rangeEndHour(rangeStopHour),
          BaseIndicator("TimeIndicator", &logger, symbol, indicatorSignals)
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
            return IsTimeIndicatorValidSignal(this._openBuySignal);

        case CLOSE_BUY_MARKET:
        case DELETE_BUY_ORDER:
            return IsTimeIndicatorValidSignal(this._closeBuySignal);

        case OPEN_SELL_MARKET:
        case OPEN_SELL_LIMIT_ORDER:
        case OPEN_SELL_STOP_ORDER:
            return IsTimeIndicatorValidSignal(this._openSellSignal);

        case CLOSE_SELL_MARKET:
        case DELETE_SELL_ORDER:
            return IsTimeIndicatorValidSignal(this._closeSellSignal);
        default:
            return false;
        }
    };

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