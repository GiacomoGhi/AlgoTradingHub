#include "../../../Shared/Interfaces/ITradeSignal.mqh";
#include "../../../Libraries/List/ObjectList.mqh";

class SignalManagerParams
{
public:
    ObjectList<ITradeSignal> *TradeSignalProviders;

    // Constructor
    SignalManagerParams(ObjectList<ITradeSignal> &tradeSignalList)
        : TradeSignalProviders(&tradeSignalList) {}
}