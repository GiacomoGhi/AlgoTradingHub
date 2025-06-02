#include <Core/Shared/Enums/TradeSignalTypeEnum.mqh>;
#include "../Models/TimeIndicatorSignalsEnum.mqh";

// Time indicator parameters
sinput string ___time_indicator_0_info_field_0;     // ************************************************************************
sinput string ___time_indicator_0_info_field_1;     // #1 TIME INDICATOR PARAMETERS
input int __time_indicator_0_open_trade_hour = 9;   // Open trade hour
input int __time_indicator_0_close_trade_hour = 18; // Close trade hour
input int __time_indicator_0_range_start_hour = 0;  // Range start hour
input int __time_indicator_0_range_stop_hour = 0;   // Range stop hour
input int __time_indicator_0_range_start_day = 0;   // Range start day
input int __time_indicator_0_range_stop_day = 0;    // Range end day