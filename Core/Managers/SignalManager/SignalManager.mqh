#include <Generic\HashMap.mqh>;

#include "./Models/SignalManagerParams.mqh";
#include "../../Shared/Enums/TradeSignalTypeEnum.mqh";
#include "../../Shared/Logger/Logger.mqh";

class SignalManager
{
private:
    /**
     * Name of the class.
     */
    const string _className;

    /**
     * Logger.
     */
    Logger *_logger;

    /**
     * List of signal providers objects.
     */
    ObjectList<ITradeSignalProvider> *_tradeSignalProviders;

    /**
     * Store of signals type and boolean flag, if true the signal will be executed.
     */
    CHashMap<TradeSignalTypeEnum, bool> *_signalsStore;

public:
    /**
     * Constructor
     */
    SignalManager(
        Logger &logger,
        SignalManagerParams &signalManagerParams,
        string className = "SignalManager")
        : _className(className),
          _logger(&logger),
          _tradeSignalProviders(signalManagerParams.TradeSignalProviders),
          _signalsStore(new CHashMap<TradeSignalTypeEnum, bool>)
    {
        // Delte dto
        delete &signalManagerParams;

        _logger.LogInitCompleted(_className);
    }

    /**
     * Deconstructor
     */
    ~SignalManager()
    {
        // Trade signal providers
        delete _tradeSignalProviders;

        // Signals store
        delete _signalsStore;
    }

    /**
     * Checks indicators and store signals to execute in the provided list overwriting previous content.
     */
    void GetSignalsToExecute(BasicList<TradeSignalTypeEnum> &signalsToExecute)
    {
        // Clear previous signals
        signalsToExecute.RemoveAll();
        _signalsStore.Clear();

        // Use all signal providers to update signal store
        for (int i = 0; i < _tradeSignalProviders.Count(); i++)
        {
            _tradeSignalProviders[i].UpdateSignalStore(_signalsStore);
        }

        // Copy store to array to allow looping
        CKeyValuePair<TradeSignalTypeEnum, bool> *signalsStoreArray[];
        if (_signalsStore.CopyTo(signalsStoreArray) == 0)
        {
            return;
        }

        // string infoLogString = "Signals to execute: ";
        for (int i = 0; i < ArraySize(signalsStoreArray); i++)
        {
            // Store signal as to execute if value in store is true.
            if (signalsStoreArray[i].Value())
            {
                // Variable for readability
                TradeSignalTypeEnum signal = signalsStoreArray[i].Key();

                // Add signal to execute
                signalsToExecute.Append(signal);
            }

            // Delete dto
            delete signalsStoreArray[i];
        }

        // Free array
        ArrayFree(signalsStoreArray);

        return;
    }
};