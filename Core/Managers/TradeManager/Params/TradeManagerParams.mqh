#include "../Models/BreakEvenExecutionMode.mqh"

// Position management parameters
sinput string ___trade_manager_info_field;                                                                              // ************************************************************************
sinput string ___trade_manager_info_field_1;                                                                            // TRADE MANAGER PARAMETERS
input bool __trade_manager_consume_all_calculated_lots = false;                                                         // Allow to open as many position as needed by calculated lots
input int __trade_manager_break_even_at_points_in_profit = 0;                                                           // Trade profit points to set break-even (less then one is disabled)
input BreakEvenExecutionModeEnum __trade_manager_break_even_execution_mode = BreakEvenExecutionModeEnum::ALL_POSITIONS; // Break even execution mode