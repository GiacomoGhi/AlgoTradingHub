#include "../../Libraries/List/ObjectList.mqh";
#include "../../Libraries/List/BasicList.mqh";
#include "../../Shared/Models/ContextParams.mqh";
#include "../../Shared/Models/TradeLevels.mqh";
#include "../../Shared/Logger/Logger.mqh";
#include "../../Shared/Helpers/TradeSignalTypeEnumHelper.mqh";
#include "../../Shared/Helpers/MarketHelper.mqh";
#include "../RiskManager/RiskManager.mqh"
#include "./Models/TradeManagerParams.mqh";
#include "./Models/TradeTypeEnumHelper.mqh";
#include <Generic/HashMap.mqh>
#include <Trade/Trade.mqh>;

class TradeManager
{
private:
    /**
     * Name of the class.
     */
    const string _className;

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
        RiskManager &riskManager,
        string className = "TradeManager")
        : _className(className),
          _logger(&logger),
          _contextParams(&contextParams),
          _magicNumber(tradeManagerParams.MagicNumber),
          _comment(tradeManagerParams.Comment),
          _riskManager(&riskManager)
    {
        _market.SetExpertMagicNumber(tradeManagerParams.MagicNumber);

        // Initialize trades stores
        _tradesStore = new ObjectList<CKeyValuePair<ulong, TradeTypeEnum>>();
        _tradesToVoidStore = new BasicList<ulong>();

        // Check for old positions and orders
        RetriveOpenPositions();
        RetriveOpenOrders();

        _logger.LogInitCompleted(_className);
    };

    /**
     * Close or delete singals only,
     * overload with TradeLevels to execute a new position or order.
     */
    void Execute(TradeSignalTypeEnum signalType)
    {
        if (TradeSignalTypeEnumHelper::IsOpenType(signalType))
        {
            _logger.Log(ERROR, _className, "Unsupported signal type");
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
                    _className,
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
            _logger.Log(ERROR, _className, "Unsupported signal type");
            return;
        }
        // If open at market type, execute it and then exit
        else if (TradeSignalTypeEnumHelper::IsOpenAtMarketType(signalType))
        {
            // TODO validate trade levels
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
            _logger.Log(ERROR, _className, "Invalid order price");
            return;
        }

        // TODO validate trade levels
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
                    _className,
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
        // TODO validate trade levels
        // TODO see https://www.mql5.com/en/articles/2555 for all the check that an EA must do before being published to the market

        // Normalize prices
        takeProfit = NormalizeDouble(takeProfit, _contextParams.Digits);
        stopLoss = NormalizeDouble(stopLoss, _contextParams.Digits);

        // Send trade
        string symbol = _contextParams.Symbol;
        if (signalType == OPEN_BUY_MARKET)
        {
            double askPrice = MarketHelper::GetAskPrice(_contextParams.Symbol);

            _market.Buy(
                _riskManager
                    .GetTradeVolume(askPrice, stopLoss),
                symbol,
                askPrice,
                stopLoss,
                takeProfit,
                _comment);
        }
        else if (signalType == OPEN_SELL_MARKET)
        {
            double bidPrice = MarketHelper::GetBidPrice(_contextParams.Symbol);

            _market.Sell(
                _riskManager
                    .GetTradeVolume(bidPrice, stopLoss),
                symbol,
                bidPrice,
                stopLoss,
                takeProfit,
                _comment);
        }

        // Check result
        if (!IsResultRetcode(TRADE_RETCODE_DONE))
        {
            return;
        }

        // Store into trades tickets store
        _tradesStore.Append(
            new CKeyValuePair<ulong, TradeTypeEnum>(
                _market.ResultDeal(),
                TradeTypeEnumHelper::Map(signalType)));
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
        double tradeVolume = _riskManager.GetTradeVolume(orderEntryPrice, stopLoss);

        // Place order
        string symbol = _contextParams.Symbol;
        if (signalType == OPEN_BUY_LIMIT_ORDER)
        {
            _market.BuyLimit(
                tradeVolume,
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
                tradeVolume,
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
                tradeVolume,
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
                tradeVolume,
                orderEntryPrice,
                symbol,
                stopLoss,
                takeProfit,
                orderTypeTime,
                orderExpiration,
                _comment);
        }

        // Check result
        if (!IsResultRetcode(TRADE_RETCODE_PLACED))
        {
            return;
        }

        // Store into trades tickets store
        _tradesStore.Append(
            new CKeyValuePair<ulong, TradeTypeEnum>(
                _market.ResultDeal(),
                TradeTypeEnumHelper::Map(signalType)));
    }

    /**
     * Check trade request result with provided ret code
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
                _className,
                "Action failed. Return code=" + (string)result + ". Code description: " + _market.ResultRetcodeDescription());

            // Exit
            return false;
        }

        _logger.Log(
            INFO,
            _className,
            "Action completed. Return code=" + (string)result + ". Code description: " + _market.ResultRetcodeDescription());

        return true;
    };

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
                        _className,
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
                        _className,
                        "Found order with ticket: " + (string)ticket);
                }
            }
        }
    }
}