#include "../../Shared/Models/ContextParams.mqh";
#include "./Models/TradeManagerParams.mqh";
#include "./Models/TradeOrderTypesEnum.mqh";
#include "./Models/TradePositionTypesEnum.mqh";
#include <Trade/Trade.mqh>;

class TradeManager
{
  private:
    // Constructor init
    ContextParams *_contextParams;
    CTrade _market;
    ulong _magicNumber;
    string _comment;

    // Internal properties
    ulong _buyPositionTicket;
    ulong _sellPositionTicket;

  public:
    // Constructor
    TradeManager(ContextParams &contextParams, TradeManagerParams &tradeManagerParams)
        : _contextParams(&contextParams),
          _magicNumber(tradeManagerParams.MagicNumber),
          _comment(tradeManagerParams.Comment)
    {
        _market.SetExpertMagicNumber(tradeManagerParams.MagicNumber);

        // Check for old positions or orders
        RetriveOpenPositions();
        RetriveOpenOrders();
    };

    // Open market position and check result code
    void Execute(
        TradePositionTypesEnum tradeTypeEnum,
        double lotSize,
        double stopLoss,
        double takeProfit = 0)
    {
        // Normalize prices
        takeProfit = NormalizeDouble(takeProfit, _contextParams.Digits);
        stopLoss = NormalizeDouble(stopLoss, _contextParams.Digits);

        // Send trade
        string symbol = _contextParams.Symbol;
        if (tradeTypeEnum == BuyPosition)
        {
            _market.Buy(lotSize, symbol, GetAskPrice(), stopLoss, takeProfit, _comment);
        }
        else if (tradeTypeEnum == SellPosition)
        {
            _market.Sell(lotSize, symbol, GetBidPrice(), stopLoss, takeProfit, _comment);
        }

        // Check result
        if (!IsResultRetcode(TRADE_RETCODE_DONE))
        {
            // TODO Use logger manager to log an error
            return;
        }

        // Save position ticket
        if (tradeTypeEnum == SellPosition)
        {
            _sellPositionTicket = _market.ResultDeal();
        }
        else
        {
            _buyPositionTicket = _market.ResultDeal();
        }
    }

    // Place market order and check result code
    void Execute(
        TradeOrderTypesEnum tradeTypeEnum,
        double lotSize,
        double price,
        double stopLoss,
        double takeProfit = 0,
        ENUM_ORDER_TYPE_TIME typeTime = ORDER_TIME_GTC,
        datetime expiration = 0)
    {
        // Normalize prices
        takeProfit = NormalizeDouble(takeProfit, _contextParams.Digits);
        stopLoss = NormalizeDouble(stopLoss, _contextParams.Digits);
        price = NormalizeDouble(price, _contextParams.Digits);

        // Place order
        string symbol = _contextParams.Symbol;
        if (tradeTypeEnum == BuyLimitOrder)
        {
            _market.BuyLimit(lotSize, price, symbol, stopLoss, takeProfit, typeTime, expiration, _comment);
        }
        else if (tradeTypeEnum == BuyStopOrder)
        {
            _market.BuyStop(lotSize, price, symbol, stopLoss, takeProfit, typeTime, expiration, _comment);
        }
        else if (tradeTypeEnum == SellLimitOrder)
        {
            _market.SellLimit(lotSize, price, symbol, stopLoss, takeProfit, typeTime, expiration, _comment);
        }
        else if (tradeTypeEnum == SellStopOrder)
        {
            _market.SellStop(lotSize, price, symbol, stopLoss, takeProfit, typeTime, expiration, _comment);
        }

        // Check result
        if (!IsResultRetcode(TRADE_RETCODE_PLACED))
        {
            return;
        }

        // Save order ticket
        if (tradeTypeEnum == BuyLimitOrder || tradeTypeEnum == BuyStopOrder)
        {
            _sellPositionTicket = _market.ResultDeal();
        }
        else
        {
            _buyPositionTicket = _market.ResultDeal();
        }
    }

    // Close market position by type
    void PositionClose(TradePositionTypesEnum tradeTypeEnum)
    {
        // Close buy
        if (tradeTypeEnum == BuyPosition && IsBuyPositionOpen())
        {
            _market.PositionClose(_buyPositionTicket);
        }
        // Close sell
        else if (tradeTypeEnum == SellPosition && IsSellPositionOpen())
        {
            _market.PositionClose(_sellPositionTicket);
        }

        // Check result
        IsResultRetcode(TRADE_RETCODE_DONE);
    }

    // Delete market position by direction type
    void OrderDelete(TradeOrderTypesEnum tradeTypeEnum)
    {
        // Delete buy order
        if ((tradeTypeEnum == BuyLimitOrder || tradeTypeEnum == BuyLimitOrder) && IsBuyOrderPlaced())
        {
            _market.OrderDelete(_buyPositionTicket);
        }
        // Delete sell order
        else if ((tradeTypeEnum == SellLimitOrder || tradeTypeEnum == SellStopOrder) && IsSellOrderPlaced())
        {
            _market.OrderDelete(_sellPositionTicket);
        }

        // Check result
        IsResultRetcode(TRADE_RETCODE_DONE);
    }

    // Close all position with matching symbol and magic number
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

    // Delete all orders with matching symbol and magic number
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

    // Returns true if there is an active buy position
    bool IsBuyPositionOpen()
    {
        return PositionSelectByTicket(_buyPositionTicket);
    }

    // Returns true if there is an active sell position
    bool IsSellPositionOpen()
    {
        return PositionSelectByTicket(_sellPositionTicket);
    }

    // Returns true if there is an active buy order
    bool IsBuyOrderPlaced()
    {
        return OrderSelect(_buyPositionTicket);
    }

    // Returns true if there is an active sell order
    bool IsSellOrderPlaced()
    {
        return OrderSelect(_sellPositionTicket);
    }

  private:
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

    // Check trade request result with provided ret code
    bool IsResultRetcode(uint retcode)
    {
        // Check result
        uint result = _market.ResultRetcode();
        if (result != retcode)
        {
            // Failure message
            Print("Action failed. Return code=", result,
                  ". Code description: ", _market.ResultRetcodeDescription());

            // Exit
            return false;
        }

        Print("Action completed. Return code=", result);
        return true;
    };

    // Find all positions with matching magic number and symbol
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

                    Print("Found position with ticket=", ticket);
                }
            }
        }
    }

    // Find all orders with matching magic number and symbol
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

                    Print("Found order with ticket=", ticket);
                }
            }
        }
    }
}