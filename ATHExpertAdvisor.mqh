#include "./index.mqh";
#include <Arrays/List.mqh>

// TODO decontructors everywhere!!!!
class ATHExpertAdvisor : public ITradeSignalTypeEnumHelperStrategy
{
private:
    SignalManager *_signalManager;
    ContextParams *_contextParams;
    TradeManager *_tradeManager;
    RiskManager *_riskManager;
    BinFlags *_signalsToExecute;
    ITradeLevelsIndicator *_tradeLevelsIndicator;

public:
    // Constructor
    ATHExpertAdvisor(
        ContextParams &contextParams,
        TradeManagerParams &tradeManagerParams,
        RiskManagerParams &riskManagerParams,
        SignalManagerParams &signalManagerParams)
        : _contextParams(&contextParams)
    {

        // Trade manager init
        _tradeManager = new TradeManager(
            &contextParams,
            &tradeManagerParams);

        // Risk manager init
        _riskManager = new RiskManager(
            &contextParams,
            &riskManagerParams);

        // Signal manager init
        _signalManager = new SignalManager(
            &signalManagerParams);
    };

    void OnTick()
    {
        // Gets signals that needs to be executed
        _signalsToExecute = _signalManager.GetSignalsToExecute();

        if (_signalsToExecute.Read() == 0)
        {
            return;
        }

        // Execute this.ForEachAlgorithmInterface()
        // For each value of the enum TradeSignalTypeEnum
        TradeSignalTypeEnumHelper::ForEach(&this);

        /**
         * use ITradeLevels Obj
         * where needed to get trading Levels such as TP and SL
         * use trade manager to execute the trades.
         */
    }

    /**
     * ITradeSignalTypeEnumHelperStrategy method implementation
     * Iterates over each signal type and checks if signal is to be executed.
     * @param signalType The signal type to process.
     */
    void ForEachAlgorithmInterface(int signalType)
    {
        if (_signalsToExecute.HasFlag(signalType))
        {
            // TODO
            //  Execute signals
            this.ExecuteSignal((TradeSignalTypeEnum)signalType);
        }
    }

private:
    /**
     * Execute provided signal
     */
    void ExecuteSignal(TradeSignalTypeEnum signalType)
    {
        // Prepare trade levels
        BasicList<int> openTypesValues = TradeSignalTypeEnumHelper::GetOpenTypesValues();
        TradeLevels *tradeLevels;
        if (_signalsToExecute.HasAnyFlag(&openTypesValues))
        {
            tradeLevels = _tradeLevelsIndicator.GetTradeLevels();
        }

        switch (signalType)
        {
        case OPEN_BUY_MARKET:
            /** code */
            break;

        case OPEN_BUY_LIMIT_ORDER:
            /** code */
            break;

        case OPEN_BUY_STOP_ORDER:
            /** code */
            break;

        case CLOSE_BUY_MARKET:
            /** code */
            break;

        case DELETE_BUY_ORDER:
            /** code */
            break;

        case OPEN_SELL_MARKET:
            /** code */
            break;

        case OPEN_SELL_LIMIT_ORDER:
            /** code */
            break;

        case OPEN_SELL_STOP_ORDER:
            /** code */
            break;

        case CLOSE_SELL_MARKET:
            /** code */
            break;

        case DELETE_SELL_ORDER:
            /** code */
            break;

        default:
            // TODO use logger to print "Unhadled singal error"
            break;
        }
    }
}