#include "./Shared/Logger/LogTypeEnum.mqh";
#include "./Shared/Enums/SymbolEnum.mqh";

// Base system parameters
input string __base_system_info_field;                         // MAIN PARAMETERS
input string __base_system_name = "MovingAvarage.Time.EA";     // Expert advisor name, comments and logs
input ulong __base_system_magic_number = 10000001;             // Expert advisor unique Id
input SymbolEnum __base_system_symbol = SymbolEnum::CHART;     // Symbol (CHART == current chart symbol)
input bool __base_system_is_grid_trading_enabled = false;      // Enable grid trading logic
input string __base_system_symbol_suffix = "";                 // Symbol suffix
input LogTypeEnum __base_system_log_level = LogTypeEnum::NONE; // Allow log level