#include "../../Shared/Models/ContextParams.mqh";
#include "../RiskManager/RiskManager.mqh"
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
    RiskManager _riskManager;
    ulong _buyPositionTicket;
    ulong _sellPositionTicket;

  public:
    // Constructor
    TradeManager(ContextParams &contextParams, TradeManagerParams &tradeManagerParams)
        : _contextParams(&contextParams),
          _magicNumber(tradeManagerParams.MagicNumber),
          _comment(tradeManagerParams.Comment),
          _riskManager(&contextParams, tradeManagerParams.RiskManagerParams)
    {
        _market.SetExpertMagicNumber(tradeManagerParams.MagicNumber);

        // Check for old positions and orders
        RetriveOpenPositions();
        RetriveOpenOrders();
    };

    // Open market position and check result code
    void Execute(
        TradePositionTypesEnum tradeTypeEnum,
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
        if (tradeTypeEnum == BUY_POSITION)
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
        else if (tradeTypeEnum == SELL_POSITION)
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
            // TODO Use logger manager to log an error
            return;
        }

        // Save position ticket
        if (tradeTypeEnum == SELL_POSITION)
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
        double orderPrice,
        double takeProfit,
        double stopLoss,
        ENUM_ORDER_TYPE_TIME typeTime = ORDER_TIME_GTC,
        datetime expiration = 0)
    {
        // Normalize prices
        takeProfit = NormalizeDouble(takeProfit, _contextParams.Digits);
        stopLoss = NormalizeDouble(stopLoss, _contextParams.Digits);
        orderPrice = NormalizeDouble(orderPrice, _contextParams.Digits);

        // Get trade volume
        double tradeVolume = _riskManager.GetTradeVolume(orderPrice, stopLoss);

        // Place order
        string symbol = _contextParams.Symbol;
        if (tradeTypeEnum == BUY_LIMIT_ORDER)
        {
            _market.BuyLimit(
                tradeVolume,
                orderPrice,
                symbol,
                stopLoss,
                takeProfit,
                typeTime,
                expiration,
                _comment);
        }
        else if (tradeTypeEnum == BUY_STOP_ORDER)
        {
            _market.BuyStop(
                tradeVolume,
                orderPrice,
                symbol,
                stopLoss,
                takeProfit,
                typeTime,
                expiration,
                _comment);
        }
        else if (tradeTypeEnum == SELL_LIMIT_ORDER)
        {
            _market.SellLimit(
                tradeVolume,
                orderPrice,
                symbol,
                stopLoss,
                takeProfit,
                typeTime,
                expiration,
                _comment);
        }
        else if (tradeTypeEnum == SELL_STOP_ORDER)
        {
            _market.SellStop(
                tradeVolume,
                orderPrice,
                symbol,
                stopLoss,
                takeProfit,
                typeTime,
                expiration,
                _comment);
        }

        // Check result
        if (!IsResultRetcode(TRADE_RETCODE_PLACED))
        {
            return;
        }

        // Save order ticket
        if (tradeTypeEnum == BUY_LIMIT_ORDER || tradeTypeEnum == BUY_STOP_ORDER)
        {
            _buyPositionTicket = _market.ResultDeal();
        }
        else
        {
            _sellPositionTicket = _market.ResultDeal();
        }
    }

    // Close market position by type
    void PositionClose(TradePositionTypesEnum tradeTypeEnum)
    {
        // Close buy
        if (tradeTypeEnum == BUY_POSITION && IsBuyPositionOpen())
        {
            _market.PositionClose(_buyPositionTicket);
        }
        // Close sell
        else if (tradeTypeEnum == SELL_POSITION && IsSellPositionOpen())
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
        if ((tradeTypeEnum == BUY_LIMIT_ORDER || tradeTypeEnum == BUY_STOP_ORDER) && IsBuyOrderPlaced())
        {
            _market.OrderDelete(_buyPositionTicket);
        }
        // Delete sell order
        else if (IsSellOrderPlaced())
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