#include "./index.mqh";

class ATHExpertAdvisor
{
public:
    /**
     * Flags to check after object init. Is false in case of invalid input params.
     */
    bool IsInitCompleted;

private:
    /**
     * Logger.
     */
    Logger *_logger;

    /**
     * Context params.
     */
    ContextParams *_contextParams;

    /**
     * Risk manager.
     */
    RiskManager *_riskManager;

    /**
     * Signal manager.
     */
    SignalManager *_signalManager;

    /**
     * Trade manager.
     */
    TradeManager *_tradeManager;

    /**
     * Trade levels.
     */
    ITradeLevelsIndicator *_tradeLevelsIndicator;

    /**
     * Signals to execute list.
     */
    BasicList<TradeSignalTypeEnum> *_signalsToExecute;

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
        ITradeLevelsIndicator &tradeLevelsIndicator)
        : _logger(&logger),
          _contextParams(&contextParams),
          _tradeLevelsIndicator(&tradeLevelsIndicator)
    {
        IsInitCompleted = true;

        // Risk manager
        _riskManager = new RiskManager(
            &logger,
            &contextParams,
            &riskManagerParams);
        IsInitCompleted &= _riskManager.IsInitCompleted;

        // Trade manager
        _tradeManager = new TradeManager(
            &logger,
            &contextParams,
            &tradeManagerParams,
            _riskManager);

        // Signal manager
        _signalManager = new SignalManager(
            &logger,
            &signalManagerParams);

        // signals to execute list
        _signalsToExecute = new BasicList<TradeSignalTypeEnum>();

        _logger.LogInitCompleted(__FUNCTION__);
    };

    /**
     * Deconstructor
     */
    ~ATHExpertAdvisor()
    {
        // Risk manager
        delete _riskManager;

        // Trade manager
        delete _tradeManager;

        // Signal manager
        delete _signalManager;

        // Trade levels indicator
        delete _tradeLevelsIndicator;

        // signals to execute list
        delete _signalsToExecute;

        // Context params
        delete _contextParams;

        // Logger
        delete _logger;
    }

    /**
     * ATH EA OnTick implementation.
     */
    void OnTick()
    {
        // Check drawdown limits
        if (_riskManager.IsDrawdownLimitExceeded())
        {
            // Void every trade
            _tradeManager.PositionCloseAll();
            _tradeManager.OrderDeleteAll();

            return;
        }

        // Delete trades that failed to be deleted
        _tradeManager.CompleteTradeVoidance();

        //  Update positions levels
        _tradeManager.UpdatePositionLevels();

        // Gets signals that needs to be executed
        _signalManager.GetSignalsToExecute(_signalsToExecute);

        if (_signalsToExecute.Count() == 0)
        {
            return;
        }

        // Execute close and delete signals
        // Close buy position
        if (_signalsToExecute.Contains(CLOSE_BUY_MARKET))
        {
            _tradeManager.Execute(CLOSE_BUY_MARKET);
            _signalsToExecute.Remove(CLOSE_BUY_MARKET);
        }

        // Delete buy limit order
        if (_signalsToExecute.Contains(DELETE_BUY_LIMIT_ORDER))
        {
            _tradeManager.Execute(DELETE_BUY_LIMIT_ORDER);
            _signalsToExecute.Remove(DELETE_BUY_LIMIT_ORDER);
        }

        // Delete buy stop order
        if (_signalsToExecute.Contains(DELETE_BUY_STOP_ORDER))
        {
            _tradeManager.Execute(DELETE_BUY_STOP_ORDER);
            _signalsToExecute.Remove(DELETE_BUY_STOP_ORDER);
        }

        // Close sell position
        if (_signalsToExecute.Contains(CLOSE_SELL_MARKET))
        {
            _tradeManager.Execute(CLOSE_SELL_MARKET);
            _signalsToExecute.Remove(CLOSE_SELL_MARKET);
        }

        // Delete sell limit order
        if (_signalsToExecute.Contains(DELETE_SELL_LIMIT_ORDER))
        {
            _tradeManager.Execute(DELETE_SELL_LIMIT_ORDER);
            _signalsToExecute.Remove(DELETE_SELL_LIMIT_ORDER);
        }

        // Delete sell stop order
        if (_signalsToExecute.Contains(DELETE_SELL_STOP_ORDER))
        {
            _tradeManager.Execute(DELETE_SELL_STOP_ORDER);
            _signalsToExecute.Remove(DELETE_SELL_STOP_ORDER);
        }

        // Exit if empty
        if (_signalsToExecute.Count() == 0)
        {
            return;
        }

        // Execute open trades signals
        for (int i = 0; i < _signalsToExecute.Count(); i++)
        {
            // Get trade signal
            TradeSignalTypeEnum tradeSignal = _signalsToExecute.Get(i);

            // Get trade levels
            TradeLevels *tradeLevels = _tradeLevelsIndicator
                                           .GetTradeLevels(tradeSignal);

            // Execute signal
            _tradeManager.Execute(
                tradeSignal,
                tradeLevels);

            delete tradeLevels;
        }
    }
}