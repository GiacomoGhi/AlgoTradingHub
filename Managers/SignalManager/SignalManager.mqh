#include "../../Indicators/BaseModels/TradeSignalList.mqh";

class SignalManager
{
  private:
    TradeSignalList *_signalList;

  public:
    // Constructor
    SignalManager(TradeSignalList &signalList)
        : _signalList(&signalList)
    {
    }
    // TODO implement
}