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
        SignalManagerParams &signalManagerParams,
        ITradeLevelsIndicator &tradeLevelsIndicator)
        : _tradeLevelsIndicator(&tradeLevelsIndicator)
    {
        // Trade manager
        _tradeManager = new TradeManager(
            &contextParams,
            &tradeManagerParams,
            &riskManagerParams);

        // Signal manager
        _signalManager = new SignalManager(
            &signalManagerParams);

        // signals to execute list
        _signalsToExecute = new BasicList<int>();
    };

    void OnTick()
    {
        // Gets signals that needs to be executed
        _signalManager.GetSignalsToExecute(&_signalsToExecute);

        if (_signalsToExecute.Count() == 0)
        {
            return;
        }

        // Execute close and delete signals
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

        // Exit if empty
        if (_signalsToExecute.Count() == 0)
        {
            return;
        }

        // Execute open trades signals
        for (int i = 0; i < _signalsToExecute.Count(); i++)
        {
            // Cast
            TradeSignalTypeEnum tradeSignal = (TradeSignalTypeEnum)_signalsToExecute.Get(i);

            // Execute signal
            _tradeManager.Execute(
                tradeSignal,
                _tradeLevelsIndicator
                    .GetTradeLevels(tradeSignal));
        }
    }
}