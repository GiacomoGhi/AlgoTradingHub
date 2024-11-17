class TradeLevels
{
public:
    const double TakeProfit;
    const double StopLoss;
    const double OrderEntryPrice;
    const ENUM_ORDER_TYPE_TIME OrderTypeTime;
    const datetime OrderExpriation;

    /**
     * Default constructor: initializes all values to zero or suitable defaults
     * */
    TradeLevels()
        : TakeProfit(0.0),
          StopLoss(0.0),
          OrderEntryPrice(0.0),
          OrderTypeTime(ORDER_TIME_GTC),
          OrderExpriation(0)
    {
    }

    /**
     * Constructor: initializes TakeProfit and StopLoss
     * */
    TradeLevels(double takeProfit, double stopLoss)
        : TakeProfit(takeProfit),
          StopLoss(stopLoss),
          OrderEntryPrice(0.0),
          OrderTypeTime(ORDER_TIME_GTC),
          OrderExpriation(0)
    {
    }

    /**
     * Constructor: initializes all trade parameters
     * */
    TradeLevels(double takeProfit,
                double stopLoss,
                double orderEntryPrice,
                const ENUM_ORDER_TYPE_TIME orderTypeTime,
                const datetime orderExpriation)
        : TakeProfit(takeProfit),
          StopLoss(stopLoss),
          OrderEntryPrice(orderEntryPrice),
          OrderTypeTime(orderTypeTime),
          OrderExpriation(orderExpriation)
    {
    }
}