#include "../../../Shared/Interfaces/ITradeSignal.mqh";
#include "../../../Libraries/List/ObjectList.mqh";

class SignalManagerParams
{
public:
    ObjectList<ITradeSignal> *TradeSignalsList;

    // Constructor
    SignalManagerParams(ObjectList<ITradeSignal> &tradeSignalList)
        : TradeSignalsList(&tradeSignalList) {}
}