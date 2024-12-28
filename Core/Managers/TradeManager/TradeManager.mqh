#include "../../Shared/Models/ContextParams.mqh";
#include "../../Shared/Models/TradeLevels.mqh";
#include "../../Shared/Logger/Logger.mqh";
#include "../../Shared/Helpers/TradeSignalTypeEnumHelper.mqh";
#include "../RiskManager/RiskManager.mqh"
#include "./Models/TradeManagerParams.mqh";
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
     * Risk manager used internally.
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

public:
    /**
     * Constructor.
     */
    TradeManager(
        Logger &logger,
        ContextParams &contextParams,
        TradeManagerParams &tradeManagerParams,
        RiskManagerParams &riskManagerParams,
        string className = "TradeManager")
        : _className(className),
          _logger(&logger),
          _contextParams(&contextParams),
          _magicNumber(tradeManagerParams.MagicNumber),
          _comment(tradeManagerParams.Comment)
    {
        _market.SetExpertMagicNumber(tradeManagerParams.MagicNumber);

        // Interally used risk manager
        _riskManager = new RiskManager(
            &logger,
            &contextParams,
            &riskManagerParams);

        // TODO Manage only positions or orders from context settings
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
        _logger.Log(INFO, _className, "Executing: " + EnumToString(signalType));

        if (TradeSignalTypeEnumHelper::IsOpenType(signalType))
        {
            _logger.Log(ERROR, _className, "Unsupported signal type");
            return;
        }

        // Close market position
        if (TradeSignalTypeEnumHelper::IsMarketType(signalType))
        {
            // Close buy
            if (signalType == CLOSE_BUY_MARKET && IsBuyPositionOpen())
            {
                _market.PositionClose(_buyPositionTicket);
            }
            // Close sell
            else if (signalType == CLOSE_SELL_MARKET && IsSellPositionOpen())
            {
                _market.PositionClose(_sellPositionTicket);
            }
        }
        // Delete order
        else
        {
            // Delete buy order
            if (signalType == DELETE_BUY_ORDER && IsBuyOrderPlaced())
            {
                _market.OrderDelete(_buyPositionTicket);
            }
            // Delete sell order
            else if (signalType == DELETE_SELL_ORDER && IsSellOrderPlaced())
            {
                _market.OrderDelete(_sellPositionTicket);
            }
        }

        // Check result
        IsResultRetcode(TRADE_RETCODE_DONE);
    }

    /**
     * Open a new position or order in the market.
     */
    void Execute(TradeSignalTypeEnum signalType, TradeLevels &tradeLevels)
    {
        _logger.Log(INFO, _className, "Executing: " + EnumToString(signalType));

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
                if (PositionGetInteger(POSITION_MAGIC) == _magicNumber && PositionGetString(POSITION_SYMBOL) == _contextParams.Symbol)
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
                if (OrderGetInteger(ORDER_MAGIC) == _magicNumber && OrderGetString(ORDER_SYMBOL) == _contextParams.Symbol)
                {
                    _market.OrderDelete(ticket);
                }
            }
        }
    }

    /**
     * Returns true if there is an active buy position
     */
    bool IsBuyPositionOpen()
    {
        return PositionSelectByTicket(_buyPositionTicket);
    }

    /**
     * Returns true if there is an active sell position
     */
    bool IsSellPositionOpen()
    {
        return PositionSelectByTicket(_sellPositionTicket);
    }

    /**
     * Returns true if there is an active buy order
     */
    bool IsBuyOrderPlaced()
    {
        return OrderSelect(_buyPositionTicket);
    }

    /**
     * Returns true if there is an active sell order
     */
    bool IsSellOrderPlaced()
    {
        return OrderSelect(_sellPositionTicket);
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
            double askPrice = GetAskPrice();

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
            double bidPrice = GetBidPrice();

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

        // Save position ticket
        if (signalType == OPEN_SELL_MARKET)
        {
            _sellPositionTicket = _market.ResultDeal();
        }
        else
        {
            _buyPositionTicket = _market.ResultDeal();
        }
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

        // Save order ticket
        if (signalType == OPEN_BUY_LIMIT_ORDER || signalType == OPEN_BUY_STOP_ORDER)
        {
            _buyPositionTicket = _market.ResultDeal();
        }
        else
        {
            _sellPositionTicket = _market.ResultDeal();
        }
    }

    // Get ask price
    double GetAskPrice()
    {
        return SymbolInfoDouble(_contextParams.Symbol, SYMBOL_ASK);
    };

    // Get bid price
    double GetBidPrice()
    {
        return SymbolInfoDouble(_contextParams.Symbol, SYMBOL_BID);
    };

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
                    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)(PositionGetInteger(POSITION_TYPE));

                    // Type buy
                    if (type == POSITION_TYPE_BUY)
                    {
                        _buyPositionTicket = ticket;
                    }
                    // Type sell
                    else if (type == POSITION_TYPE_SELL)
                    {
                        _sellPositionTicket = ticket;
                    }

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
                    ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)(OrderGetInteger(ORDER_TYPE));

                    // Type buy
                    if (type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_BUY_LIMIT)
                    {
                        _buyPositionTicket = ticket;
                    }
                    // Type sell
                    else
                    {
                        _sellPositionTicket = ticket;
                    }

                    _logger.Log(
                        INFO,
                        _className,
                        "Found order with ticket: " + (string)ticket);
                }
            }
        }
    }
}