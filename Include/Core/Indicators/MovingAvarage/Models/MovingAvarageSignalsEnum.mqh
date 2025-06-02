enum MovingAvarageSignalsEnum
{
    // Price close is above the moving avarage
    PRICE_CLOSE_ABOVE,

    // Price close is below the moving avarage
    PRICE_CLOSE_BELOW,

    // Price previous close was below and price current close ss below
    PRICE_UPWARD_CROSS,

    // Price previous close was above and price current close is below
    PRICE_DOWNWARD_CROSS,

    // Moving avarage is in upward direction
    UPWARD_DIRECTION,

    // Moving avarage is in downward direction
    DOWNWARD_DIRECTION,

    // Moving avarage turned from downward to an upward direction
    UPWARD_TURNAROUND,

    // Moving avarage turned from upward to a downward direction
    DOWNWARD_TURNAROUND,
};