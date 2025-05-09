#include "../../../Shared/Enums/TradeSignalTypeEnum.mqh";
#include "../../../Shared/Enums/SymbolEnum.mqh";
#include "../Models/RelativeStrenghtIndexSignalsEnum.mqh";

// RSI parameters
sinput string ___relative_strenght_index_0_info_field_0;                          // ************************************************************************
sinput string ___relative_strenght_index_0_info_field_1;                          // #1 RSI PARAMETERS
input SymbolEnum __relative_strenght_index_0_symbol = SymbolEnum::CHART;          // Symbol (CHART == current chart symbol)
input ENUM_TIMEFRAMES __relative_strenght_index_0_time_frame = PERIOD_CURRENT;    // Time frame
input int __relative_strenght_index_0_ma_period = 14;                             // MA period
input ENUM_APPLIED_PRICE __relative_strenght_index_0_applied_price = PRICE_CLOSE; // Applied price
input double __relative_strenght_index_0_overbought_level = 70;                   // Overbought level
input double __relative_strenght_index_0_oversold_level = 30;                     // Oversold level