#include "../../../Shared/Enums/TradeSignalTypeEnum.mqh";
#include "../Models/StaticRangeSignalsEnum.mqh";

// Static range indicator parameters
sinput string ___static_range_0_info_field_0;                                                                          // ************************************************************************
sinput string ___static_range_0_info_field_1;                                                                          // #1 STATIC RANGE INDICATOR PARAMETERS
input double __static_range_0_min_price = 15;                                                                          // Minimum price
input double __static_range_0_max_price = 15;                                                                          // Maximum price
input double __static_range_0_positions_delta_point = 100;                                                             // Positions delta points
input TradeSignalTypeEnum __static_range_0_signal_type_0 = TradeSignalTypeEnum::OPEN_BUY_MARKET;                       // #1 Trade signal type
input StaticRangeSignalsEnum __static_range_0_signal_trigger_0 = StaticRangeSignalsEnum::PRICE_ABOVE_MIN_PRICE;        // #1 Trade signal trigger
input TradeSignalTypeEnum __static_range_0_signal_type_1 = TradeSignalTypeEnum::OPEN_BUY_MARKET;                       // #2 Trade signal type
input StaticRangeSignalsEnum __static_range_0_signal_trigger_1 = StaticRangeSignalsEnum::PRICE_BELOW_MAX_PRICE;        // #2 Trade signal trigger
input TradeSignalTypeEnum __static_range_0_signal_type_2 = TradeSignalTypeEnum::OPEN_SELL_MARKET;                      // #3 Trade signal type
input StaticRangeSignalsEnum __static_range_0_signal_trigger_2 = StaticRangeSignalsEnum::PRICE_BELOW_MAX_PRICE;        // #3 Trade signal trigger
input TradeSignalTypeEnum __static_range_0_signal_type_3 = TradeSignalTypeEnum::OPEN_SELL_MARKET;                      // #4 Trade signal type
input StaticRangeSignalsEnum __static_range_0_signal_trigger_3 = StaticRangeSignalsEnum::OVER_PREVIOUS_POSITION_DELTA; // #4 Trade signal trigger