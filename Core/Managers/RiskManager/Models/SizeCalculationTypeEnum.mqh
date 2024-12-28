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
}