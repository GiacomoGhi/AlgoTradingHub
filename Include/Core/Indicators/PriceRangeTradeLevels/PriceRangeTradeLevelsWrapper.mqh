#include "./PriceRangeTradeLevels.mqh";

class PriceRangeTradeLevelsWrapper : public ITradeLevelsIndicator
{
private:
    PriceRangeTradeLevels *_priceRangeImplementation;

public:
    PriceRangeTradeLevelsWrapper(PriceRangeTradeLevels &priceRangeImplementation)
        : _priceRangeImplementation(&priceRangeImplementation) {}

    /**
     * ITradeLevelsIndicator implementation.
     * Forward to price range trade levels.
     */
    TradeLevels *GetTradeLevels(TradeSignalTypeEnum tradeSignal)
    {
        return _priceRangeImplementation.GetTradeLevels(tradeSignal);
    }
};