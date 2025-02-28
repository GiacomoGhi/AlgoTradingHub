enum TimeIndicatorSignalsEnum
{
    // Current hour equal to open trade hour
    CURRENT_HOUR_IS_OPEN_HOUR,

    // Current hour equals to close trade hour
    CURRENT_HOUR_IS_CLOSE_HOUR,

    // Range start hour <= Current time < Range end hour
    CURRENT_TIME_IS_IN_TIME_RANGE,

    // Range start day <= Current time < Range end day
    CURRENT_TIME_IS_IN_DAY_RANGE,

    // Current day equal to end day
    CURRENT_DAY_IS_END_DAY,

    // Current day equal to start day
    CURRENT_DAY_IS_START_DAY,

    // Current day not equal to end day
    CURRENT_DAY_IS_NOT_END_DAY,

    // Current day not equal to start day
    CURRENT_DAY_IS_NOT_START_DAY,
};