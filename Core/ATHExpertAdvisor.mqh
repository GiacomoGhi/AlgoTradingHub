#include "./index.mqh";

// TODO decontructors everywhere!!!!
class ATHExpertAdvisor
{
private:
    SignalManager *_signalManager;
    TradeManager *_tradeManager;
    ITradeLevelsIndicator *_tradeLevelsIndicator;
    BasicList<int> _signalsToExecute;

public:
    // Constructor
    ATHExpertAdvisor(
        ContextParams &contextParams,
        TradeManagerParams &tradeManagerParams,
        RiskManagerParams &riskManagerParams,
        SignalManagerParams &signalManagerParams)
    // ITradeLevelsIndicator &tradeLevelsIndicator)
    // : _tradeLevelsIndicator(&tradeLevelsIndicator)
    {
        // Trade manager
        _tradeManager = new TradeManager(
            &contextParams,
            &tradeManagerParams,
            &riskManagerParams);

        // Signal manager
        _signalManager = new SignalManager(
            &signalManagerParams);
    };

    void OnTick()
    {
        this.ExecuteSignals();
    }

private:
    /**
     * Gets and execute signals from signal manager
     */
    void ExecuteSignals()
    {
        // Gets signals that needs to be executed
        _signalManager.GetSignalsToExecute(&_signalsToExecute);

        if (_signalsToExecute.Count() == 0)
        {
            return;
        }

        // First thing first, close trades or delete open orders
        if (_signalsToExecute.Contains(CLOSE_BUY_MARKET))
        {
            _tradeManager.Execute(CLOSE_BUY_MARKET);
            _signalsToExecute.Remove(CLOSE_BUY_MARKET);
        }

        if (_signalsToExecute.Contains(DELETE_BUY_ORDER))
        {
            _tradeManager.Execute(DELETE_BUY_ORDER);
            _signalsToExecute.Remove(CLOSE_BUY_MARKET);
        }

        if (_signalsToExecute.Contains(CLOSE_SELL_MARKET))
        {
            _tradeManager.Execute(CLOSE_SELL_MARKET);
            _signalsToExecute.Remove(CLOSE_BUY_MARKET);
        }

        if (_signalsToExecute.Contains(DELETE_SELL_ORDER))
        {
            _tradeManager.Execute(DELETE_SELL_ORDER);
            _signalsToExecute.Remove(CLOSE_BUY_MARKET);
        }

        // All close and delete type signals have been executed,
        // Check if there are any open type signal yet to execute
        if (_signalsToExecute.Count() == 0)
        {
            return;
        }

        // TODO this should be moved inside the for loop
        // TODO trade levels should be get based on TradeSignalTypeEnum
        TradeLevels *tradeLevels = _tradeLevelsIndicator.GetTradeLevels();

        for (int i = 0; i < _signalsToExecute.Count(); i++)
        {
            _tradeManager.Execute(
                (TradeSignalTypeEnum)_signalsToExecute.Get(i),
                tradeLevels);
        }
    }
}