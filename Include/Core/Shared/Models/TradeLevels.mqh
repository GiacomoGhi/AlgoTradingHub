class TradeLevels
{
public:
  /**
   * Take profit price.
   */
  const double TakeProfit;

  /**
   * Stop loss price.
   */
  const double StopLoss;

  /**
   * Order entry price
   */
  const double OrderEntryPrice;

  /**
   * Order time tpye enum
   */
  const ENUM_ORDER_TYPE_TIME OrderTypeTime;

  /**
   * Order expiration time
   */
  const datetime OrderExpriation;

  /**
   * Constructor: initializes TakeProfit and StopLoss
   * */
  TradeLevels(double takeProfit = 0, double stopLoss = 0)
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