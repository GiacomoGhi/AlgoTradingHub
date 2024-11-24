#include "../../Shared/Models/ContextParams.mqh";
#include "./Models/RiskManagerParams.mqh";
#include <Trade/AccountInfo.mqh>
#include <Trade/SymbolInfo.mqh>

class RiskManager
{
private:
    ContextParams *_contextParams;
    RiskManagerParams *_params;
    CSymbolInfo _symbolInfo;
    CAccountInfo _accountInfo;

public:
    // Constructor
    RiskManager(ContextParams &contextParams, RiskManagerParams &riskManagerParams)
        : _contextParams(&contextParams),
          _params(&riskManagerParams)
    {
        _symbolInfo.Name(contextParams.Symbol);
    }

    // Calcualte position size based on required risk percentage
    double GetTradeVolume(double entryPrice = 0, double stopLossPrice = 0)
    {
        // TODO perform size validation before returning

        if (_params.SizeCalculationType == FIXED_LOT_SIZE)
        {
            return _params.SizeValueOrPercentage;
        }
        else if (_params.SizeCalculationType == FIXED_MONEY_AMOUNT)
        {
            // TODO implement logic
            return 0;
        }

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
            double positionRisk = _accountInfo.Balance() * (_params.SizeValueOrPercentage / 100);

            // Calculate lots using calculated profit
            double calculatedLots = round(positionRisk * _symbolInfo.LotsMax() / (-calculatedProfit * _symbolInfo.LotsStep())) * _symbolInfo.LotsStep();

            return fmin(fmax(calculatedLots, _symbolInfo.LotsMin()), _symbolInfo.LotsMax());
        }

        // TODO log an error
        return 0;
    }

    // TODO implement max daily drowdown checks.
    // TODO implement max overall drowdown checks.
    // TODO see https://www.mql5.com/en/articles/2555 for all the check that an EA must do before being published to the market
}