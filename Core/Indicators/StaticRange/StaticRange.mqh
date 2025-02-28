#include "../../Managers/TradeManager/TradeManager.mqh";
#include "../BaseIndicator.mqh";
#include "./Models/StaticRangeSignalsEnum.mqh";

class StaticRange : public BaseIndicator<StaticRangeSignalsEnum>
{
private:
    double _minPrice;
    double _maxPrice;
    double _priceDeltaPoints;
    ulong _magicNumber;
    double _positionsDeltaPoints;

public:
    /**
     * Constructor
     */
    StaticRange(
        Logger &logger,
        string symbol,
        ObjectList<CKeyValuePair<TradeSignalTypeEnum, StaticRangeSignalsEnum>> &signalTypeTriggerStore,
        ulong magicNumber,
        double minPrice,
        double maxPrice,
        double priceDeltaPoints,
        double positionsDeltaPoints)
        : _minPrice(minPrice),
          _maxPrice(maxPrice),
          _priceDeltaPoints(priceDeltaPoints * SymbolInfoDouble(symbol, SYMBOL_POINT)),
          _magicNumber(magicNumber),
          _positionsDeltaPoints(positionsDeltaPoints * SymbolInfoDouble(symbol, SYMBOL_POINT)),
          BaseIndicator(
              &logger,
              symbol,
              signalTypeTriggerStore)
    {
        _logger.LogInitCompleted(__FUNCTION__);
    }

    /**
     * Deconstructor
     */
    ~StaticRange()
    {
        this.BaseIndicatorDeconstructor();
    }

protected:
    /**
     * Base class method override.
     */
    bool IsIndicatorValidSignal(StaticRangeSignalsEnum signalType) override
    {
        switch (signalType)
        {
        case StaticRangeSignalsEnum::PRICE_ABOVE_MAX_PRICE:
            return IsPriceAboveMaxPriceSignal();

        case StaticRangeSignalsEnum::PRICE_BELOW_MAX_PRICE:
            return IsPriceBelowMaxPriceSignal();

        case StaticRangeSignalsEnum::PRICE_ABOVE_MIN_PRICE:
            return IsPriceAboveMinPriceSignal();

        case StaticRangeSignalsEnum::PRICE_BELOW_MIN_PRICE:
            return IsPriceBelowMinPriceSignal();

        case StaticRangeSignalsEnum::PRICE_ABOVE_MAX_PRICE_PLUS_DELTA:
            return IsPriceAboveMaxPricePlusDeltaSignal();

        case StaticRangeSignalsEnum::PRICE_BELOW_MAX_PRICE_PLUS_DELTA:
            return IsPriceBelowMaxPricePlusDeltaSignal();

        case StaticRangeSignalsEnum::OVER_PREVIOUS_POSITION_DELTA:
            return IsPriceOverPreviousPositionDelta();

        case StaticRangeSignalsEnum::UNDER_PREVIOUS_POSITION_DELTA:
            return IsPriceUnderPreviousPositionDelta();

        case StaticRangeSignalsEnum::OVER_PREVIOUS_BUY_POSITION_DELTA:
            return IsPriceOverPreviousPositionDelta(1);

        case StaticRangeSignalsEnum::OVER_PREVIOUS_SELL_POSITION_DELTA:
            return IsPriceOverPreviousPositionDelta(-1);

        case StaticRangeSignalsEnum::UNDER_PREVIOUS_BUY_POSITION_DELTA:
            return IsPriceUnderPreviousPositionDelta(1);

        case StaticRangeSignalsEnum::UNDER_PREVIOUS_SELL_POSITION_DELTA:
            return IsPriceUnderPreviousPositionDelta(-1);

        default:
            return false;
        };
    };

private:
    /**
     * Checks that current bid price is above max price
     */
    bool IsPriceAboveMaxPriceSignal()
    {
        return MarketHelper::GetBidPrice(_symbol) > _maxPrice;
    }

    /**
     * Checks that current bid price is below max price
     */
    bool IsPriceBelowMaxPriceSignal()
    {
        return MarketHelper::GetBidPrice(_symbol) < _maxPrice;
    }

    /**
     * Checks that current bid price is above min price
     */
    bool IsPriceAboveMinPriceSignal()
    {
        return MarketHelper::GetBidPrice(_symbol) > _minPrice;
    }

    /**
     * Checks that current bid price is below min price
     */
    bool IsPriceBelowMinPriceSignal()
    {
        return MarketHelper::GetBidPrice(_symbol) < _minPrice;
    }

    /**
     * Checks that current bid price is above the sum of max price and price delta points
     */
    bool IsPriceAboveMaxPricePlusDeltaSignal()
    {
        return MarketHelper::GetBidPrice(_symbol) > (_maxPrice + _priceDeltaPoints);
    }

    /**
     * Checks that current bid price is below the sum of max price and price delta points
     */
    bool IsPriceBelowMaxPricePlusDeltaSignal()
    {
        return MarketHelper::GetBidPrice(_symbol) < (_maxPrice + _priceDeltaPoints);
    }

    /**
     * Checks that current bid price is grater then
     * last position price + position delta
     */
    bool IsPriceOverPreviousPositionDelta(int direction = 0)
    {
        // Select latest position
        if (!TradeManager::SelectLatestPosition(_logger, _magicNumber, _symbol, direction))
        {
            // If not any position was found,
            return true;
        }

        // Get latest position open price
        double lastestPositionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        double bidPrice = MarketHelper::GetBidPrice(_symbol);

        // Compare
        return bidPrice > (lastestPositionPrice + _positionsDeltaPoints);
    }

    /**
     * Checks that current bid price is less then
     * last position price + position delta
     */
    bool IsPriceUnderPreviousPositionDelta(int direction = 0)
    {
        // Select latest position
        if (!TradeManager::SelectLatestPosition(_logger, _magicNumber, _symbol, direction))
        {
            // If not any position was found,
            return true;
        }

        // Get latest position open price
        double lastestPositionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        double bidPrice = MarketHelper::GetBidPrice(_symbol);

        // Compare
        return bidPrice < (lastestPositionPrice - _positionsDeltaPoints);
    }
}