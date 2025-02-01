#include "../../../Shared/Enums/TradeSignalTypeEnum.mqh";
#include "../Models/MovingAvarageSignalsEnum.mqh";

// Moving avarage indicator parameters
sinput string ___moving_avarage_0_info_field_0;                                                                   // ************************************************************************
sinput string ___moving_avarage_0_info_field_1;                                                                   // #1 MOVING AVARAGE INDICATOR PARAMETERS
input ENUM_TIMEFRAMES __moving_avarage_0_time_frame = PERIOD_H1;                                                  // Time frame
input int __moving_avarage_0_period = 15;                                                                         // Period
input int __moving_avarage_0_shift = 0;                                                                           // Shift
input ENUM_MA_METHOD __moving_avarage_0_method = MODE_SMA;                                                        // Method
input ENUM_APPLIED_PRICE __moving_avarage_0_applied_price = PRICE_CLOSE;                                          // Applied price
input TradeSignalTypeEnum __moving_avarage_0_signal_type_0 = TradeSignalTypeEnum::OPEN_BUY_MARKET;                // Trade signal type
input MovingAvarageSignalsEnum __moving_avarage_0_signal_trigger_0 = MovingAvarageSignalsEnum::PRICE_CLOSE_ABOVE; // Trade signal trigger