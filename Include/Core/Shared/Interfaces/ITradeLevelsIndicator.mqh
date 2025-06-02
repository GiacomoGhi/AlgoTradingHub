#include "../Models/TradeLevels.mqh";
#include "../Enums/TradeSignalTypeEnum.mqh";

interface ITradeLevelsIndicator
{
    /**
     * Determines the appropriate trade levels for a given trade signal.
     * @param tradeSignal The type of trade signal (e.g., market or limit order).
     * @return A TradeLevels object containing the trade levels for the signal.
     */
    TradeLevels *GetTradeLevels(TradeSignalTypeEnum tradeSignal);
}