#include "../Libraries/BinFlags/BinFlags.mqh";
#include "../Shared/Interfaces/ITradeSignal.mqh";
#include "./IndicatorSignals.mqh";

template <typename TSignalsTypeEnum>
class BaseIndicator : public ITradeSignal
{
protected:
    const string _symbol;
    const int _handle;
    ENUM_TIMEFRAMES _timeFrame;
    const TSignalsTypeEnum _openBuySignal;
    const TSignalsTypeEnum _openSellSignal;
    const TSignalsTypeEnum _closeBuySignal;
    const TSignalsTypeEnum _closeSellSignal;

private:
    BinFlags *_produceSignalTypeFlags;

public:
    /**
     * Constructor
     */
    BaseIndicator(
        string symbol,
        IndicatorSignals<TSignalsTypeEnum> &indicatorSignals,
        ENUM_TIMEFRAMES timeFrame = PERIOD_H1,
        int handle = 0)
        : _symbol(symbol),
          _openBuySignal(indicatorSignals.OpenBuy.Item2),
          _openSellSignal(indicatorSignals.OpenSell.Item2),
          _closeBuySignal(indicatorSignals.CloseBuy.Item2),
          _closeSellSignal(indicatorSignals.CloseSell.Item2),
          _timeFrame(timeFrame),
          _handle(handle)
    {
        _produceSignalTypeFlags = new BinFlags();
        if (indicatorSignals.OpenBuy.Item1)
        {
            _produceSignalTypeFlags.SetFlag(TradeSignalTypeEnum::OPEN_BUY_MARKET);
            _produceSignalTypeFlags.SetFlag(TradeSignalTypeEnum::OPEN_BUY_LIMIT_ORDER);
            _produceSignalTypeFlags.SetFlag(TradeSignalTypeEnum::OPEN_BUY_STOP_ORDER);
        }

        if (indicatorSignals.OpenSell.Item1)
        {
            _produceSignalTypeFlags.SetFlag(TradeSignalTypeEnum::OPEN_SELL_MARKET);
            _produceSignalTypeFlags.SetFlag(TradeSignalTypeEnum::OPEN_SELL_LIMIT_ORDER);
            _produceSignalTypeFlags.SetFlag(TradeSignalTypeEnum::OPEN_SELL_STOP_ORDER);
        }

        if (indicatorSignals.CloseBuy.Item1)
        {
            _produceSignalTypeFlags.SetFlag(TradeSignalTypeEnum::CLOSE_BUY_MARKET);
            _produceSignalTypeFlags.SetFlag(TradeSignalTypeEnum::DELETE_BUY_ORDER);
        }

        if (indicatorSignals.CloseSell.Item1)
        {
            _produceSignalTypeFlags.SetFlag(TradeSignalTypeEnum::CLOSE_SELL_MARKET);
            _produceSignalTypeFlags.SetFlag(TradeSignalTypeEnum::DELETE_SELL_ORDER);
        }
    };

    /**
     * Checks if indicator is set to produce given signal
     */
    bool ProduceSignal(TradeSignalTypeEnum signalType)
    {
        return _produceSignalTypeFlags.HasFlag(signalType);
    }

protected:
    // Get a signle value of the indicator
    double GetIndicatorValue(int handle, int shift = 0, int bufferNumber = 1)
    {
        double valueContainer[1];

        // Copy requested value inside the container
        CopyBuffer(handle, bufferNumber, shift, 1, valueContainer);

        return valueContainer[0];
    };

    // TODO Move this to static class helper MarketHelper
    // Get ask price
    double GetAskPrice()
    {
        return SymbolInfoDouble(_symbol, SYMBOL_ASK);
    };

    // Get bid price
    double GetBidPrice()
    {
        return SymbolInfoDouble(_symbol, SYMBOL_BID);
    };

    // Get close price
    double GetClosePrice(int shift = 1)
    {
        return iClose(_symbol, _timeFrame, shift);
    }

    // Get open price
    double GetOpenPrice(int shift = 1)
    {
        return iOpen(_symbol, _timeFrame, shift);
    }
}