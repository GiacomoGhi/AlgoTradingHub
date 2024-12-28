#include "../../../Core/Shared/Enums/TradeSignalTypeEnum.mqh";
#include "../../../Core/Indicators/TimeIndicator/Models/TimeIndicatorSignalsEnum.mqh";

// Time indicator parameters
sinput string ___time_indicator_0_info_field_0;                                                                            // ************************************************************************
sinput string ___time_indicator_0_info_field_1;                                                                            // #1 TIME INDICATOR PARAMETERS
input int __time_indicator_0_open_trade_hour = 9;                                                                          // Open trade hour
input int __time_indicator_0_close_trade_hour = 18;                                                                        // Close trade hour
input int __time_indicator_0_range_start_hour = 0;                                                                         // Range start hour
input int __time_indicator_0_range_stop_hour = 0;                                                                          // Range stop hour
input TradeSignalTypeEnum __time_indicator_0_signal_type_0 = TradeSignalTypeEnum::CLOSE_BUY_MARKET;                        // #1 Trade signal type
input TimeIndicatorSignalsEnum __time_indicator_0_signal_trigger_0 = TimeIndicatorSignalsEnum::CURRENT_HOUR_IS_CLOSE_HOUR; // #1 Trade signal trigger
input TradeSignalTypeEnum __time_indicator_0_signal_type_1 = TradeSignalTypeEnum::CLOSE_BUY_MARKET;                        // #2 Trade signal type
input TimeIndicatorSignalsEnum __time_indicator_0_signal_trigger_1 = TimeIndicatorSignalsEnum::CURRENT_HOUR_IS_CLOSE_HOUR; // #2 Trade signal trigger