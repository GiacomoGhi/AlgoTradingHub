#include "./Models/SignalManagerParams.mqh";
#include "../../Shared/Helpers/TradeSignalTypeEnumHelper.mqh";

class SignalManager : public ITradeSignalTypeEnumHelperStrategy
{
private:
    ObjectList<ITradeSignal> *_tradeSignalsList;
    BinFlags _binFlags;

public:
    /**
     * Constructor
     * @param signalManagerParams Parameters containing the trade signals list.
     */
    SignalManager(SignalManagerParams &signalManagerParams)
        : _tradeSignalsList(signalManagerParams.TradeSignalsList)
        :
    {
    }

    /**
     * Checks indicators and returns the trading signals to execute.
     * @return Pointer to BinFlags containing the signals to execute.
     */
    BinFlags *GetSignalsToExecute()
    {
        // Clear previous flags
        _binFlags.Clear();
        
        // Execute this.ForEachAlgorithmInterface()
        // For each value of the enum TradeSignalTypeEnum
        TradeSignalTypeEnumHelper::ForEach(&this);
        
        return &_binFlags;
    }

    /**
     * ITradeSignalTypeEnumHelperStrategy method implementation
     * Iterates over each signal type and sets the corresponding flag if valid.
     * @param signalType The signal type to process.
     */
    void ForEachAlgorithmInterface(int signalType)
    {
        if (this.IsValidSignal((TradeSignalTypeEnum)signalType))
        {
            _binFlags.SetFlag(signalType);
        }
    }    

private:
    /**
     * Validates a signal based on the indicators in the trade signals list.
     * @param signalType The signal type to validate.
     * @return True if the signal is valid, false otherwise.
     */
    bool IsValidSignal(TradeSignalTypeEnum signalType)
    {
        int validatedSignals = 0;
        int totalTradeSignalsToCheck = _tradeSignalsList.Count();
        for (int i = 0; i < _tradeSignalsList.Count(); i++)
        {
            ITradeSignal *tradeSignal = _tradeSignalsList[i];
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
                totalTradeSignalsToCheck--;
            }
        }
        
        // Signal is valid if at least one is validated, and all required signals are checked
        return (validatedSignals > 0 && validatedSignals == totalTradeSignalsToCheck);
    };
};