#include "../../../Shared/Enums/TradeSignalTypeEnum.mqh";
#include "../Models/StaticRangeSignalsEnum.mqh";

// Static range indicator parameters
sinput string ___static_range_0_info_field_0;               // ************************************************************************
sinput string ___static_range_0_info_field_1;               // #1 STATIC RANGE INDICATOR PARAMETERS
input double __static_range_0_min_price = 15;               // Minimum price
input double __static_range_0_max_price = 15;               // Maximum price
input double __static_range_0_price_delta_points = 15;      // Price delta
input double __static_range_0_positions_delta_points = 100; // Positions delta points
input bool __static_range_0_use_shifted_start_price = true; // (For grid trading) Use shifted start price