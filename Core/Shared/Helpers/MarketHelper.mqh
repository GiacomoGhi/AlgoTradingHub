class MarketHelper
{
private:
    MarketHelper() {}

public:
    // Get ask price
    static double GetAskPrice(const string &symbol = _Symbol)
    {
        return SymbolInfoDouble(symbol, SYMBOL_ASK);
    }

    // Get bid price
    static double GetBidPrice(const string &symbol = _Symbol)
    {
        return SymbolInfoDouble(symbol, SYMBOL_BID);
    }

    // Get close price
    static double GetClosePrice(int shift = 1, const string &symbol = _Symbol, ENUM_TIMEFRAMES timeFrame = PERIOD_CURRENT)
    {
        return iClose(symbol, timeFrame, shift);
    }

    // Get open price
    static double GetOpenPrice(int shift = 1, const string &symbol = _Symbol, ENUM_TIMEFRAMES timeFrame = PERIOD_CURRENT)
    {
        return iOpen(symbol, timeFrame, shift);
    }
}