#include "./TradeSignalTypeEnum.mqh";

interface ITradeSignal
{
    bool IsValidSignal(TradeSignalTypeEnum signalType);
}