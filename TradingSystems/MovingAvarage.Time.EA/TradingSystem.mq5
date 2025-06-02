//+-----------------------------------------------------------------------------+
//|                                                   MovingAvarage.Time.EA.mq5 |
//|        Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/> |
//|                                https://github.com/GiacomoGhi/AlgoTradingHub |
//+-----------------------------------------------------------------------------+

#property copyright "Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>"
#property link "https://github.com/GiacomoGhi/AlgoTradingHub"
#property version "1.00"

// Include Algo Trading Hub components
#include "../../Core/ATHExpertAdvisor.mqh";
#include "../../Core/index.mqh";

// Include base system input params global variables files
#include "../../Core/BaseSystemParams.mqh";
#include "../../Core/Managers/RiskManager/Params/RiskParams.mqh";
#include "../../Core/Managers/TradeManager/Params/TradeManagerParams.mqh";

// Include indicators input params global variables files
#include "../../Core/Indicators/ExposureStatusIndicator/Params/ExposureStatusIndicatorParams.0.mqh";
#include "../../Core/Indicators/FixedTradeLevels/Params/FixedTradeLevelsParams.mqh";
#include "../../Core/Indicators/MovingAvarage/Params/MovingAvarageParams.0.mqh";
#include "../../Core/Indicators/TimeIndicator/Params/TimeIndicatorParams.0.mqh";

// Include additional params
#include "./AdditionalParams/ExposureStatusIndicatorAdditionalParams.0.mqh";
#include "./AdditionalParams/RiskAdditionalParams.mqh";
#include "./AdditionalParams/TimeIndicatorAdditionalParams.0.mqh";

// ATH Expert advisor object
ATHExpertAdvisor *TradingSystem;

int OnInit()
{
    // Logger
    Logger *logger = new Logger(
        __base_system_log_level,
        __base_system_name,
        __base_system_magic_number);

    // Trade signal list
    ObjectList<ITradeSignalProvider> *tradeSignalsList = new ObjectList<ITradeSignalProvider>();

    // Exposure status indicator
    ObjectList<CKeyValuePair<TradeSignalTypeEnum, ExposureStatusIndicatorSignalsEnum>> *exposureStatusIndicatorSignalTypeTriggerStore = new ObjectList<CKeyValuePair<TradeSignalTypeEnum, ExposureStatusIndicatorSignalsEnum>>();
    exposureStatusIndicatorSignalTypeTriggerStore.Append(
        new CKeyValuePair<TradeSignalTypeEnum, ExposureStatusIndicatorSignalsEnum>(
            __exposure_status_indicator_0_signal_type_0,
            __exposure_status_indicator_0_signal_trigger_0));

    // Add exposure status indicator to trade signals list
    tradeSignalsList.Append(
        new ExposureStatusIndicator(
            logger,
            _Symbol,
            exposureStatusIndicatorSignalTypeTriggerStore,
            __base_system_magic_number));

    // Moving avarage singals type and trigger associations
    ObjectList<CKeyValuePair<TradeSignalTypeEnum, MovingAvarageSignalsEnum>> *movingAvarageSignalTypeTriggerStore = new ObjectList<CKeyValuePair<TradeSignalTypeEnum, MovingAvarageSignalsEnum>>();
    movingAvarageSignalTypeTriggerStore.Append(
        new CKeyValuePair<TradeSignalTypeEnum, MovingAvarageSignalsEnum>(
            __moving_avarage_0_signal_type_0,
            __moving_avarage_0_signal_trigger_0));

    // Add moving avarage to trade signals list
    tradeSignalsList.Append(
        new MovingAvarage(
            logger,
            _Symbol,
            movingAvarageSignalTypeTriggerStore,
            __moving_avarage_0_time_frame,
            __moving_avarage_0_period,
            __moving_avarage_0_shift,
            __moving_avarage_0_method,
            __moving_avarage_0_applied_price));

    // Time indicator singals type and trigger associations
    ObjectList<CKeyValuePair<TradeSignalTypeEnum, TimeIndicatorSignalsEnum>> *timeIndicatorSignalTypeTriggerStore = new ObjectList<CKeyValuePair<TradeSignalTypeEnum, TimeIndicatorSignalsEnum>>();
    timeIndicatorSignalTypeTriggerStore.Append(
        new CKeyValuePair<TradeSignalTypeEnum, TimeIndicatorSignalsEnum>(
            __time_indicator_0_signal_type_0,
            __time_indicator_0_signal_trigger_0));
    timeIndicatorSignalTypeTriggerStore.Append(
        new CKeyValuePair<TradeSignalTypeEnum, TimeIndicatorSignalsEnum>(
            __time_indicator_0_signal_type_1,
            __time_indicator_0_signal_trigger_1));

    // Add time indicator to trade signals list
    tradeSignalsList.Append(
        new TimeIndicator(
            logger,
            _Symbol,
            timeIndicatorSignalTypeTriggerStore,
            __time_indicator_0_open_trade_hour,
            __time_indicator_0_close_trade_hour,
            __time_indicator_0_range_start_hour,
            __time_indicator_0_range_stop_hour));

    // Trade manager params
    TradeManagerParams *tradeManagerParams = new TradeManagerParams(
        __base_system_name,
        __trade_manager_break_even_at_points_in_profit,
        __trade_manager_break_even_execution_mode,
        __trade_manager_consume_all_calculated_lots);

    // Risk manager periods allowed drowdown store
    ObjectList<CKeyValuePair<ENUM_TIMEFRAMES, double>> *periodAllowedDrawdownStore = new ObjectList<CKeyValuePair<ENUM_TIMEFRAMES, double>>();
    periodAllowedDrawdownStore.Append(
        new CKeyValuePair<ENUM_TIMEFRAMES, double>(
            __risk_manager_drawdown_limit_period_0,
            __risk_manager_drawdown_limit_percent_0));
    periodAllowedDrawdownStore.Append(
        new CKeyValuePair<ENUM_TIMEFRAMES, double>(
            __risk_manager_drawdown_limit_period_1,
            __risk_manager_drawdown_limit_percent_1));

    // Risk manager params
    RiskManagerParams *riskManagerParams = new RiskManagerParams(
        __risk_manager_size_calculation_type_long,
        __risk_manager_size_value_or_balance_percentage_long,
        __risk_manager_size_calculation_type_short,
        __risk_manager_size_value_or_balance_percentage_short,
        periodAllowedDrawdownStore);

    // Signal manager params
    SignalManagerParams *signalManagerParams = new SignalManagerParams(tradeSignalsList);

    // Context params
    ContextParams *contextParams = new ContextParams(
        _Symbol,
        __base_system_magic_number);

    // Trade levels indicator
    FixedTradeLevels *fixedTradeLevels = new FixedTradeLevels(
        logger,
        contextParams,
        __trade_levels_take_profit_length_long,
        __trade_levels_stop_loss_length_long,
        __trade_levels_take_profit_length_short,
        __trade_levels_stop_loss_length_short,
        __trade_levels_order_distance_from_price,
        __trade_levels_order_type_time,
        __trade_levels_order_expiration_hour);

    // Initialize ATH Expert Advisor
    TradingSystem = new ATHExpertAdvisor(
        logger,
        contextParams,
        tradeManagerParams,
        riskManagerParams,
        signalManagerParams,
        fixedTradeLevels);

    if (!TradingSystem.IsInitCompleted)
    {
        return (INIT_PARAMETERS_INCORRECT);
    }

    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
    delete TradingSystem;
}

void OnTick()
{
    TradingSystem.OnTick();
}