#include "../BaseModels/BaseIndicator.mqh";
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
          BaseIndicator(symbol, timeFrame)
    {
    }

    // Base class methods override
    virtual bool IsValidSignal(TradeSignalTypeEnum signalType) override
    {
        switch (signalType)
        {
        case BuySignal:
            return IsMovingAvarageValidSignal(_buySignalType);

        case CloseBuySignal:
            return IsMovingAvarageValidSignal(_closeBuySignalType);

        case SellSignal:
            return IsMovingAvarageValidSignal(_sellSignalType);

        case CloseSellSignal:
            return IsMovingAvarageValidSignal(_closeSellSignalType);
        default:
            return false;
        }
    };

    // Private methods
  private:
    // Return signal method result given a signal type
    bool IsMovingAvarageValidSignal(TimeIndicatorSignalsEnum signalType)
    {
        switch (signalType)
        {
        case CurrentHourIsOpenHour:
            return IsCurrentHourIsOpenHour();

        case CurrentHourIsCloseHour:
            return IsCurrentHourIsCloseHour();

        case CurrentTimeIsInRange:
            return IsCurrentTimeIsInRange();

        case AlwaysTrue:
            return true;

        default:
            return false;
        };
    };

    // Current hour equal to open trade hour
    bool IsCurrentHourIsOpenHour()
    {
        return GetCurrentHour() == _openTradeHour;
    };

    // Current hour equals to close trade hour
    bool IsCurrentHourIsCloseHour()
    {
        return GetCurrentHour() == _closeTradeHour;
    };

    // Range start hour <= Current time < Range end hour
    bool IsCurrentTimeIsInRange()
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