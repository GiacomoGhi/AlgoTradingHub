// Trade levels parameters
sinput string ___trade_levels_info_field;                                   // ************************************************************************
sinput string ___trade_levels_info_field_1;                                 // FIXED TRADE LEVELS PARAMETERS
input int __trade_levels_take_profit_length_long = 0;                       // Long trade take profit length
input int __trade_levels_stop_loss_length_long = 0;                         // Long trade stop loss length
input int __trade_levels_take_profit_length_short = 0;                      // Short trade take profit length
input int __trade_levels_stop_loss_length_short = 0;                        // Short trade stop loss length
input int __trade_levels_order_distance_from_price = 0;                     // Order distance from price
input ENUM_ORDER_TYPE_TIME __trade_levels_order_type_time = ORDER_TIME_GTC; // Order type time
input int __trade_levels_order_expiration_hour = -1;                        // Order expiration hour
