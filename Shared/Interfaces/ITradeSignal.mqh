#include "../Enums/TradeSignalTypeEnum.mqh";

interface ITradeSignal
{
    /**
     * Checks if indicator is set to produce given signal
     */
    bool ProduceSignal(TradeSignalTypeEnum signalType);

    /**
     * Validate if indicators has a signal for the given signal type
     */
    bool IsValidSignal(TradeSignalTypeEnum signalType);
}