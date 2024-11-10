#include "./Models/SignalManagerParams.mqh";

class SignalManager
{
private:
    ObjectList<ITradeSignal> *_tradeSingalsList;

public:
    // Constructor
    SignalManager(SignalManagerParams &signalManagerParams)
        : _tradeSingalsList(signalManagerParams.TradeSignalsList)
    {
    }

    // Checks indicators and return trading signals to execute.
    BinFlags *GetSignalsToExecute()
    {
        BinFlags binFlags = new BinFlags();
        for (int signalType = TradeSignalTypeEnum::OPEN_BUY_MARKET;
             signalType <= TradeSignalTypeEnum::DELETE_SELL_ORDER;
             signalType *= 2)
        {
            if (this.IsValidSignal((TradeSignalTypeEnum)signalType))
            {
                binFlags.SetFlag(signalType);
            }
        }

        return &binFlags;
    }

private:
    /**
     * Retruns true if checked indicators are at least one and the amount of
     * checked indicators is equal to the amount of indicators that were set to produce
     * the provided signal
     * */
    bool IsValidSignal(TradeSignalTypeEnum signalType)
    {
        int validatedSignals = 0;
        int totalTradeSinglasToCheck = _tradeSingalsList.Count();
        for (int i = 0; i < _tradeSingalsList.Count(); i++)
        {
            ITradeSignal *tradeSignal = _tradeSingalsList[i];
            if (tradeSignal.ProduceSignal(signalType))
            {
                if (tradeSignal.IsValidSignal(signalType))
                {
                    validatedSignals++;
                }
            }
            else
            {
                // Reduce the amount of valid trade signals
                totalTradeSinglasToCheck--;
            }
        }
        return (validatedSignals > 0 && validatedSignals == totalTradeSinglasToCheck);
    };
};