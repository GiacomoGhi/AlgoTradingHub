#include "../../Libraries/List/BasicList.mqh";
#include "../../Libraries/List/ObjectList.mqh";
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
     * String to use in trade comments.
     */
    string _comment;

    /**
     * Allow full calculated lots consumption if true.
     */
    bool _consumeAllCalculatedLots;

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
          _contextParams(&contextParams),
          _magicNumber(contextParams.MagicNumber),
          _comment(tradeManagerParams.Comment),
          _consumeAllCalculatedLots(tradeManagerParams.ConsumeAllCalculatedLots),
          _riskManager(&riskManager),
          _tradesStore(new ObjectList<CKeyValuePair<ulong, TradeTypeEnum>>),
          _tradesToVoidStore(new BasicList<ulong>)
    {
        // Set ea magic number
        _market.SetExpertMagicNumber(contextParams.MagicNumber);

        // Check for old positions and orders
        RetriveOpenPositions();
        RetriveOpenOrders();

        // Delte dto
        delete &tradeManagerParams;

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
    }

    /**
     * Select lastest position with given magicNumber
     */
    static bool SelectLatestPosition(Logger &logger, ulong magicNumber)
    {
        // For all open positions
        for (int i = PositionsTotal() - 1; i >= 0; i--)
        {
            // Select current position
            ulong ticket = PositionGetTicket(i);
            if (PositionSelectByTicket(ticket))
            {
                // Compare magic and symbol of position
                if (PositionGetInteger(POSITION_MAGIC) == magicNumber)
                {
                    logger.Log(DEBUG, __FUNCTION__, "Position ticket: " + (string)ticket);
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
            _logger.Log(ERROR, __FUNCTION__, "Unsupported signal type");
            return;
        }

        // Void trades with matching type
        TradeTypeEnum tradeType = TradeTypeEnumHelper::Map(signalType);
        for (int i = 0; i < _tradesStore.Count(); i++)
        {
            // Get trade
            CKeyValuePair<ulong, TradeTypeEnum> *trade = _tradesStore.Get(i);
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
                _tradesStore.Remove(trade);

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
            _logger.Log(ERROR, __FUNCTION__, "Unsupported signal type");
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
                    _comment);
            }
            else
            {
                _market.Sell(
                    volumeToOpen,
                    symbol,
                    openPrice,
                    stopLoss,
                    takeProfit,
                    _comment);
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
                    _comment);
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
                    _comment);
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
                    _comment);
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
                    _comment);
            }
            else
            {
                _logger.Log(ERROR, __FUNCTION__, "Unsupported signal type: " + EnumToString(signalType));
                return;
            }

            // Check result
            if (!IsResultRetcode(TRADE_RETCODE_PLACED))
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
        if (_consumeAllCalculatedLots)
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