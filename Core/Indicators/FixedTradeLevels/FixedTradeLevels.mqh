#include "../../Shared/Interfaces/ITradeLevelsIndicator.mqh";
#include "../../Shared/Helpers/MarketHelper.mqh";
#include "../../Shared/Helpers/TradeSignalTypeEnumHelper.mqh";
#include "../../Shared/Models/ContextParams.mqh";
#include "../../Shared/Logger/Logger.mqh";

class FixedTradeLevels : public ITradeLevelsIndicator
{
private:
    /**
     * Name of the class.
     */
    const string _className;

    /**
     * Logger
     */
    Logger *_logger;

    /**
     * Context params
     */
    ContextParams *_contextParams;

    /**
     * Take profit level distance from open price.
     */
    int _takeProfitLenght;

    /**
     * Stop profit level distance from open price.
     */
    int _stopLossLenght;

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

public:
    /**
     * Constructor to initialize FixedTradeLevels with specific parameters.
     */
    FixedTradeLevels(
        Logger &logger,
        ContextParams &contextParams,
        int takeProfitLenght = 0,
        int stopLossLenght = 0,
        int orderDistanceFromCurrentPrice = 0,
        ENUM_ORDER_TYPE_TIME orderTypeTime = ORDER_TIME_GTC,
        int orderExpirationHour = -1,
        string className = "FixedTradeLevels")
        : _className(className),
          _logger(&logger),
          _contextParams(&contextParams),
          _takeProfitLenght(takeProfitLenght),
          _stopLossLenght(stopLossLenght),
          _orderDistanceFromCurrentPrice(orderDistanceFromCurrentPrice),
          _orderTypeTime(orderTypeTime),
          _orderExpirationHour(orderExpirationHour)
    {
        _logger.LogInitCompleted(_className);
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
        // Prepare ask and bid price
        double currentAskPrice = MarketHelper::GetAskPrice(_contextParams.Symbol);
        double currentBidPrice = MarketHelper::GetBidPrice(_contextParams.Symbol);

        // Prepare tp and sl levels
        double takeProfitPrice;
        double stopLossPrice;
        const double points = _contextParams.Points;
        if (TradeSignalTypeEnumHelper::IsOpenBuyType(tradeSignal))
        {
            takeProfitPrice = _takeProfitLenght > 0
                                  ? currentAskPrice + (_takeProfitLenght * points)
                                  : 0;

            stopLossPrice = _stopLossLenght > 0
                                ? currentBidPrice - (_stopLossLenght * points)
                                : 0;
        }
        else
        {
            takeProfitPrice = _takeProfitLenght > 0
                                  ? currentBidPrice - (_takeProfitLenght * points)
                                  : 0;

            stopLossPrice = _stopLossLenght > 0
                                ? currentAskPrice + (_stopLossLenght * points)
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
                // TODO log error
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
            takeProfitPrice = _takeProfitLenght > 0
                                  ? takeProfitPrice = orderPrice + (_takeProfitLenght * points)
                                  : 0;

            // Stop loss
            stopLossPrice = _takeProfitLenght > 0
                                ? takeProfitPrice = orderPrice - (_stopLossLenght * points)
                                : 0;
        }
        else
        {
            // Order price
            orderPrice = TradeSignalTypeEnumHelper::IsLimitType(tradeSignal)
                             ? currentBidPrice - (_orderDistanceFromCurrentPrice * points)
                             : currentBidPrice + (_orderDistanceFromCurrentPrice * points);

            // Take profit
            takeProfitPrice = _takeProfitLenght > 0
                                  ? takeProfitPrice = orderPrice - (_takeProfitLenght * points)
                                  : 0;

            // Stop loss
            stopLossPrice = _takeProfitLenght > 0
                                ? takeProfitPrice = orderPrice + (_stopLossLenght * points)
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