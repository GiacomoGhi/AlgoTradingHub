//+-----------------------------------------------------------------------------+
//|                                                   MovingAvarage.Time.EA.mq5 |
//|        Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/> |
//|                                https://github.com/GiacomoGhi/AlgoTradingHub |
//+-----------------------------------------------------------------------------+

#property copyright "Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>"
#property link "https://github.com/GiacomoGhi/AlgoTradingHub"
#property version "1.00"

#include "../../Core/index.mqh";
#include "../../Core/ATHExpertAdvisor.mqh";

// Base system parameters
input string __baseSystemInfoField = "Main parameters";
input ulong __baseSystemMagicNumber = 10000001;                                    // Expert advisor unique Id
input string __baseSystemComment = "ATH Expert Advisor";                           // Expert advisor trade comment
input TradingStyleTypeEnum __baseSystemTradingStyleType = DIRECT_MARKET_EXECUTION; // Trading style type
input bool __baseSystemAllowMultiplePosition = false;                              // Allow multiple open positions

// Risk parameters
sinput string ___riskManagerInfoField = "";
sinput string ___riskManagerInfoField1 = "Risk manager parameters";
input SizeCalculationTypeEnum __riskManagerSizeCalculationType = SizeCalculationTypeEnum::FIXED_LOT_SIZE; // Size calculation type
input double __riskManagerSizeValueOrBalancePercentage = 1;                                               // Lots, money or balace percent to risk
input double __riskManagerMaxDailyDrowDownPercentage = 4.5;                                               // Max daily equity drow down
input double __riskManagerMaxOverallDrawDown = 9.5;                                                       // Max total equity drow down

// Moving avarage indicator parameters
sinput string ___movingAvarageIndicatorInfoField = "";
sinput string ___movingAvarageIndicatorInfoField1 = "Moving avarage indicator parameters";
input ENUM_TIMEFRAMES __movingAvarageIndicatorTimeFrame = PERIOD_H1;                                                // Time frame
input int __movingAvarageIndicatorPeriod = 15;                                                                      // Period
input int __movingAvarageIndicatorShift = 0;                                                                        // Shift
input ENUM_MA_METHOD __movingAvarageIndicatorMethod = MODE_SMA;                                                     // Method
input ENUM_APPLIED_PRICE __movingAvarageIndicatorAppliedPrice = PRICE_CLOSE;                                        // Applied price
input MovingAvarageSignalsEnum __movingAvarageIndicatorOpenBuySignal = MovingAvarageSignalsEnum::PRICE_CLOSE_ABOVE; // Open buy trade signal type
input MovingAvarageSignalsEnum __movingAvarageIndicatorCloseBuySignal = MovingAvarageSignalsEnum::NONE;             // Close buy trade signal type
input MovingAvarageSignalsEnum __movingAvarageIndicatorOpenSellSignal = MovingAvarageSignalsEnum::NONE;             // Open sell trade signal type
input MovingAvarageSignalsEnum __movingAvarageIndicatorCloseSellSignal = MovingAvarageSignalsEnum::NONE;            // Close sell trade signal type

// Time indicator parameters
sinput string ___timeIndicatorInfoField = "";
sinput string ___timeIndicatorInfoField1 = "Time indicator parameters";
input ENUM_TIMEFRAMES __timeIndicatorTimeFrame = PERIOD_H1;                                                          // Time frame
input int __timeIndicatorOpenTradeHour = 9;                                                                          // Open trade hour
input int __timeIndicatorCloseTradeHour = 18;                                                                        // Close trade hour
input int __timeIndicatorRangeStartHour = 0;                                                                         // Range start hour
input int __timeIndicatorRangeStopHour = 0;                                                                          // Range stop hour
input TimeIndicatorSignalsEnum __timeIndicatorOpenBuySignal = TimeIndicatorSignalsEnum::NONE;                        // Open buy trade signal type
input TimeIndicatorSignalsEnum __timeIndicatorCloseBuySignal = TimeIndicatorSignalsEnum::CURRENT_HOUR_IS_CLOSE_HOUR; // Close buy trade signal type
input TimeIndicatorSignalsEnum __timeIndicatorOpenSellSignal = TimeIndicatorSignalsEnum::NONE;                       // Open sell trade signal type
input TimeIndicatorSignalsEnum __timeIndicatorCloseSellSignal = TimeIndicatorSignalsEnum::NONE;                      // Close sell trade signal type

// ATH Expert advisor object
ATHExpertAdvisor *TradingSystem;

int OnInit()
{
    // Trade signal list
    ObjectList<ITradeSignal> *tradeSignalsList;

    // Moving avarage indicators singals
    IndicatorSignals<MovingAvarageSignalsEnum> *movingAvarageIndicatorSignals = new IndicatorSignals<MovingAvarageSignalsEnum>(
        // Open buy trade signal
        new Tuple<bool, MovingAvarageSignalsEnum>(
            __movingAvarageIndicatorOpenBuySignal == MovingAvarageSignalsEnum::NONE
                ? false
                : true,
            __movingAvarageIndicatorOpenBuySignal),
        // Close buy trade signal
        new Tuple<bool, MovingAvarageSignalsEnum>(
            __movingAvarageIndicatorCloseBuySignal == MovingAvarageSignalsEnum::NONE
                ? false
                : true,
            __movingAvarageIndicatorCloseBuySignal),
        // Open sell trade signal
        new Tuple<bool, MovingAvarageSignalsEnum>(
            __movingAvarageIndicatorOpenSellSignal == MovingAvarageSignalsEnum::NONE
                ? false
                : true,
            __movingAvarageIndicatorOpenSellSignal),
        // Open buy trade singal
        new Tuple<bool, MovingAvarageSignalsEnum>(
            __movingAvarageIndicatorCloseSellSignal == MovingAvarageSignalsEnum::NONE
                ? false
                : true,
            __movingAvarageIndicatorCloseSellSignal));

    // Add moving avarage to trade signals list
    tradeSignalsList.Append(
        new MovingAvarage(
            _Symbol,
            __movingAvarageIndicatorTimeFrame,
            movingAvarageIndicatorSignals,
            __movingAvarageIndicatorPeriod,
            __movingAvarageIndicatorShift,
            __movingAvarageIndicatorMethod,
            __movingAvarageIndicatorAppliedPrice));

    // Time indicator signals
    IndicatorSignals<TimeIndicatorSignalsEnum> *timeIndicatorSignals = new IndicatorSignals<TimeIndicatorSignalsEnum>(
        // Open buy trade signal
        new Tuple<bool, TimeIndicatorSignalsEnum>(
            __timeIndicatorOpenBuySignal == TimeIndicatorSignalsEnum::NONE
                ? false
                : true,
            __timeIndicatorOpenBuySignal),
        // Close buy trade signal
        new Tuple<bool, TimeIndicatorSignalsEnum>(
            __timeIndicatorCloseBuySignal == TimeIndicatorSignalsEnum::NONE
                ? false
                : true,
            __timeIndicatorCloseBuySignal),
        // Open sell trade signal
        new Tuple<bool, TimeIndicatorSignalsEnum>(
            __timeIndicatorOpenSellSignal == TimeIndicatorSignalsEnum::NONE
                ? false
                : true,
            __timeIndicatorOpenSellSignal),
        // Open buy trade singal
        new Tuple<bool, TimeIndicatorSignalsEnum>(
            __timeIndicatorCloseSellSignal == TimeIndicatorSignalsEnum::NONE
                ? false
                : true,
            __timeIndicatorCloseSellSignal));

    // Add time indicator to trade signals list
    tradeSignalsList.Append(
        new TimeIndicator(
            _Symbol,
            timeIndicatorSignals,
            __timeIndicatorOpenTradeHour,
            __timeIndicatorCloseTradeHour,
            __timeIndicatorRangeStartHour,
            __timeIndicatorRangeStopHour));

    // Trade manager params
    TradeManagerParams *tradeManagerParams = new TradeManagerParams(
        __baseSystemMagicNumber,
        __baseSystemComment);

    // Risk manager params
    RiskManagerParams *riskManagerParams = new RiskManagerParams(
        __riskManagerSizeValueOrBalancePercentage,
        __riskManagerMaxDailyDrowDownPercentage,
        __riskManagerMaxOverallDrawDown,
        __riskManagerSizeCalculationType);

    // Signal manager params
    SignalManagerParams *signalManagerParams = new SignalManagerParams(tradeSignalsList);

    // Initialize ATH Expert Advisor
    TradingSystem = new ATHExpertAdvisor(
        new ContextParams(_Symbol),
        tradeManagerParams,
        riskManagerParams,
        signalManagerParams
        // TODO tradeLevelsIndicator
    );

    // double test = MarketHelper::GetAskPrice();

    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
    TradingSystem.OnTick();
}