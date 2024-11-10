#include "../../Libraries/BinFlags/BinFlags.mqh";
#include "../../Shared/Interfaces/ITradeSignal.mqh";

class BaseIndicator : public ITradeSignal
{
protected:
    ENUM_TIMEFRAMES _timeFrame;
    string _symbol;
    BinFlags *_produceSignalTypeFlags;

public:
    /**
     * Constructor
     * */
    BaseIndicator(
        string symbol,
        ENUM_TIMEFRAMES timeFrame,
        BinFlags &produceSignalType)
        : _symbol(symbol),
          _timeFrame(timeFrame),
          _produceSignalTypeFlags(&produceSignalType) {};

    /**
     * Checks if indicator is set to produce given signal
     * */
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