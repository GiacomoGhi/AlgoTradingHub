#include "../../../Shared/Interfaces/ITradeSignal.mqh";
#include "../../../Libraries/List/ObjectList.mqh";

class SignalManagerParams
{
public:
    ObjectList<ITradeSignal> *TradeSignalsList;
    const ulong MagicNumber;
    const bool AllowMultiplePositions;

    // Constructor
    SignalManagerParams(
        ObjectList<ITradeSignal> &tradeSignalList,
        ulong magicNumber,
        bool allowMultiplePositions = false)
        : TradeSignalsList(&tradeSignalList),
          MagicNumber(magicNumber),
          AllowMultiplePositions(allowMultiplePositions) {}
}