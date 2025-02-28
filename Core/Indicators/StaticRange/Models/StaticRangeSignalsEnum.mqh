enum StaticRangeSignalsEnum
{
    // Current price is above max price
    PRICE_ABOVE_MAX_PRICE,

    // Current price is below max price
    PRICE_BELOW_MAX_PRICE,

    // Current price is above min price
    PRICE_ABOVE_MIN_PRICE,

    // Current price is below min price
    PRICE_BELOW_MIN_PRICE,

    // Current price is above sum of max price and price delta points
    PRICE_ABOVE_MAX_PRICE_PLUS_DELTA,

    // Current price is below sum of max price and price delta points
    PRICE_BELOW_MAX_PRICE_PLUS_DELTA,

    // Current price is over previous position delta
    OVER_PREVIOUS_POSITION_DELTA,

    // Current price is under previous position delta
    UNDER_PREVIOUS_POSITION_DELTA,

    // Current price is over previous buy position delta of the same side
    OVER_PREVIOUS_BUY_POSITION_DELTA,

    // Current price is over previous sell position delta of the same side
    OVER_PREVIOUS_SELL_POSITION_DELTA,

    // Current price is under previous buy position delta of the same side
    UNDER_PREVIOUS_BUY_POSITION_DELTA,

    // Current price is under previous buy position delta of the same side
    UNDER_PREVIOUS_SELL_POSITION_DELTA,
}