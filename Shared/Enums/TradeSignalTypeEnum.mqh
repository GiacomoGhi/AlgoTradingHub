enum TradeSignalTypeEnum
{
    // Buy signal
    BUY_SIGNAL = 0x1,

    // Close buy signal
    CLOSE_BUY_SIGNAL = 0x2,

    // Sell signal
    SELL_SIGNAL = 0x3,

    // Close sell signal
    CLOSE_SELL_SIGNAL = 0x4,
};

/*
Power of 2 enum for byte flags operations.
See:
   ¬/AlgoTradingHub/Libraries/BinFlag/BinFlag.mqh
*/