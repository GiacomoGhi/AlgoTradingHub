#include "./index.mqh";
#include <Arrays/List.mqh>

class ATHExpertAdvisor
{
  private:
    TradeSignalList *_signalList;
    ContextParams *_contextParams;
    TradeManager *_tradeManager;
    RiskManager *_riskManager;

  public:
    // Constructor
    ATHExpertAdvisor(
        ContextParams &contextParams,
        TradeManagerParams &tradeManagerParams,
        TradeSignalList &signalList)
        : _signalList(&signalList),
          _contextParams(&contextParams)
    {

        // Initalize trade manager
        _tradeManager = new TradeManager(
            &contextParams,
            &tradeManagerParams);
    };

    void OnTick()
    {
        // TODO move this to Signal manager
        if (_signalList.IsValidSignal(BUY_SIGNAL))
        {
            // Use trade manager class to open a buy trade or to place a buy stop/limit order
            // _tradeManager.Execute(
            //     BUY_POSITION,
            //     _riskManager.get);
        }

        if (_signalList.IsValidSignal(SELL_SIGNAL))
        {
            // Use trade manager class to open a sell trade or to place a sell stop/limit order
        }

        if (_signalList.IsValidSignal(CLOSE_BUY_SIGNAL))
        {
            // Use trade manager class to close buy trade
        }

        if (_signalList.IsValidSignal(CLOSE_SELL_SIGNAL))
        {
            // Use trade manager class to close sell trade
        }
    }
}