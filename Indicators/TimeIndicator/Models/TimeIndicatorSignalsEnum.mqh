enum TimeIndicatorSignalsEnum
{
    // Default value that returns true signal,
    // it is used to ignore this indicator during signal analysis.
    AlwaysTrue,

    // Current hour equal to open trade hour
    CurrentHourIsOpenHour,

    // Current hour equals to close trade hour
    CurrentHourIsCloseHour,

    // Range start hour <= Current time < Range end hour
    CurrentTimeIsInRange,
};