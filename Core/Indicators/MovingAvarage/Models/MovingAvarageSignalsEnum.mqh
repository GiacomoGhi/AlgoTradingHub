enum MovingAvarageSignalsEnum
{
    // Default value that returns true signal,
    // it is used to ignore this indicator during signal analysis.
    AlwaysTrue,

    // Price close is above the moving avarage
    CloseAbove,

    // Price close is below the moving avarage
    CloseBelow,

    // Price previous close was below and price current close ss below
    PriceUpwardCross,

    // Price previous close was above and price current close is below
    PriceDownwardCross,

    // Moving avarage is in upward direction
    UpwardDirection,

    // Moving avarage is in downward direction
    DownwardDirection,

    // Moving avarage turned from downward to an upward direction
    UpwardTurnAround,

    // Moving avarage turned from upward to a downward direction
    DownwardTurnAround,
};