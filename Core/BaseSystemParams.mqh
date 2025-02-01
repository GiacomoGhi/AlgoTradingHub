#include "./Shared/Logger/LogTypeEnum.mqh";

// Base system parameters
input string __base_system_info_field;                         // MAIN PARAMETERS
input string __base_system_name = "MovingAvarage.Time.EA";     // Expert advisor name, comments and logs
input ulong __base_system_magic_number = 10000001;             // Expert advisor unique Id
input LogTypeEnum __base_system_log_level = LogTypeEnum::NONE; // Allow log level