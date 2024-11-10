#include "./index.mqh";
#include <Arrays/List.mqh>

class ATHExpertAdvisor
{
private:
    SignalManager *_signalManager;
    ContextParams *_contextParams;
    TradeManager *_tradeManager;
    RiskManager *_riskManager;

public:
    // Constructor
    ATHExpertAdvisor(
        ContextParams &contextParams,
        TradeManagerParams &tradeManagerParams,
        SignalManager &signalManager)
        : _signalManager(&signalManager),
          _contextParams(&contextParams)
    {

        // Initalize trade manager
        _tradeManager = new TradeManager(
            &contextParams,
            &tradeManagerParams);
    };

    void OnTick()
    {
        /**
         * TODO
         * Use SignalManager to check what kind of signal need to be processed;
         * Execute signals returned in the BinFlags obj; use ITradeLevels Obj
         * where needed to get trading Levels such as TP and SL
         * use trade manager to execute the trades
         * */
    }
}