;
class MarketHelper
{
private:
    MarketHelper() {}

public:
    /**
     * Get ask price
     */
    static double GetAskPrice(string symbol)
    {
        return SymbolInfoDouble(symbol, SYMBOL_ASK);
    }

    /**
     * Get bid price
     */
    static double GetBidPrice(string symbol)
    {
        return SymbolInfoDouble(symbol, SYMBOL_BID);
    }

    /**
     * Get close price
     */
    static double GetClosePrice(string symbol, int shift = 1, ENUM_TIMEFRAMES timeFrame = PERIOD_CURRENT)
    {
        return iClose(symbol, timeFrame, shift);
    }

    /**
     * Get open price
     */
    static double GetOpenPrice(string symbol, int shift = 1, ENUM_TIMEFRAMES timeFrame = PERIOD_CURRENT)
    {
        return iOpen(symbol, timeFrame, shift);
    }
}