#include "../../Managers/TradeManager/TradeManager.mqh";
#include "../BaseIndicator.mqh";
#include "./Models/StaticRangeSignalsEnum.mqh";

class StaticRange : public BaseIndicator<StaticRangeSignalsEnum>
{
private:
    double _minPrice;
    double _maxPrice;
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
        double positionsDeltaPoints)
        : _minPrice(minPrice),
          _maxPrice(maxPrice),
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

    /**
     * Base class ITradeSignalProvider implementation
     */
    void UpdateSignalStore(CHashMap<TradeSignalTypeEnum, bool> &signalsStore) override
    {
        for (int i = 0; i < _signalTypeTriggerList.Count(); i++)
        {
            // Variable for readability
            TradeSignalTypeEnum signalType = _signalTypeTriggerList[i].Key();

            // Add entry if missing
            bool isValidSignal = true;
            if (!signalsStore.TryGetValue(signalType, isValidSignal))
            {
                signalsStore.Add(signalType, isValidSignal);
            }

            // Update signal validity
            isValidSignal &= IsStaticRangeValidSignal(_signalTypeTriggerList[i].Value());
            signalsStore.TrySetValue(signalType, isValidSignal);
        }
    };

private:
    /**
     * Return signal method result given a signal type
     */
    bool IsStaticRangeValidSignal(StaticRangeSignalsEnum signalType)
    {
        switch (signalType)
        {
        case StaticRangeSignalsEnum::PRICE_ABOVE_MIN_PRICE:
            return IsPriceAboveMinPriceSignal();

        case StaticRangeSignalsEnum::PRICE_BELOW_MAX_PRICE:
            return IsPriceBelowMinPriceSignal();

        case StaticRangeSignalsEnum::PRICE_ABOVE_MAX_PRICE:
            return IsPriceAboveMaxPriceSignal();

        case StaticRangeSignalsEnum::OVER_PREVIOUS_POSITION_DELTA:
            return IsPriceOverPreviousPositionDelta();

        default:
            return false;
        };
    };

    /**
     * Checks that current bid price is above min price
     */
    bool IsPriceAboveMinPriceSignal()
    {
        return MarketHelper::GetBidPrice(_symbol) > _minPrice;
    }

    /**
     * Checks that current bid price is above max price
     */
    bool IsPriceAboveMaxPriceSignal()
    {
        return MarketHelper::GetBidPrice(_symbol) > _maxPrice;
    }

    /**
     * Checks that current bid price is above min price
     */
    bool IsPriceBelowMinPriceSignal()
    {
        return MarketHelper::GetBidPrice(_symbol) < _maxPrice;
    }

    /**
     * Checks that current bid price is grater then
     * lower position price + position delta
     */
    bool IsPriceOverPreviousPositionDelta()
    {
        // Select latest position
        if (!TradeManager::SelectLatestPosition(_logger, _magicNumber))
        {
            // If not any position was found,
            return true;
        }

        // Get latest position open price
        double lastestPositionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        double bidPrice = MarketHelper::GetBidPrice(_symbol);

        _logger.Log(
            DEBUG,
            __FUNCTION__,
            "bidPrice: " +
                (string)bidPrice +
                " > lastestPositionPrice + _positionsDeltaPoints: " +
                (string)(lastestPositionPrice + _positionsDeltaPoints));

        // Compare
        return bidPrice > (lastestPositionPrice + _positionsDeltaPoints);
    }
}