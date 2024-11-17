#include "./Models/SignalManagerParams.mqh";
#include "../../Shared/Helpers/TradeSignalTypeEnumHelper.mqh";

class SignalManager : public ITradeSignalTypeEnumHelperStrategy
{
private:
    ObjectList<ITradeSignal> *_tradeSignalsList;
    BasicList<int> _signalsToExecute;

public:
    /**
     * Constructor
     * @param signalManagerParams Parameters containing the trade signals list.
     */
    SignalManager(SignalManagerParams &signalManagerParams)
        : _tradeSignalsList(signalManagerParams.TradeSignalsList)
    {
    }

    /**
     * Checks indicators and returns the trading signals to execute.
     * @return Pointer to BinFlags containing the signals to execute.
     */
    BasicList<int> *GetSignalsToExecute()
    {
        // Clear previous signals
        _signalsToExecute.RemoveAll();

        // Execute this.ForEachAlgorithmInterface()
        // For each value of the enum TradeSignalTypeEnum
        TradeSignalTypeEnumHelper::ForEach(&this);

        return &_signalsToExecute;
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
            _signalsToExecute.Append(signalType);
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
        // Validated singals counter
        int validatedSignals = 0;

        // Total amount of singals that needs to be valid
        int totalTradeSignalsToCheck = _tradeSignalsList.Count();

        // Valodate signal for each signal provider
        for (int i = 0; i < _tradeSignalsList.Count(); i++)
        {
            ITradeSignal *tradeSignal = _tradeSignalsList[i];
            if (!tradeSignal.ProduceSignal(signalType))
            {
                // Reduce the amount of trade signals that needs to be valid
                totalTradeSignalsToCheck--;
                continue;
            }

            if (tradeSignal.IsValidSignal(signalType))
            {
                validatedSignals++;
            }
        }

        // Signal is valid if at least one is validated, and all required signals are checked
        return (validatedSignals > 0 && validatedSignals == totalTradeSignalsToCheck);
    };
};