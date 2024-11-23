#include "./index.mqh";

// TODO decontructors everywhere!!!!
class ATHExpertAdvisor
{
private:
    ContextParams *_contextParams;
    SignalManager *_signalManager;
    TradeManager *_tradeManager;
    ITradeLevelsIndicator *_tradeLevelsIndicator;

public:
    // Constructor
    ATHExpertAdvisor(
        ContextParams &contextParams,
        TradeManagerParams &tradeManagerParams,
        SignalManagerParams &signalManagerParams)
        : _contextParams(&contextParams)
    {
        // Trade manager
        _tradeManager = new TradeManager(
            &contextParams,
            &tradeManagerParams);

        // Signal manager
        _signalManager = new SignalManager(
            &signalManagerParams);
    };

    void OnTick()
    {
        this.ExecuteSignals();

        /**
         * use ITradeLevels Obj
         * where needed to get trading Levels such as TP and SL
         * use trade manager to execute the trades.
         */
    }

private:
    /**
     * Gets and execute signals from signal manager
     */
    void ExecuteSignals()
    {
        // Gets signals that needs to be executed
        BasicList<int> *signalsToExecute = _signalManager.GetSignalsToExecute();

        if (signalsToExecute.Count() == 0)
        {
            return;
        }

        // First thing first, close trades or delete open orders
        if (signalsToExecute.Contains(CLOSE_BUY_MARKET))
        {
            _tradeManager.Execute(CLOSE_BUY_MARKET);
            signalsToExecute.Remove(CLOSE_BUY_MARKET);
        }

        if (signalsToExecute.Contains(DELETE_BUY_ORDER))
        {
            _tradeManager.Execute(DELETE_BUY_ORDER);
            signalsToExecute.Remove(CLOSE_BUY_MARKET);
        }

        if (signalsToExecute.Contains(CLOSE_SELL_MARKET))
        {
            _tradeManager.Execute(CLOSE_SELL_MARKET);
            signalsToExecute.Remove(CLOSE_BUY_MARKET);
        }

        if (signalsToExecute.Contains(DELETE_SELL_ORDER))
        {
            _tradeManager.Execute(DELETE_SELL_ORDER);
            signalsToExecute.Remove(CLOSE_BUY_MARKET);
        }

        // All close and delete type signals have been executed,
        // Check if there are any open type signal yet to execute
        if (signalsToExecute.Count() == 0)
        {
            return;
        }

        // TODO this should be moved inside the for loop
        // TODO trade levels should be get based on TradeSignalTypeEnum
        TradeLevels *tradeLevels = _tradeLevelsIndicator.GetTradeLevels();

        for (int i = 0; i < signalsToExecute.Count(); i++)
        {
            _tradeManager.Execute(
                (TradeSignalTypeEnum)signalsToExecute.Get(i),
                tradeLevels);
        }
    }
}