#include "../../Shared/Models/ContextParams.mqh";
#include "./Models/RiskManagerParams.mqh";
#include <Trade/AccountInfo.mqh>
#include <Trade/SymbolInfo.mqh>

class RiskManager
{
  private:
    ContextParams *_contextParams;
    double _sizeValueOrPercentage;
    double _maxDailyDrawDownPercentage;
    double _maxOverallDrawDown;
    CSymbolInfo _symbolInfo;
    CAccountInfo _accountInfo;

  public:
    // Constructor
    RiskManager(ContextParams &contextParams, RiskManagerParams &riskManagerParams)
        : _contextParams(&contextParams),
          _sizeValueOrPercentage(riskManagerParams.SizeValueOrPercentage),
          _maxDailyDrawDownPercentage(riskManagerParams.MaxDailyDrawDownPercentage),
          _maxOverallDrawDown(riskManagerParams.MaxOverallDrawDown)
    {
        _symbolInfo.Name(contextParams.Symbol);
    }

    // Return fixed position size
    double GetPositionSize()
    {
        return _sizeValueOrPercentage;
    }

    // Calcualte position size based on required risk percentage
    double GetPositionSize(double entryPrice, double stopLossPrice)
    {
        double stopSize = MathAbs(entryPrice - stopLossPrice);

        double calculatedProfit = 0;
        if (OrderCalcProfit(
                ORDER_TYPE_BUY,
                _contextParams.Symbol,
                _symbolInfo.LotsMax(),
                entryPrice,
                stopLossPrice,
                calculatedProfit))
        {
            // Calculate position risk based on balance and risk percentage
            double positionRisk = _accountInfo.Balance() * (_sizeValueOrPercentage / 100);

            // Calculate lots using calculated profit
            double calculatedLots = round(positionRisk * _symbolInfo.LotsMax() / (-calculatedProfit * _symbolInfo.LotsStep())) * _symbolInfo.LotsStep();

            return fmin(fmax(calculatedLots, _symbolInfo.LotsMin()), _symbolInfo.LotsMax());
        }

        // TODO log an error
        return 0;
    }
}