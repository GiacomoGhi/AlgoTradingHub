// Trade levels parameters
sinput string ___trade_levels_info_field;                                   // ************************************************************************
sinput string ___trade_levels_info_field_1;                                 // PRICE RANGE TRADE LEVELS PARAMETERS
input ENUM_TIMEFRAMES __trade_levels_time_frame;                            // Bars time frame
input int __trade_levels_bars_number;                                       // Number of bars in the range
input double __trade_levels_max_range_percentage_height;                    // Max range percentage height
input double __trade_levels_min_range_percentage_height;                    // Min range percentage height
input int __trade_levels_order_price_delta;                                 // Order price delta from range
input int __trade_levels_order_stop_loss_delta;                             // Order stop loss delta
input ENUM_ORDER_TYPE_TIME __trade_levels_order_type_time = ORDER_TIME_GTC; // Order type time
input int __trade_levels_order_expiration_hour = 0;                         // Order expiration hour
