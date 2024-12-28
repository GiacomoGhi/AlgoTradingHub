#include <Generic\HashMap.mqh>;
#include "../Enums/TradeSignalTypeEnum.mqh";

interface ITradeSignalProvider
{
    /**
     * Adds or update signal entry in signal store
     */
    void UpdateSignalStore(CHashMap<TradeSignalTypeEnum, bool> & signalsStore);
}