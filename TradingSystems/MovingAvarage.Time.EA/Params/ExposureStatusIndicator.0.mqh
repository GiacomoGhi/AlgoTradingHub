#include "../../../Core/Shared/Enums/TradeSignalTypeEnum.mqh";
#include "../../../Core/Indicators/ExposureStatusIndicator/Models/ExposureStatusIndicatorSignalsEnum.mqh";

// Time indicator parameters
sinput string ___exposure_status_indicator_0_info_field_0;                                                                                           // ************************************************************************
sinput string ___exposure_status_indicator_0_info_field_1;                                                                                           // #1 EXPOSURE STATUS INDICATOR PARAMETERS
input TradeSignalTypeEnum __exposure_status_indicator_0_signal_type_0 = TradeSignalTypeEnum::OPEN_BUY_MARKET;                                        // Trade signal type
input ExposureStatusIndicatorSignalsEnum __exposure_status_indicator_0_signal_trigger_0 = ExposureStatusIndicatorSignalsEnum::NOT_ANY_OPEN_POSITION; // Trade signal trigger