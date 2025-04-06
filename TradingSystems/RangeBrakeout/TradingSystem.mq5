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

// Base system params
#include "../../Core/BaseSystemParams.mqh";

// Risk manager params
#include "../../Core/Managers/RiskManager/Params/RiskParams.mqh";
#include "./AdditionalParams/RiskAdditionalParams.mqh";

// Trade levels indicator params
#include "../../Core/Indicators/PriceRangeTradeLevels/Params/PriceRangeTradeLevelsParams.mqh";
#include "./AdditionalParams/PriceRangeTradeLevelsAdditionalParams.0.mqh";

// Trade manager params
#include "../../Core/Managers/TradeManager/Params/TradeManagerParams.mqh"
#include "../../Core/Indicators/ExposureStatusIndicator/Params/ExposureStatusIndicatorParams.0.mqh";

// Exposure status indicator params
#include "./AdditionalParams/ExposureStatusIndicatorAdditionalParams.0.mqh";
#include "../../Core/Indicators/TimeIndicator/Params/TimeIndicatorParams.0.mqh";

// Time indicator params
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

    // Get EA working symbol
    const string SYMBOL = MarketHelper::MapSymbol(__base_system_symbol, __base_system_symbol_suffix);
    logger.Log(INFO, __FUNCTION__, "Trading symbol: " + SYMBOL);

    // Trade signal list
    ObjectList<ITradeSignalProvider> *tradeSignalsList = new ObjectList<ITradeSignalProvider>();

    // Exposure status indicator
    ObjectList<CKeyValuePair<TradeSignalTypeEnum, ExposureStatusIndicatorSignalsEnum>> *exposureStatusIndicatorSignalTypeTriggerStore = new ObjectList<CKeyValuePair<TradeSignalTypeEnum, ExposureStatusIndicatorSignalsEnum>>();
    exposureStatusIndicatorSignalTypeTriggerStore.Append(
        new CKeyValuePair<TradeSignalTypeEnum, ExposureStatusIndicatorSignalsEnum>(
            __exposure_status_indicator_0_signal_type_0,
            __exposure_status_indicator_0_signal_trigger_0));
    exposureStatusIndicatorSignalTypeTriggerStore.Append(
        new CKeyValuePair<TradeSignalTypeEnum, ExposureStatusIndicatorSignalsEnum>(
            __exposure_status_indicator_0_signal_type_1,
            __exposure_status_indicator_0_signal_trigger_1));

    // Add exposure status indicator to trade signals list
    tradeSignalsList.Append(
        new ExposureStatusIndicator(
            logger,
            SYMBOL,
            exposureStatusIndicatorSignalTypeTriggerStore,
            __base_system_magic_number));

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
    timeIndicatorSignalTypeTriggerStore.Append(
        new CKeyValuePair<TradeSignalTypeEnum, TimeIndicatorSignalsEnum>(
            __time_indicator_0_signal_type_2,
            __time_indicator_0_signal_trigger_2));
    timeIndicatorSignalTypeTriggerStore.Append(
        new CKeyValuePair<TradeSignalTypeEnum, TimeIndicatorSignalsEnum>(
            __time_indicator_0_signal_type_3,
            __time_indicator_0_signal_trigger_3));

    // Add time indicator to trade signals list
    tradeSignalsList.Append(
        new TimeIndicator(
            logger,
            SYMBOL,
            timeIndicatorSignalTypeTriggerStore,
            __time_indicator_0_open_trade_hour,
            __time_indicator_0_close_trade_hour,
            __time_indicator_0_range_start_hour,
            __time_indicator_0_range_stop_hour,
            __time_indicator_0_range_start_day,
            __time_indicator_0_range_stop_day));

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
        periodAllowedDrawdownStore,
        __risk_manager_use_long_value_for_both);

    // Signal manager params
    SignalManagerParams *signalManagerParams = new SignalManagerParams(tradeSignalsList);

    // Context params
    ContextParams *contextParams = new ContextParams(
        SYMBOL,
        __base_system_magic_number);

    // Price range trade levels trigger store
    ObjectList<CKeyValuePair<TradeSignalTypeEnum, PriceRangeTradeLevelsSignalsEnum>> *priceRangeTradeLevelsSignalTypeTriggerStore = new ObjectList<CKeyValuePair<TradeSignalTypeEnum, PriceRangeTradeLevelsSignalsEnum>>();
    priceRangeTradeLevelsSignalTypeTriggerStore.Append(
        new CKeyValuePair<TradeSignalTypeEnum, PriceRangeTradeLevelsSignalsEnum>(
            __trade_levels_0_signal_type_0,
            __trade_levels_0_signal_trigger_0));
    priceRangeTradeLevelsSignalTypeTriggerStore.Append(
        new CKeyValuePair<TradeSignalTypeEnum, PriceRangeTradeLevelsSignalsEnum>(
            __trade_levels_0_signal_type_1,
            __trade_levels_0_signal_trigger_1));
    priceRangeTradeLevelsSignalTypeTriggerStore.Append(
        new CKeyValuePair<TradeSignalTypeEnum, PriceRangeTradeLevelsSignalsEnum>(
            __trade_levels_0_signal_type_2,
            __trade_levels_0_signal_trigger_2));
    priceRangeTradeLevelsSignalTypeTriggerStore.Append(
        new CKeyValuePair<TradeSignalTypeEnum, PriceRangeTradeLevelsSignalsEnum>(
            __trade_levels_0_signal_type_3,
            __trade_levels_0_signal_trigger_3));

    // Price range trade levels indicator
    PriceRangeTradeLevels *priceRangeTradeLevels = new PriceRangeTradeLevels(
        logger,
        contextParams,
        priceRangeTradeLevelsSignalTypeTriggerStore,
        __trade_levels_time_frame,
        __trade_levels_bars_number,
        __trade_levels_max_range_percentage_height,
        __trade_levels_min_range_percentage_height,
        __trade_levels_order_price_delta,
        __trade_levels_order_stop_loss_delta,
        __trade_levels_order_type_time,
        __trade_levels_order_expiration_hour);

    // Add price range trade levels to trade singal list
    tradeSignalsList.Append(priceRangeTradeLevels);

    // Use wrapper, workarout for mql lack of multiple interfaces inheritance
    PriceRangeTradeLevelsWrapper *tradeLevelsIndicatorWrapper = new PriceRangeTradeLevelsWrapper(priceRangeTradeLevels);

    // Initialize ATH Expert Advisor
    TradingSystem = new ATHExpertAdvisor(
        logger,
        contextParams,
        tradeManagerParams,
        riskManagerParams,
        signalManagerParams,
        tradeLevelsIndicatorWrapper);

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