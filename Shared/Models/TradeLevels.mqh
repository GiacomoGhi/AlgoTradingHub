class TradeLevels
{
public:
    const double _takeProfit;
    const double _stopLoss;
    const double _entryPrice;

    // Constructor
    TradeLevels(double takeProfit, double stopLoss, double entryPrice)
        : _takeProfit(takeProfit),
          _stopLoss(stopLoss),
          _entryPrice(entryPrice)
    {
    }
}