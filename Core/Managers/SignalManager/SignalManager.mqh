#include "./Models/SignalManagerParams.mqh";
#include "../../Shared/Helpers/TradeSignalTypeEnumHelper.mqh";

class SignalManager : public ITradeSignalTypeEnumHelperStrategy
{
private:
    ObjectList<ITradeSignal> *_tradeSignalProviders;
    BasicList<int> *_signalsToExecute;

public:
    /**
     * Constructor
     * @param signalManagerParams Parameters containing the trade signals list.
     */
    SignalManager(SignalManagerParams &signalManagerParams)
        : _tradeSignalProviders(signalManagerParams.TradeSignalProviders)
    {
    }

    /**
     * Checks indicators and updates by reference the received singals list.
     */
    void GetSignalsToExecute(BasicList<int> &receivedSignalsToExecute)
    {
        // Clear previous signals
        _signalsToExecute.RemoveAll();
        receivedSignalsToExecute.RemoveAll();

        // Set internal list pointer to received list
        _signalsToExecute = &receivedSignalsToExecute;

        // Execute this.ForEachAlgorithmInterface()
        // For each value of the enum TradeSignalTypeEnum
        TradeSignalTypeEnumHelper::ForEach(&this);

        return;
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
        int totalTradeSignalsToCheck = _tradeSignalProviders.Count();

        // Valodate signal for each signal provider
        for (int i = 0; i < _tradeSignalProviders.Count(); i++)
        {
            ITradeSignal *tradeSignal = _tradeSignalProviders[i];
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