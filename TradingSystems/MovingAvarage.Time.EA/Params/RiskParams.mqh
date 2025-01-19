#include "../../../Core/Managers/RiskManager/Models/SizeCalculationTypeEnum.mqh";

// Risk parameters
sinput string ___risk_manager_info_field;                                                                     // ************************************************************************
sinput string ___risk_manager_info_field_1;                                                                   // RISK MANAGER PARAMETES
input SizeCalculationTypeEnum __risk_manager_size_calculation_type = SizeCalculationTypeEnum::FIXED_LOT_SIZE; // Size calculation type
input double __risk_manager_size_value_or_balance_percentage = 1;                                             // Lots, money, or balance percent to risk
input ENUM_TIMEFRAMES __risk_manager_drawdown_limit_period_0 = PERIOD_D1;                                     // #1 Drawdown limit period
input double __risk_manager_drawdown_limit_percent_0 = 4.5;                                                   // #1 Drawdown limit balance percentage
input ENUM_TIMEFRAMES __risk_manager_drawdown_limit_period_1 = PERIOD_H1;                                     // #2 Drawdown limit period
input double __risk_manager_drawdown_limit_percent_1 = 1.0;                                                   // #2 Drawdown limit balance percentage
