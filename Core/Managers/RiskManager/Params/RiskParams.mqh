#include "../Models/SizeCalculationTypeEnum.mqh";

// Risk parameters
sinput string ___risk_manager_info_field;                                                                                            // ************************************************************************
sinput string ___risk_manager_info_field_1;                                                                                          // RISK MANAGER PARAMETES
input SizeCalculationTypeEnum __risk_manager_size_calculation_type_long = SizeCalculationTypeEnum::FIXED_LOT_SIZE;                   // Long trades size calculation type
input double __risk_manager_size_value_or_balance_percentage_long = 1;                                                               // Long trades lots, money, or balance percent to risk
input SizeCalculationTypeEnum __risk_manager_size_calculation_type_short = SizeCalculationTypeEnum::MATCH_OPPOSITE_DIRECTION_VOLUME; // Short trades size calculation type
input double __risk_manager_size_value_or_balance_percentage_short = 1;                                                              // Short trades lots, money, or balance percent to risk
