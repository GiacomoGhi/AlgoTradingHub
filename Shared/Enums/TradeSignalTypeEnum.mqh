/**
 * Represents trading signals for different order types.
 * Use power of 2 enum for byte flags operations.
 * See:
 *    ¬/AlgoTradingHub/Libraries/BinFlag/BinFlag.mqh
 */
enum TradeSignalTypeEnum
{
    /**
     * No signals
     */
    NONE = 0,

    /**
     * Open a buy position at the current market price
     */
    OPEN_BUY_MARKET = 0x1,

    /**
     * Open a buy limit order
     */
    OPEN_BUY_LIMIT_ORDER = 0x2,

    /**
     * Open a buy stop order
     */
    OPEN_BUY_STOP_ORDER = 0x3,

    /**
     * Close an open buy position at the current market price
     */
    CLOSE_BUY_MARKET = 0x4,

    /**
     * Delete a pending buy order
     */
    DELETE_BUY_ORDER = 0x5,

    /**
     * Open a sell position at the current market price
     */
    OPEN_SELL_MARKET = 0x6,

    /**
     * Open a sell limit order
     */
    OPEN_SELL_LIMIT_ORDER = 0x7,

    /**
     * Open a sell stop order
     */
    OPEN_SELL_STOP_ORDER = 0x8,

    /**
     * Close an open sell position at the current market price
     */
    CLOSE_SELL_MARKET = 0x9,

    /**
     * Delete a pending sell order
     */
    DELETE_SELL_ORDER = 0x10,
};