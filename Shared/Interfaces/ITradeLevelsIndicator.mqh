// TODO update this, should be only one method that returns the TradeLevels object
interface ITradeLevelsIndicator
{
    // Returns market price for the take profit.
    double GetTakeProfitPrice();

    // Returns market price for the stop loss.
    double GetStopLossPrice();

    // Return order market price.
    double GetOrderPrice();
}