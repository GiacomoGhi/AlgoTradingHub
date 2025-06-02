#include "../../Shared/Helpers/MarketHelper.mqh";
#include "../../Shared/Helpers/TradeSignalTypeEnumHelper.mqh";
#include "../../Shared/Interfaces/ITradeLevelsIndicator.mqh";
#include "../../Shared/Logger/Logger.mqh";
#include "../../Shared/Models/ContextParams.mqh";
#include "../../Managers/TradeManager/TradeManager.mqh";

class FixedTradeLevels : public ITradeLevelsIndicator
{
private:
    /**
     * Logger
     */
    Logger *_logger;

    /**
     * Context params
     */
    ContextParams *_contextParams;

    /**
     * Long trades take profit level distance from open price.
     */
    int _longTradesTakeProfitLenght;

    /**
     * Long trades stop profit level distance from open price.
     */
    int _longTradesStopLossLenght;

    /**
     * Short trades take profit level distance from open price.
     */
    int _shortTradesTakeProfitLenght;

    /**
     * Short trades stop profit level distance from open price.
     */
    int _shortTradesStopLossLenght;

    /**
     * Pending order distance from current price.
     */
    int _orderDistanceFromCurrentPrice;

    /**
     * Order tpye time enum.
     */
    ENUM_ORDER_TYPE_TIME _orderTypeTime;

    /**
     * Order expiration hour.
     */
    int _orderExpirationHour;

    /**
     * Flag to indicate if grid trading is enabled.
     */
    bool _isGridTradingEnabled;

public:
    /**
     * Constructor to initialize FixedTradeLevels with specific parameters.
     */
    FixedTradeLevels(
        Logger &logger,
        ContextParams &contextParams,
        int longTradesTakeProfitLenght = 0,
        int longTradesStopLossLenght = 0,
        int shortTradesTakeProfitLenght = 0,
        int shortTradesStopLossLenght = 0,
        int orderDistanceFromCurrentPrice = 0,
        ENUM_ORDER_TYPE_TIME orderTypeTime = ORDER_TIME_GTC,
        int orderExpirationHour = -1,
        bool isGridTradingEnabled = false)
        : _logger(&logger),
          _contextParams(&contextParams),
          _longTradesTakeProfitLenght(longTradesTakeProfitLenght),
          _longTradesStopLossLenght(longTradesStopLossLenght),
          _shortTradesTakeProfitLenght(shortTradesTakeProfitLenght),
          _shortTradesStopLossLenght(shortTradesStopLossLenght),
          _orderDistanceFromCurrentPrice(orderDistanceFromCurrentPrice),
          _orderTypeTime(orderTypeTime),
          _orderExpirationHour(orderExpirationHour),
          _isGridTradingEnabled(isGridTradingEnabled)
    {
        _logger.LogInitCompleted(__FUNCTION__);
    };

    /**
     * ITradeLevelsIndicator implementation.
     */
    TradeLevels *GetTradeLevels(TradeSignalTypeEnum tradeSignal)
    {
        if (TradeSignalTypeEnumHelper::IsLimitType(tradeSignal))
        {
            return this.GetPendingOrderTradeLevels(tradeSignal);
        }
        else
        {
            return this.GetMarketOrderTradeLevels(tradeSignal);
        }
    }

private:
    /**
     * Generates trade levels for a market order based on the trade signal..
     */
    TradeLevels *GetMarketOrderTradeLevels(TradeSignalTypeEnum tradeSignal)
    {
        // If grid trading is enabled and there is an open position
        // next position is considered as a mediation position without any tp/sl levels.
        bool isLong = TradeSignalTypeEnumHelper::IsOpenBuyType(tradeSignal);
        if (_isGridTradingEnabled && TradeManager::SelectLatestPosition(
                                         _logger,
                                         _contextParams.MagicNumber,
                                         _contextParams.Symbol,
                                         isLong ? 1 : -1))
        {
            return new TradeLevels();
        }

        // Prepare ask and bid price
        double currentAskPrice = MarketHelper::GetAskPrice(_contextParams.Symbol);
        double currentBidPrice = MarketHelper::GetBidPrice(_contextParams.Symbol);

        // Prepare tp and sl levels
        double takeProfitPrice;
        double stopLossPrice;
        const double points = _contextParams.Points;
        if (isLong)
        {
            takeProfitPrice = _longTradesTakeProfitLenght > 0
                                  ? currentAskPrice + (_longTradesTakeProfitLenght * points)
                                  : 0;

            stopLossPrice = _longTradesStopLossLenght > 0
                                ? currentBidPrice - (_longTradesStopLossLenght * points)
                                : 0;
        }
        else
        {
            takeProfitPrice = _shortTradesTakeProfitLenght > 0
                                  ? currentBidPrice - (_shortTradesTakeProfitLenght * points)
                                  : 0;

            stopLossPrice = _shortTradesStopLossLenght > 0
                                ? currentAskPrice + (_shortTradesStopLossLenght * points)
                                : 0;
        }

        return new TradeLevels(
            NormalizeDouble(takeProfitPrice, _contextParams.Digits),
            NormalizeDouble(stopLossPrice, _contextParams.Digits));
    }

    /**
     * Generates trade levels for a pending order based on the trade signal.
     */
    TradeLevels *GetPendingOrderTradeLevels(TradeSignalTypeEnum tradeSignal)
    {
        // Prepare order expiration time
        datetime orderExpiration = 0;
        if (_orderExpirationHour >= 0)
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

        // Prepare ask and bid price
        const double currentAskPrice = MarketHelper::GetAskPrice(_contextParams.Symbol);
        const double currentBidPrice = MarketHelper::GetBidPrice(_contextParams.Symbol);

        // Prepare trade levels
        double orderPrice;
        double takeProfitPrice;
        double stopLossPrice;
        const double points = _contextParams.Points;
        if (TradeSignalTypeEnumHelper::IsOpenBuyType(tradeSignal))
        {

            // Order price
            orderPrice = TradeSignalTypeEnumHelper::IsLimitType(tradeSignal)
                             ? currentAskPrice - (_orderDistanceFromCurrentPrice * points)
                             : currentAskPrice + (_orderDistanceFromCurrentPrice * points);

            // Take profit
            takeProfitPrice = _longTradesTakeProfitLenght > 0
                                  ? orderPrice + (_longTradesTakeProfitLenght * points)
                                  : 0;

            // Stop loss
            stopLossPrice = _longTradesStopLossLenght > 0
                                ? orderPrice - (_longTradesStopLossLenght * points)
                                : 0;
        }
        else
        {
            // Order price
            orderPrice = TradeSignalTypeEnumHelper::IsLimitType(tradeSignal)
                             ? currentBidPrice - (_orderDistanceFromCurrentPrice * points)
                             : currentBidPrice + (_orderDistanceFromCurrentPrice * points);

            // Take profit
            takeProfitPrice = _shortTradesTakeProfitLenght > 0
                                  ? orderPrice - (_shortTradesTakeProfitLenght * points)
                                  : 0;

            // Stop loss
            stopLossPrice = _shortTradesStopLossLenght > 0
                                ? orderPrice + (_shortTradesStopLossLenght * points)
                                : 0;
        }

        return new TradeLevels(
            NormalizeDouble(takeProfitPrice, _contextParams.Digits),
            NormalizeDouble(stopLossPrice, _contextParams.Digits),
            NormalizeDouble(orderPrice, _contextParams.Digits),
            _orderTypeTime,
            orderExpiration);
    }
}