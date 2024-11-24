enum TimeIndicatorSignalsEnum
{
    // Indicator will not produce signal.
    NONE,

    // Current hour equal to open trade hour
    CURRENT_HOUR_IS_OPEN_HOUR,

    // Current hour equals to close trade hour
    CURRENT_HOUR_IS_CLOSE_HOUR,

    // Range start hour <= Current time < Range end hour
    CURRENT_TIME_IS_IN_RANGE,
};