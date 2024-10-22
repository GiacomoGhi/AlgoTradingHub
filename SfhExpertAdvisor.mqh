#include "./index.mqh";
#include <Arrays/List.mqh>

class SfhExpertAdvisor
{
  private:
    TradeSignalList *_signalList;
    ContextParams *_contextParams;
    TradeManager *_tradeManager;

  public:
    // Constructor
    SfhExpertAdvisor(
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

        // Initialize risk manager
        // TODO
    };

    void OnTick()
    {
        if (_signalList.IsValidSignal(BuySignal))
        {
            // Use trade manager class to open a buy trade or to place a buy stop/limit order
        }

        if (_signalList.IsValidSignal(SellSignal))
        {
            // Use trade manager class to open a sell trade or to place a sell stop/limit order
        }

        if (_signalList.IsValidSignal(CloseBuySignal))
        {
            // Use trade manager class to close buy trade
        }

        if (_signalList.IsValidSignal(CloseSellSignal))
        {
            // Use trade manager class to close sell trade
        }
    }
}