#include "../../Shared/Helpers/MarketHelper.mqh";
#include "../../Shared/Helpers/MathHelper.mqh";
#include "../../Shared/Helpers/TradeSignalTypeEnumHelper.mqh";
#include "../../Shared/Interfaces/ITradeLevelsIndicator.mqh";
#include "../../Shared/Logger/Logger.mqh";
#include "../../Shared/Models/ContextParams.mqh";
#include "../BaseIndicator.mqh";
#include "./Models/PriceRangeTradeLevelsSignalsEnum.mqh";

class PriceRangeTradeLevels : public BaseIndicator<PriceRangeTradeLevelsSignalsEnum>
{
private:
    /**
     * Context params.
     */
    ContextParams *_contextParams;

    /**
     * Bars number.
     */
    int _barsNumber;

    /**
     * Max range percentage height.
     */
    double _maxRangePercentageHeight;

    /**
     * Min range percentage height.
     */
    double _minRangePercentageHeight;

    /**
     * Order price delta.
     */
    int _orderPriceDelta;

    /**
     * Order stop loss delta.
     */
    int _orderStopLossDelta;

    /**
     * Order tpye time enum.
     */
    ENUM_ORDER_TYPE_TIME _orderTypeTime;

    /**
     * Order expiration hour.
     */
    int _orderExpirationHour;

public:
    /**
     * Constructor to initialize PriceRangeTradeLevels with specific parameters.
     */
    PriceRangeTradeLevels(
        Logger &logger,
        ContextParams &contextParams,
        ObjectList<CKeyValuePair<TradeSignalTypeEnum, PriceRangeTradeLevelsSignalsEnum>> &signalTypeTriggerStore,
        ENUM_TIMEFRAMES timeFrame,
        int barsNumber,
        double maxRangePercentageHeight,
        double minRangePercentageHeight,
        int orderPriceDelta,
        int orderStopLossDelta,
        ENUM_ORDER_TYPE_TIME orderTypeTime = ORDER_TIME_GTC,
        int orderExpirationHour = -1)
        : _contextParams(&contextParams),
          _barsNumber(barsNumber),
          _maxRangePercentageHeight(maxRangePercentageHeight),
          _minRangePercentageHeight(minRangePercentageHeight),
          _orderPriceDelta(orderPriceDelta),
          _orderStopLossDelta(orderStopLossDelta),
          _orderTypeTime(orderTypeTime),
          _orderExpirationHour(orderExpirationHour),
          BaseIndicator(&logger, contextParams.Symbol, signalTypeTriggerStore)
    {
        _logger.LogInitCompleted(__FUNCTION__);
    };

    /**
     * ITradeLevelsIndicator implementation.
     */
    TradeLevels *GetTradeLevels(TradeSignalTypeEnum tradeSignal)
    {
        if (TradeSignalTypeEnumHelper::IsMarketType(tradeSignal))
        {
            _logger.Log(ERROR, __FUNCTION__, "Market orders are not supported.");
            return new TradeLevels();
        }

        return this.GetPendingOrderTradeLevels(tradeSignal);
    }

protected:
    /**
     * Base class method override.
     */
    bool IsIndicatorValidSignal(PriceRangeTradeLevelsSignalsEnum signalType)
    {
        switch (signalType)
        {
        case PriceRangeTradeLevelsSignalsEnum::RANGE_HEIGHT_LESS_THEN_MAX:
            return _maxRangePercentageHeight <= 0 || PriceRangePercentageHeight() < _maxRangePercentageHeight;

        case PriceRangeTradeLevelsSignalsEnum::RANGE_HEIGHT_GRATER_THEN_MIN:
            return _minRangePercentageHeight <= 0 || PriceRangePercentageHeight() > _minRangePercentageHeight;

        default:
            return false;
        }
    }

private:
    /**
     * Returns range height in price percentage
     */
    double PriceRangePercentageHeight()
    {
        // Prepare ask and bid price
        const double rangeHighestPrice = iHigh(_contextParams.Symbol, _timeFrame, iHighest(_contextParams.Symbol, _timeFrame, MODE_HIGH, _barsNumber, 1));
        const double rangeLowestPrice = iLow(_contextParams.Symbol, _timeFrame, iLowest(_contextParams.Symbol, _timeFrame, MODE_LOW, _barsNumber, 1));

        return MathHelper::SafeDivision(
                   _logger,
                   (rangeHighestPrice - rangeLowestPrice),
                   rangeLowestPrice) *
               100;
    }

    /**
     * Generates trade levels for a pending order based on the trade signal.
     */
    TradeLevels *GetPendingOrderTradeLevels(TradeSignalTypeEnum tradeSignal)
    {
        // Prepare order expiration time
        datetime orderExpiration = 0;
        if (_orderTypeTime == ORDER_TIME_SPECIFIED && _orderExpirationHour >= 0)
        {
            MqlDateTime orderExpirationDateTimeStruct;
            TimeToStruct(TimeCurrent(), orderExpirationDateTimeStruct);

            if (orderExpirationDateTimeStruct.hour >= _orderExpirationHour)
            {
                // Update expiration
                orderExpirationDateTimeStruct.hour = _orderExpirationHour;

                // Set expiration time shifted to next day
                orderExpiration = StructToTime(orderExpirationDateTimeStruct) + 86400;
            }
            else
            {
                // Update expiration
                orderExpirationDateTimeStruct.hour = _orderExpirationHour;

                // Set expiration time
                orderExpiration = StructToTime(orderExpirationDateTimeStruct);
            }
        }

        _logger.Log(DEBUG, __FUNCTION__,
                    "expiration set to: " + TimeToString(orderExpiration, TIME_DATE | TIME_MINUTES | TIME_SECONDS));

        // Prepare ask and bid price
        const double rangeHighestPrice = iHigh(_contextParams.Symbol, _timeFrame, iHighest(_contextParams.Symbol, _timeFrame, MODE_HIGH, _barsNumber, 1));
        const double rangeLowestPrice = iLow(_contextParams.Symbol, _timeFrame, iLowest(_contextParams.Symbol, _timeFrame, MODE_LOW, _barsNumber, 1));

        // Prepare trade levels
        double orderPrice;
        double stopLossPrice;
        const double orderPriceDeltaPoints = _contextParams.Points * _orderPriceDelta;
        const double orderStopLossDeltaPoints = _contextParams.Points * _orderStopLossDelta;

        _logger.Log(DEBUG, __FUNCTION__,
                    "orderStopLossDeltaPoints: " + (string)orderStopLossDeltaPoints);

        if (TradeSignalTypeEnumHelper::IsOpenBuyType(tradeSignal))
        {
            // Order price
            orderPrice = TradeSignalTypeEnumHelper::IsLimitType(tradeSignal)
                             ? rangeLowestPrice - orderPriceDeltaPoints
                             : rangeHighestPrice + orderPriceDeltaPoints;

            // Stop loss
            stopLossPrice = rangeLowestPrice - orderStopLossDeltaPoints;
        }
        else
        {
            // Order price
            orderPrice = TradeSignalTypeEnumHelper::IsLimitType(tradeSignal)
                             ? rangeHighestPrice + orderPriceDeltaPoints
                             : rangeLowestPrice - orderPriceDeltaPoints;

            // Stop loss
            stopLossPrice = rangeHighestPrice + orderStopLossDeltaPoints;
        }

        return new TradeLevels(
            0,
            NormalizeDouble(stopLossPrice, _contextParams.Digits),
            NormalizeDouble(orderPrice, _contextParams.Digits),
            _orderTypeTime,
            orderExpiration);
    }
}