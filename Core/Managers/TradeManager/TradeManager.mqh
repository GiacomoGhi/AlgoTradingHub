#include "../../../Libraries/List/BasicList.mqh";
#include "../../../Libraries/List/ObjectList.mqh";
#include "../../Shared/Helpers/MarketHelper.mqh";
#include "../../Shared/Helpers/TradeSignalTypeEnumHelper.mqh";
#include "../../Shared/Logger/Logger.mqh";
#include "../../Shared/Models/ContextParams.mqh";
#include "../../Shared/Models/TradeLevels.mqh";
#include "../RiskManager/RiskManager.mqh";
#include "./Models/TradeManagerParams.mqh";
#include "./Models/TradeTypeEnumHelper.mqh";
#include <Generic/HashMap.mqh>;
#include <Trade/Trade.mqh>;

class TradeManager
{
private:
    /**
     * Logger.
     */
    Logger *_logger;

    /**
     * Trade manager params.
     */
    TradeManagerParams *_tradeManagerParams;

    /**
     * Context params.
     */
    ContextParams *_contextParams;

    /**
     * CTrade object to access market api.
     */
    CTrade _market;

    /**
     * Expert advisor unique identifier.
     */
    ulong _magicNumber;

    /**
     * Risk manager.
     */
    RiskManager *_riskManager;

    /**
     * Buy position ticket store.
     */
    ulong _buyPositionTicket;

    /**
     * Sell position ticket store.
     */
    ulong _sellPositionTicket;

    /**
     * List of trades tickets (keys) and their type (values).
     */
    ObjectList<CKeyValuePair<ulong, TradeTypeEnum>> *_tradesStore;

    /**
     * Tickets of trades not correctly voided.
     */
    BasicList<ulong> *_tradesToVoidStore;

    /**
     * Symbol trade freeze level
     */
    double _symbolTradeFreezeLevel;

public:
    /**
     * Constructor.
     */
    TradeManager(
        Logger &logger,
        ContextParams &contextParams,
        TradeManagerParams &tradeManagerParams,
        RiskManager &riskManager)
        : _logger(&logger),
          _tradeManagerParams(&tradeManagerParams),
          _contextParams(&contextParams),
          _magicNumber(contextParams.MagicNumber),
          _riskManager(&riskManager),
          _tradesStore(new ObjectList<CKeyValuePair<ulong, TradeTypeEnum>>),
          _tradesToVoidStore(new BasicList<ulong>),
          _symbolTradeFreezeLevel(
              SymbolInfoInteger(contextParams.Symbol, SYMBOL_TRADE_FREEZE_LEVEL) * contextParams.Points)
    {
        // Set ea magic number
        _market.SetExpertMagicNumber(contextParams.MagicNumber);

        // Check for old positions and orders
        RetriveOpenPositions();
        RetriveOpenOrders();

        _logger.LogInitCompleted(__FUNCTION__);
    };

    /**
     * Deconstructor
     */
    ~TradeManager()
    {
        // Trades store
        delete _tradesStore;

        // Trades to void store;
        delete _tradesToVoidStore;

        // Delte trade manager params dto
        delete _tradeManagerParams;
    }

    /**
     * Select lastest position with given magicNumber
     */
    static bool SelectLatestPosition(Logger &logger, ulong magicNumber, string symbol, int direction = 0)
    {
        // For all open positions
        for (int i = PositionsTotal() - 1; i >= 0; i--)
        {
            // Select current position
            ulong ticket = PositionGetTicket(i);
            if (PositionSelectByTicket(ticket))
            {
                // Get position type
                ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)(PositionGetInteger(POSITION_TYPE));

                // Compare magic
                if (PositionGetInteger(POSITION_MAGIC) == magicNumber
                    // Symbol of position
                    && PositionGetString(POSITION_SYMBOL) == symbol
                    // Flat (any direction)
                    && (direction == 0
                        // Long
                        || (direction == 1 && positionType == POSITION_TYPE_BUY)
                        // Short
                        || (direction == -1 && positionType == POSITION_TYPE_SELL)))
                {
                    return true;
                }
            }
        }

        return false;
    }

    /**
     * Close or delete singals only,
     * overload with TradeLevels to execute a new position or order.
     */
    void Execute(TradeSignalTypeEnum signalType)
    {
        if (TradeSignalTypeEnumHelper::IsOpenType(signalType))
        {
            _logger.Log(ERROR, __FUNCTION__, "Unsupported close or delete signal type: " + EnumToString(signalType));
            return;
        }

        // Void trades with matching type
        TradeTypeEnum tradeType = TradeTypeEnumHelper::Map(signalType);
        for (int i = 0; i < _tradesStore.Count(); i++)
        {
            // Get trade
            CKeyValuePair<ulong, TradeTypeEnum> *trade = _tradesStore.Get(i);

            _logger.Log(
                DEBUG,
                __FUNCTION__,
                "Trade type: " + EnumToString(trade.Value()) +
                    ", signal type: " + EnumToString(signalType) +
                    ", trade ticket: " + (string)trade.Key());

            if (trade.Value() != tradeType)
            {
                continue;
            }

            // Delete order
            const ulong tradeTicket = trade.Key();
            if (OrderSelect(tradeTicket))
            {
                _market.OrderDelete(tradeTicket);
            }
            // Close position
            else if (PositionSelectByTicket(tradeTicket))
            {
                _market.PositionClose(tradeTicket);
            }
            // Trade closed from user or another EA
            else
            {
                // Info log
                _logger.Log(
                    INFO,
                    __FUNCTION__,
                    "Removing stored trade not found, ticket: " + (string)tradeTicket);

                // Remove from store
                _tradesStore.Remove(trade, 1);

                // Adjust loop index and exit
                i--;
                continue;
            }

            // Check result
            if (IsResultRetcode(TRADE_RETCODE_DONE))
            {
                continue;
            }

            // Trades might not be closed due to market close condition
            _tradesToVoidStore.Append(tradeTicket);
        }
    }

    /**
     * Open a new position or order in the market.
     */
    void Execute(TradeSignalTypeEnum signalType, TradeLevels &tradeLevels)
    {
        // Exit if signal is not an "open" type
        if (!TradeSignalTypeEnumHelper::IsOpenType(signalType))
        {
            _logger.Log(ERROR, __FUNCTION__, "Unsupported open signal type: " + EnumToString(signalType));
            return;
        }
        // If open at market type, execute it and then exit
        else if (TradeSignalTypeEnumHelper::IsOpenAtMarketType(signalType))
        {
            // Execute market position
            this.ExecuteInternal(
                signalType,
                tradeLevels.TakeProfit,
                tradeLevels.StopLoss);

            return;
        }
        // Exit if entry price is not set
        else if (tradeLevels.OrderEntryPrice <= 0)
        {
            _logger.Log(ERROR, __FUNCTION__, "Invalid order price");
            return;
        }

        this.ExecuteInternal(
            signalType,
            tradeLevels.TakeProfit,
            tradeLevels.StopLoss,
            tradeLevels.OrderEntryPrice,
            tradeLevels.OrderTypeTime,
            tradeLevels.OrderExpriation);
    }

    /**
     * Completes trade voidance, ensure all trades that received a close or delete signal are
     * voided.
     */
    void CompleteTradeVoidance()
    {
        if (_tradesToVoidStore.Count() == 0)
        {
            return;
        }

        for (int i = 0; i < _tradesToVoidStore.Count(); i++)
        {
            const ulong tradeTicket = _tradesToVoidStore.Get(i);

            // Delete order
            if (OrderSelect(tradeTicket))
            {
                _market.OrderDelete(tradeTicket);
            }
            // Close position
            else if (PositionSelectByTicket(tradeTicket))
            {
                _market.PositionClose(tradeTicket);
            }
            // Trade closed from user or another EA
            else
            {
                // Info log
                _logger.Log(
                    ERROR,
                    __FUNCTION__,
                    "Stored trade not found, ticket: " + (string)tradeTicket);

                // Remove from store
                _tradesToVoidStore.Remove(tradeTicket);

                // Adjust loop index and exit
                i--;
                continue;
            }

            // Check result
            if (!IsResultRetcode(TRADE_RETCODE_PLACED))
            {
                continue;
            }

            // Remove from store
            _tradesToVoidStore.Remove(tradeTicket);

            // Adjust loop index and exit
            i--;
        }
    }

    /**
     * Update position levels.
     */
    void UpdatePositionLevels()
    {
        // Disabled
        int tradeStoreCount = _tradesStore.Count();
        if (_tradeManagerParams.BreakEvenAtPointsInProfit <= 0
            // No trades in store
            || tradeStoreCount == 0)
        {
            return;
        }

        for (int i = 0; i < tradeStoreCount; i++)
        {
            // Variables for readability
            CKeyValuePair<ulong, TradeTypeEnum> *trade = _tradesStore.Get(i);

            // Transform opened pending orders values in order values
            TradeTypeEnum tradeValue = trade.Value();
            if ((tradeValue != TRADE_TYPE_BUY && tradeValue != TRADE_TYPE_SELL))
            {
                // Try select postion
                if (!PositionSelectByTicket(trade.Key()))
                {
                    // Skip, still pending order
                    continue;
                }

                // Conver trade value from pending to position
                TradeTypeEnum newTradeType = TradeTypeEnumHelper::IsLong(tradeValue)
                                                 ? TradeTypeEnum::TRADE_TYPE_BUY
                                                 : TradeTypeEnum::TRADE_TYPE_SELL;

                // Set value
                trade.Value(newTradeType);
            }

            // Open position check
            bool isLong = tradeValue == TRADE_TYPE_BUY;
            BreakEvenExecutionModeEnum breakEvenExecutionMode = _tradeManagerParams.BreakEvenExecutionMode;
            if ((tradeValue != TRADE_TYPE_BUY && tradeValue != TRADE_TYPE_SELL)
                // Trade type and execution mode check
                || (breakEvenExecutionMode == BreakEvenExecutionModeEnum::BUY_POSITIONS && !isLong)
                // Trade type and execution mode check
                || (breakEvenExecutionMode == BreakEvenExecutionModeEnum::SELL_POSITIONS && isLong))
            {
                continue;
            }

            // Skip and remove from store if position cannot be selected
            if (!PositionSelectByTicket(trade.Key()))
            {
                _tradesStore.Remove(trade, 1);

                // Adjust index since trade store count got reduced
                i--;
                tradeStoreCount--;
                continue;
            }

            // Calculate position p/l points
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            double currentPrice = isLong ? MarketHelper::GetBidPrice(_contextParams.Symbol)
                                         : MarketHelper::GetAskPrice(_contextParams.Symbol);
            // Skip if position is in loss
            if ((isLong && currentPrice <= openPrice)
                //
                || (!isLong && currentPrice >= openPrice))
            {
                continue;
            }

            // Skip if position profit is less then break event points required
            if (MathAbs(openPrice - currentPrice) < (_tradeManagerParams.BreakEvenAtPointsInProfit * _contextParams.Points))
            {
                continue;
            }

            // Skip if position stop loss is already at break even or in profit
            double stopLossPrice = PositionGetDouble(POSITION_SL);
            if (stopLossPrice != 0
                //
                && ((isLong && stopLossPrice >= openPrice)
                    //
                    || (!isLong && stopLossPrice <= openPrice)))
            {
                // Note:
                //  This check implicitly avoid the error: TRADE_RETCODE_NO_CHANGES
                continue;
            }

            // Validate trade freeze level
            if (!this.ValidateSymbolTradeFreezeLevel(currentPrice, openPrice, trade.Key()))
            {
                continue;
            }

            // Update order
            _market.PositionModify(
                trade.Key(),
                openPrice,
                PositionGetDouble(POSITION_TP));

            // Check result
            if (!IsResultRetcode(TRADE_RETCODE_DONE))
            {
                _logger.Log(ERROR, __FUNCTION__, "Setting break even failed with error: " + (string)GetLastError());
                return;
            }
        }
    }

    /**
     * Close all position with matching symbol and magic number
     */
    void PositionCloseAll()
    {
        // For all open positions
        for (int i = PositionsTotal() - 1; i >= 0; i--)
        {
            // Select current position
            ulong ticket = PositionGetTicket(i);
            if (PositionSelectByTicket(ticket))
            {
                // Compare magic and symbol of position
                if (PositionGetInteger(POSITION_MAGIC) == _magicNumber)
                {
                    _market.PositionClose(ticket);
                }
            }
        }
    }

    /**
     * Delete all orders with matching symbol and magic number
     */
    void OrderDeleteAll()
    {
        // For all placed orders
        for (int i = 0; i < OrdersTotal(); i++)
        {
            // Select order
            ulong ticket = OrderGetTicket(i);
            if (OrderSelect(ticket))
            {
                // Compare order's magic and symbol
                if (OrderGetInteger(ORDER_MAGIC) == _magicNumber)
                {
                    _market.OrderDelete(ticket);
                }
            }
        }
    }

    /**
     * Close all flat positions with matching symbol and magic number.
     */
    void CloseFlatMediationPositions()
    {
        if (_tradesStore.Count() == 0)
        {
            return;
        }

        // For all open positions
        int longMediationPositionsCount = 0;
        double longPositionProfit = 0;
        int shortMediationPositionsCount = 0;
        double shortPositionProfit = 0;
        for (int i = 0; i < _tradesStore.Count(); i++)
        {
            // Get trade
            CKeyValuePair<ulong, TradeTypeEnum> *trade = _tradesStore.Get(i);

            // Select position
            if (!PositionSelectByTicket(trade.Key()))
            {
                // Remove from store
                _tradesStore.Remove(trade, 1);

                // Adjust loop index and exit
                i--;
                continue;
            }

            // Check if position is flat
            if (trade.Value() == TRADE_TYPE_BUY)
            {
                // If position dose not have tp or sl set its a mediation position
                if (PositionGetDouble(POSITION_SL) == 0 && PositionGetDouble(POSITION_TP) == 0)
                {
                    longMediationPositionsCount++;
                }

                // Add profit to total profit
                longPositionProfit += PositionGetDouble(POSITION_PROFIT);
            }
            else if (trade.Value() == TRADE_TYPE_SELL)
            {
                // If position dose not have tp or sl set its a mediation position
                if (PositionGetDouble(POSITION_SL) == 0 && PositionGetDouble(POSITION_TP) == 0)
                {
                    shortMediationPositionsCount++;
                }

                // Add profit to total profit
                shortPositionProfit += PositionGetDouble(POSITION_PROFIT);
            }
        }

        // Close long positions
        if (longMediationPositionsCount > 0 && longPositionProfit >= 0)
        {
            for (int i = 0; i < _tradesStore.Count(); i++)
            {
                // Get trade
                CKeyValuePair<ulong, TradeTypeEnum> *trade = _tradesStore.Get(i);
                if (trade.Value() == TRADE_TYPE_BUY)
                {
                    _market.PositionClose(trade.Key());
                }
            }
        }

        // Close short positions
        if (shortMediationPositionsCount > 0 && shortPositionProfit >= 0)
        {
            for (int i = 0; i < _tradesStore.Count(); i++)
            {
                // Get trade
                CKeyValuePair<ulong, TradeTypeEnum> *trade = _tradesStore.Get(i);
                if (trade.Value() == TRADE_TYPE_SELL)
                {
                    _market.PositionClose(trade.Key());
                }
            }
        }
    }

private:
    /**
     * Open market position and check result code
     */
    void ExecuteInternal(
        TradeSignalTypeEnum signalType,
        double takeProfit,
        double stopLoss)
    {
        // Normalize prices
        takeProfit = NormalizeDouble(takeProfit, _contextParams.Digits);
        stopLoss = NormalizeDouble(stopLoss, _contextParams.Digits);

        string symbol = _contextParams.Symbol;
        double openPrice;
        if (signalType == OPEN_BUY_MARKET)
        {
            openPrice = MarketHelper::GetAskPrice(_contextParams.Symbol);
        }
        else if (signalType == OPEN_SELL_MARKET)
        {
            openPrice = MarketHelper::GetBidPrice(_contextParams.Symbol);
        }
        else
        {
            _logger.Log(ERROR, __FUNCTION__, "Unsupported signal type: " + EnumToString(signalType));
            return;
        }

        double volume = _riskManager.GetTradeVolume(signalType, openPrice, stopLoss);

        if (!this.ValidateTrade(signalType, volume, openPrice, stopLoss, takeProfit))
        {
            return;
        }

        const double maxAllowedLots = SymbolInfoDouble(_contextParams.Symbol, SYMBOL_VOLUME_MAX);

        // Consume all required volume
        while (volume > SymbolInfoDouble(_contextParams.Symbol, SYMBOL_VOLUME_MIN))
        {
            double volumeToOpen = volume > maxAllowedLots
                                      ? maxAllowedLots
                                      : volume;

            _logger.Log(
                DEBUG,
                __FUNCTION__,
                "Opening trade with voulme: " + (string)volumeToOpen + "/" + (string)volume);

            // Send trade
            if (signalType == OPEN_BUY_MARKET)
            {
                _market.Buy(
                    volumeToOpen,
                    symbol,
                    openPrice,
                    stopLoss,
                    takeProfit,
                    _tradeManagerParams.Comment);
            }
            else
            {
                _market.Sell(
                    volumeToOpen,
                    symbol,
                    openPrice,
                    stopLoss,
                    takeProfit,
                    _tradeManagerParams.Comment);
            }

            // Check result
            if (!IsResultRetcode(TRADE_RETCODE_DONE))
            {
                _logger.Log(ERROR, __FUNCTION__, "Trade failed with error: " + (string)GetLastError());
                return;
            }

            // Store into trades tickets store
            _tradesStore.Append(
                new CKeyValuePair<ulong, TradeTypeEnum>(
                    _market.ResultDeal(),
                    TradeTypeEnumHelper::Map(signalType)));

            volume -= volumeToOpen;
        }

        _logger.Log(DEBUG, __FUNCTION__, "Return");
    }

    /**
     * Place market order and check result code
     */
    void ExecuteInternal(
        TradeSignalTypeEnum signalType,
        double takeProfit,
        double stopLoss,
        double orderEntryPrice,
        ENUM_ORDER_TYPE_TIME orderTypeTime,
        datetime orderExpiration)
    {
        _logger.Log(
            DEBUG,
            __FUNCTION__,
            "Opening order with entry price: " + (string)orderEntryPrice +
                ", stop loss: " + (string)stopLoss +
                ", take profit: " + (string)takeProfit);

        // Normalize prices
        takeProfit = NormalizeDouble(takeProfit, _contextParams.Digits);
        stopLoss = NormalizeDouble(stopLoss, _contextParams.Digits);
        orderEntryPrice = NormalizeDouble(orderEntryPrice, _contextParams.Digits);

        // Get trade volume
        double volume = _riskManager.GetTradeVolume(signalType, orderEntryPrice, stopLoss);

        if (!this.ValidateTrade(signalType, volume, orderEntryPrice, stopLoss, takeProfit))
        {
            return;
        }

        const double maxAllowedLots = SymbolInfoDouble(_contextParams.Symbol, SYMBOL_VOLUME_MAX);

        // Consume all required volume
        string symbol = _contextParams.Symbol;
        while (volume > SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN))
        {
            double volumeToOpen = volume > maxAllowedLots
                                      ? maxAllowedLots
                                      : volume;

            // Place order
            if (signalType == OPEN_BUY_LIMIT_ORDER)
            {
                _market.BuyLimit(
                    volumeToOpen,
                    orderEntryPrice,
                    symbol,
                    stopLoss,
                    takeProfit,
                    orderTypeTime,
                    orderExpiration,
                    _tradeManagerParams.Comment);
            }
            else if (signalType == OPEN_BUY_STOP_ORDER)
            {
                _market.BuyStop(
                    volumeToOpen,
                    orderEntryPrice,
                    symbol,
                    stopLoss,
                    takeProfit,
                    orderTypeTime,
                    orderExpiration,
                    _tradeManagerParams.Comment);
            }
            else if (signalType == OPEN_SELL_LIMIT_ORDER)
            {
                _market.SellLimit(
                    volumeToOpen,
                    orderEntryPrice,
                    symbol,
                    stopLoss,
                    takeProfit,
                    orderTypeTime,
                    orderExpiration,
                    _tradeManagerParams.Comment);
            }
            else if (signalType == OPEN_SELL_STOP_ORDER)
            {
                _market.SellStop(
                    volumeToOpen,
                    orderEntryPrice,
                    symbol,
                    stopLoss,
                    takeProfit,
                    orderTypeTime,
                    orderExpiration,
                    _tradeManagerParams.Comment);
            }
            else
            {
                _logger.Log(ERROR, __FUNCTION__, "Unsupported signal type: " + EnumToString(signalType));
                return;
            }

            // Check result
            if (!IsResultRetcode(TRADE_RETCODE_DONE))
            {
                _logger.Log(ERROR, __FUNCTION__, "Trade failed with error: " + (string)GetLastError());
                return;
            }

            _logger.Log(
                DEBUG,
                __FUNCTION__,
                "Trade opened with ticket: " + (string)_market.ResultOrder());

            // Store into trades tickets store
            _tradesStore.Append(
                new CKeyValuePair<ulong, TradeTypeEnum>(
                    _market.ResultOrder(),
                    TradeTypeEnumHelper::Map(signalType)));

            volume -= volumeToOpen;
        }
    }

    /**
     * Check trade request result with provided ret code.
     */
    bool IsResultRetcode(uint retcode)
    {
        // Check result
        uint result = _market.ResultRetcode();
        if (result != retcode)
        {
            // Failure message
            _logger.Log(
                ERROR,
                __FUNCTION__,
                "Action failed. Return code=" + (string)result + ". Code description: " + _market.ResultRetcodeDescription());

            // Exit
            return false;
        }

        _logger.Log(
            INFO,
            __FUNCTION__,
            "Action completed. Return code=" + (string)result + ". Code description: " + _market.ResultRetcodeDescription());

        return true;
    };

    /**
     * Perform all needed checks before opening a trade operation.
     */
    bool ValidateTrade(TradeSignalTypeEnum signalType,
                       double volume,
                       double price,
                       double stopLoss,
                       double takeProfit)
    {
        bool isLong = TradeTypeEnumHelper::IsLong(signalType);

        // Trade levels
        if (!this.ValidateTradeLevels(isLong, price, stopLoss, takeProfit))
        {
            return false;
        }

        // Max pending orders
        if (!TradeSignalTypeEnumHelper::IsMarketType(signalType) && !this.ValidateNumberOfPendingOrders(volume))
        {
            return false;
        }

        // Trade volume
        if (!this.ValidateTradeVolume(volume))
        {
            return false;
        }

        // Account margin availability
        if (!this.ValidateRequiredMargin(
                isLong,
                volume,
                price,
                stopLoss,
                takeProfit))
        {
            return false;
        }

        // Symbol max allowed volume
        if (!this.ValidateSymbolMaxExposure(isLong, volume))
        {
            return false;
        }

        return true;
    }

    /**
     * Validate trade take profit, stopLoss and entry price levels.
     */
    bool ValidateTradeLevels(bool isLong, double entryPrice, double stopLoss, double takeProfit)
    {
        double pointsAdjustedStopsLevel = (int)SymbolInfoInteger(_contextParams.Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _contextParams.Points;

        // Check take profit
        if (MathAbs(entryPrice - takeProfit) < pointsAdjustedStopsLevel)
        {
            _logger.Log(ERROR, __FUNCTION__, "Invalid take profit, closer then allowed by SYMBOL_TRADE_STOPS_LEVEL");
            return false;
        }

        // Check stop loss
        if (MathAbs(entryPrice - stopLoss) < pointsAdjustedStopsLevel)
        {
            _logger.Log(ERROR, __FUNCTION__, "Invalid stop loss, closer then allowed by SYMBOL_TRADE_STOPS_LEVEL");
            return false;
        }

        double upperLevel = isLong ? takeProfit : stopLoss;
        if (upperLevel != 0 && upperLevel < entryPrice)
        {
            _logger.Log(ERROR, __FUNCTION__, "Invalid upper level, isLong? " + (string)isLong);
            return false;
        }

        double lowerLevel = isLong ? stopLoss : takeProfit;
        if (lowerLevel != 0 && lowerLevel > entryPrice)
        {
            _logger.Log(ERROR, __FUNCTION__, "Invalid lower level, isLong? " + (string)isLong);
            return false;
        }

        return true;
    }

    /**
     * Validate account max number of allowed pending orders
     */
    bool ValidateNumberOfPendingOrders(double volume)
    {
        // Get the number of pending orders allowed on the account
        int maxAllowedOrders = (int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);

        // No limitation, return true
        if (maxAllowedOrders == 0)
        {
            return true;
        }

        int currentOpenOrders = OrdersTotal();

        double totalOdersToOpen = MathHelper::SafeDivision(
            _logger,
            volume,
            SymbolInfoDouble(_contextParams.Symbol, SYMBOL_VOLUME_MAX));

        return ((currentOpenOrders + totalOdersToOpen) < maxAllowedOrders);
    }

    /**
     * Validate account margin.
     */
    bool ValidateRequiredMargin(bool isLong,
                                double volume,
                                double price,
                                double stopLoss,
                                double takeProfit)
    {
        // Free margin
        const double free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);

        // Calculate required margin
        double margin;
        if (!OrderCalcMargin(
                isLong ? ORDER_TYPE_BUY : ORDER_TYPE_SELL,
                _contextParams.Symbol,
                volume,
                price,
                margin))
        {
            _logger.Log(ERROR, __FUNCTION__, "OrderCalcProfit: " + (string)GetLastError());
            return false;
        }

        // Check funds
        if (margin > free_margin)
        {
            _logger.Log(ERROR, __FUNCTION__, "Insufficient margin!");
            return false;
        }
        //--- checking successful
        return true;
    }

    /**
     * Validate trade volume.
     */
    bool ValidateTradeVolume(double volume)
    {
        // Minimal allowed volume for trade operations
        string symbol = _contextParams.Symbol;
        double minVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
        if (volume < minVolume)
        {
            _logger.Log(ERROR, __FUNCTION__, StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f", minVolume));
            return false;
        }

        // Exit if full lots consumption is allowed
        if (_tradeManagerParams.ConsumeAllCalculatedLots)
        {
            return true;
        }

        // Maximal allowed volume of trade operations
        double maxVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
        if (volume > maxVolume)
        {
            _logger.Log(ERROR, __FUNCTION__, StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f", maxVolume));
            return false;
        }

        // NOTE: minimal step error is handled by risk manager that rounds
        // trade volume to the closest multiple of symbol volume step
        return true;
    }

    /**
     * Validate symbol max allowed volume
     */
    bool ValidateSymbolMaxExposure(bool isLong, double newTradeVolume)
    {
        // Get the limitation on the volume by a symbol
        double maxVolume = SymbolInfoDouble(_contextParams.Symbol, SYMBOL_VOLUME_LIMIT);

        // No limitation, return true
        if (maxVolume == 0)
        {
            return true;
        }

        double currentTotalVolume = this.GetSymbolVolumeExposureByDirection(isLong);

        if (maxVolume - (currentTotalVolume + newTradeVolume) > 0)
        {
            return true;
        }

        _logger.Log(ERROR, __FUNCTION__, "Would exceed maximal allowed SYMBOL_VOLUME_LIMIT=" + (string)maxVolume);
        return false;
    }

    /**
     * Validate order levels edit request is not within trade freeze levels.
     * @param currentPrice is the ask (buy orders) or bid (sell orders) price
     * @param orderPrice is the price of any type of pending order, take profit and stop loss
     * included.
     */
    bool ValidateSymbolTradeFreezeLevel(double currentPrice, double orderPrice, ulong tradeTicket)
    {
        if (MathAbs(orderPrice - currentPrice) <= _symbolTradeFreezeLevel)
        {
            _logger.Log(
                ERROR,
                __FUNCTION__,
                "Order (" + (string)tradeTicket + ") cannot be modified, orderd price is within trade freeze level");

            return false;
        }

        return true;
    }

    /**
     * Calculate total open volume exposure on the requested symbol
     * for both positions and orders.
     */
    double GetSymbolVolumeExposureByDirection(bool isLong)
    {
        double totalVolume = 0;

        // For all open positions
        for (int i = PositionsTotal() - 1; i >= 0; i--)
        {
            // Select current position
            ulong ticket = PositionGetTicket(i);
            if (PositionSelectByTicket(ticket))
            {
                // Compare symbol of position
                if (PositionGetString(POSITION_SYMBOL) == _contextParams.Symbol)
                {
                    // Get position type
                    ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)(PositionGetInteger(POSITION_TYPE));

                    ENUM_POSITION_TYPE selectedType = isLong ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
                    if (positionType == selectedType)
                    {
                        totalVolume += PositionGetDouble(POSITION_VOLUME);
                    }
                }
            }
        }

        // For all placed orders
        for (int i = 0; i < OrdersTotal(); i++)
        {
            // Select order
            ulong ticket = OrderGetTicket(i);
            if (OrderSelect(ticket))
            {
                // Compare symbol
                if (OrderGetString(ORDER_SYMBOL) == _contextParams.Symbol)
                {
                    // Get type
                    ENUM_ORDER_TYPE orderType = (ENUM_ORDER_TYPE)(OrderGetInteger(ORDER_TYPE));

                    if ((isLong && (orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP)) || (!isLong && (orderType == ORDER_TYPE_SELL_LIMIT || orderType == ORDER_TYPE_SELL_STOP)))
                    {
                        totalVolume += PositionGetDouble(POSITION_VOLUME);
                    }
                }
            }
        }

        return totalVolume;
    }

    /**
     * Find all positions with matching magic number and symbol
     */
    void RetriveOpenPositions()
    {
        // For all open positions
        for (int i = PositionsTotal() - 1; i >= 0; i--)
        {
            // Select current position
            ulong ticket = PositionGetTicket(i);
            if (PositionSelectByTicket(ticket))
            {
                // Compare magic and symbol of position
                if (PositionGetInteger(POSITION_MAGIC) == _magicNumber && PositionGetString(POSITION_SYMBOL) == _contextParams.Symbol)
                {
                    // Get position type
                    ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)(PositionGetInteger(POSITION_TYPE));

                    // Store into trades tickets store
                    _tradesStore.Append(
                        new CKeyValuePair<ulong, TradeTypeEnum>(
                            ticket,
                            TradeTypeEnumHelper::Map(positionType)));

                    // Info log
                    _logger.Log(
                        INFO,
                        __FUNCTION__,
                        "Found position with ticket: " + (string)ticket);
                }
            }
        }
    }

    /**
     * Find all orders with matching magic number and symbol
     */
    void RetriveOpenOrders()
    {
        // For all placed orders
        for (int i = 0; i < OrdersTotal(); i++)
        {
            // Select order
            ulong ticket = OrderGetTicket(i);
            if (OrderSelect(ticket))
            {
                // Compare order's magic and symbol
                if (OrderGetInteger(ORDER_MAGIC) == _magicNumber && OrderGetString(ORDER_SYMBOL) == _contextParams.Symbol)
                {
                    // Get order type
                    ENUM_ORDER_TYPE orderType = (ENUM_ORDER_TYPE)(OrderGetInteger(ORDER_TYPE));

                    // Store into trades tickets store
                    _tradesStore.Append(
                        new CKeyValuePair<ulong, TradeTypeEnum>(
                            ticket,
                            TradeTypeEnumHelper::Map(orderType)));

                    // Info log
                    _logger.Log(
                        INFO,
                        __FUNCTION__,
                        "Found order with ticket: " + (string)ticket);
                }
            }
        }
    }
}