enum SizeCalculationTypeEnum
{
    /**
     * Use the same size for every trade.
     */
    FIXED_LOT_SIZE,

    /**
     * Calculate lot size based on the monetary amount to risk.
     */
    FIXED_MONEY_AMOUNT,

    /**
     * Calculate lot size to risk the requested balance percentage.
     */
    BALANCE_PERCENTAGE,

    /**
     * Calculate lot size based on the account balance.
     it will open x lots for each x amount of money in the account.
     E.g. Balance = 1000, size value = 500; Lot size will be 2 (1000/500).
     */
    ONE_LOT_EVERY,

    /**
     * Always match opposite direction volume of open trades.
     * It is used to enter and edged state.
     * Note that size value or percentage value will be ignored.
     */
    MATCH_OPPOSITE_DIRECTION_VOLUME,

    /**
     * Calculate position size based on price.
     * For long trades: the lower the price, the bigger the lot size.
     * For short trades: the higher the price, the bigger the lot size.
     * Total openable positions size is fixed.
     */
    PRICE_BASED_SIZE_FIXED,

    /**
     * Calculate position size based on price.
     * For long trades: the lower the price, the bigger the lot size.
     * For short trades: the higher the price, the bigger the lot size.
     * Total openable positions size is progressive (one lot every).
     */
    PRICE_BASED_SIZE_PROGRESSIVE,
}