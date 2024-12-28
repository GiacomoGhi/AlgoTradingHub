#include "./index.mqh";

// TODO decontructors everywhere!!!!
class ATHExpertAdvisor
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
     * Signal manager object.
     */
    SignalManager *_signalManager;

    /**
     * Trade manager object.
     */
    TradeManager *_tradeManager;

    /**
     * Trade levels object.
     */
    ITradeLevelsIndicator *_tradeLevelsIndicator;

    /**
     * Signals to execute list.
     */
    BasicList<TradeSignalTypeEnum> _signalsToExecute;

public:
    /**
     * Constructor
     */
    ATHExpertAdvisor(
        Logger &logger,
        ContextParams &contextParams,
        TradeManagerParams &tradeManagerParams,
        RiskManagerParams &riskManagerParams,
        SignalManagerParams &signalManagerParams,
        ITradeLevelsIndicator &tradeLevelsIndicator,
        string className = "ATHExpertAdvisor")
        : _className(className),
          _logger(&logger),
          _tradeLevelsIndicator(&tradeLevelsIndicator)
    {
        // Trade manager
        _tradeManager = new TradeManager(
            &logger,
            &contextParams,
            &tradeManagerParams,
            &riskManagerParams);

        // Signal manager
        _signalManager = new SignalManager(
            &logger,
            &signalManagerParams);

        // signals to execute list
        _signalsToExecute = new BasicList<TradeSignalTypeEnum>();

        _logger.LogInitCompleted(_className);
    };

    /**
     * ATH EA OnTick implementation.
     */
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
            TradeSignalTypeEnum tradeSignal = _signalsToExecute.Get(i);

            // Execute signal
            _tradeManager.Execute(
                tradeSignal,
                _tradeLevelsIndicator
                    .GetTradeLevels(tradeSignal));
        }
    }
}