class TradeLevels
{
  private:
    double _takeProfit;
    double _stopLoss;
    double _entryPrice;

  public:
    // Constructor
    TradeLevels(double takeProfit, double stopLoss, double entryPrice)
        : _takeProfit(takeProfit),
          _stopLoss(stopLoss),
          _entryPrice(entryPrice)
    {
    }

    // Getter methods
    double GetTakeProfit()
    {
        return _takeProfit;
    }

    double GetStopLoss()
    {
        return _stopLoss;
    }

    double GetEntryPrice()
    {
        return _entryPrice;
    }
}