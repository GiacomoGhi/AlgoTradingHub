#include "../../../Core/Managers/RiskManager/Models/SizeCalculationTypeEnum.mqh";

// Risk parameters
sinput string ___risk_manager_0_info_field;                                                                     // ************************************************************************
sinput string ___risk_manager_0_info_field_1;                                                                   // RISK MANAGER PARAMETES
input SizeCalculationTypeEnum __risk_manager_0_size_calculation_type = SizeCalculationTypeEnum::FIXED_LOT_SIZE; // Size calculation type
input double __risk_manager_0_size_value_or_balance_percentage = 1;                                             // Lots, money, or balance percent to risk
input double __risk_manager_0_max_daily_draw_down_percentage = 4.5;                                             // Max daily equity drawdown
input double __risk_manager_0_max_overall_draw_down = 9.5;                                                      // Max total equity drawdown