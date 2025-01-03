//+-----------------------------------------------------------------------------+
//|                                                   MovingAvarage.Time.EA.mq5 |
//|        Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/> |
//|                                https://github.com/GiacomoGhi/AlgoTradingHub |
//+-----------------------------------------------------------------------------+

#property copyright "Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>"
#property link "https://github.com/GiacomoGhi/AlgoTradingHub"
#property version "1.00"

// Include Algo Trading Hub components
#include "../../Core/index.mqh";
#include "../../Core/ATHExpertAdvisor.mqh";

// Include input params global variables files
#include "./Params/BaseSystemParams.0.mqh";
#include "./Params/RiskParams.0.mqh";
#include "./Params/TradeLevelsParams.0.mqh";
#include "./Params/ExposureStatusIndicator.0.mqh";
#include "./Params/MovingAvarageParams.0.mqh";
#include "./Params/TimeIndicatorParams.0.mqh";

// ATH Expert advisor object
ATHExpertAdvisor *TradingSystem;

int OnInit()
{
    // Logger
    Logger *logger = new Logger(
        __base_system_0_allow_logging,
        __base_system_0_name,
        __base_system_0_magic_number);

    // Trade signal list
    ObjectList<ITradeSignalProvider> *tradeSignalsList = new ObjectList<ITradeSignalProvider>();

    // Exposure status indicator
    CHashMap<TradeSignalTypeEnum, ExposureStatusIndicatorSignalsEnum> *exposureStatusIndicatorSignalTypeTriggerStore = new CHashMap<TradeSignalTypeEnum, ExposureStatusIndicatorSignalsEnum>();
    exposureStatusIndicatorSignalTypeTriggerStore.Add(
        __exposure_status_indicator_0_signal_type_0,
        __exposure_status_indicator_0_signal_trigger_0);

    // Add exposure status indicator to trade signals list
    tradeSignalsList.Append(
        new ExposureStatusIndicator(
            logger,
            _Symbol,
            __base_system_0_magic_number,
            exposureStatusIndicatorSignalTypeTriggerStore));

    // Moving avarage singals type and trigger associations
    CHashMap<TradeSignalTypeEnum, MovingAvarageSignalsEnum> *movingAvarageSignalTypeTriggerStore = new CHashMap<TradeSignalTypeEnum, MovingAvarageSignalsEnum>();
    movingAvarageSignalTypeTriggerStore.Add(
        __moving_avarage_0_signal_type_0,
        __moving_avarage_0_signal_trigger_0);

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
    CHashMap<TradeSignalTypeEnum, TimeIndicatorSignalsEnum> *timeIndicatorSignalTypeTriggerStore = new CHashMap<TradeSignalTypeEnum, TimeIndicatorSignalsEnum>();
    timeIndicatorSignalTypeTriggerStore.Add(
        __time_indicator_0_signal_type_0,
        __time_indicator_0_signal_trigger_0);
    timeIndicatorSignalTypeTriggerStore.Add(
        __time_indicator_0_signal_type_1,
        __time_indicator_0_signal_trigger_1);

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
        __base_system_0_magic_number,
        __base_system_0_name);

    // Risk manager periods allowed drowdown store
    ObjectList<CKeyValuePair<ENUM_TIMEFRAMES, double>> *periodAllowedDrawdownStore = new ObjectList<CKeyValuePair<ENUM_TIMEFRAMES, double>>();
    periodAllowedDrawdownStore.Append(
        new CKeyValuePair<ENUM_TIMEFRAMES, double>(
            __risk_manager_0_drawdown_limit_period_0,
            __risk_manager_0_drawdown_limit_percent_0));
    periodAllowedDrawdownStore.Append(
        new CKeyValuePair<ENUM_TIMEFRAMES, double>(
            __risk_manager_0_drawdown_limit_period_1,
            __risk_manager_0_drawdown_limit_percent_1));

    // Risk manager params
    RiskManagerParams *riskManagerParams = new RiskManagerParams(
        __risk_manager_0_size_calculation_type,
        __risk_manager_0_size_value_or_balance_percentage,
        periodAllowedDrawdownStore);

    // Signal manager params
    SignalManagerParams *signalManagerParams = new SignalManagerParams(tradeSignalsList);

    // Context params
    ContextParams *contextParams = new ContextParams(_Symbol);

    // Trade levels indicator
    FixedTradeLevels *fixedTradeLevels = new FixedTradeLevels(
        logger,
        contextParams,
        __trade_levels_take_profit_length,
        __trade_levels_stop_loss_length,
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