#include "../BaseModels/BaseIndicator.mqh";
#include "./Models/MovingAvarageSignalsEnum.mqh";

class MovingAvarage : public BaseIndicator
{
  private:
    MovingAvarageSignalsEnum _buySignalType;
    MovingAvarageSignalsEnum _closeBuySignalType;
    MovingAvarageSignalsEnum _sellSignalType;
    MovingAvarageSignalsEnum _closeSellSignalType;
    int _handle;

  public:
    // Constructor
    MovingAvarage(
        string symbol,
        ENUM_TIMEFRAMES timeFrame,
        int period,
        int shift,
        ENUM_MA_METHOD method,
        ENUM_APPLIED_PRICE appliedPrice,
        MovingAvarageSignalsEnum buySignal,
        MovingAvarageSignalsEnum buySignalClose,
        MovingAvarageSignalsEnum sellSignal,
        MovingAvarageSignalsEnum sellSignalClose)
        : _buySignalType(buySignal),
          _closeBuySignalType(buySignalClose),
          _sellSignalType(sellSignal),
          _closeSellSignalType(sellSignalClose),
          // Call base class constructor
          BaseIndicator(symbol, timeFrame)
    {
        // Moving avarage handle
        _handle = iMA(
            symbol,
            timeFrame,
            period,
            shift,
            method,
            appliedPrice);
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
    bool IsMovingAvarageValidSignal(MovingAvarageSignalsEnum signalType)
    {
        switch (signalType)
        {
        case CloseAbove:
            return IsCloseAboveSignal();

        case CloseBelow:
            return IsCloseBelowSignal();

        case PriceUpwardCross:
            return IsPriceUpwardCrossSignal();

        case PriceDownwardCross:
            return IsPriceDownwardCrossSignal();

        case UpwardDirection:
            return IsUpwardDirectionSignal();

        case DownwardDirection:
            return IsDownwardDirectionSignal();

        case UpwardTurnAround:
            return IsUpwardTurnAroundSignal();

        case DownwardTurnAround:
            return IsDownwardTurnAroundSignal();

        case AlwaysTrue:
            return true;

        default:
            return false;
        };
    };

    // Check if previous candle close price is above the moving avarage
    bool IsCloseAboveSignal()
    {
        return this.GetClosePrice() > this.GetIndicatorSingleValue(_handle, 1);
    };

    // Check if previous candle close price is below the moving avarage
    bool IsCloseBelowSignal()
    {
        return this.GetClosePrice() < this.GetIndicatorSingleValue(_handle, 1);
    };

    // Check if price previous close was below and price current close ss below
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