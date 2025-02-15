#include "../BaseIndicator.mqh";
#include "./Models/ExposureStatusIndicatorSignalsEnum.mqh";

class ExposureStatusIndicator : public BaseSignalProvider<ExposureStatusIndicatorSignalsEnum>
{
private:
    /**
     * Expert advisor unique identifier.
     */
    const ulong _magicNumber;

    /**
     * Stored ticket to speed up open positions and orders checks.
     */
    ulong _storedTicket;

public:
    /**
     * Constructor
     */
    ExposureStatusIndicator(
        Logger &logger,
        string symbol,
        ObjectList<CKeyValuePair<TradeSignalTypeEnum, ExposureStatusIndicatorSignalsEnum>> &signalTypeTriggerStore,
        ulong magicNumber)
        : _magicNumber(magicNumber),
          _storedTicket(0),
          BaseSignalProvider(&logger, symbol, signalTypeTriggerStore)
    {
        _logger.LogInitCompleted(__FUNCTION__);
    }

    /**
     * Deconstructor
     */
    ~ExposureStatusIndicator()
    {
        this.BaseIndicatorDeconstructor();
    }

protected:
    /**
     * Base class method override.
     */
    bool IsIndicatorValidSignal(ExposureStatusIndicatorSignalsEnum signalType) override
    {
        switch (signalType)
        {
        case NOT_ANY_OPEN_POSITION:
            return !IsAnyPositionOpen();

        case NOT_ANY_BUY_POSITIONS:
            return !IsAnyPositionOpen(1);

        case NOT_ANY_SELL_POSITIONS:
            return !IsAnyPositionOpen(-1);

        case NOT_ANY_PLACED_ORDER:
            return !IsAnyOrderPlaced();

        default:
            return false;
        };
    }

private:
    /**
     * Check for open positions by magic num, return true if one open position is found
     */
    bool IsAnyPositionOpen(int direction = 0)
    {
        // Check stored ticket first
        if (direction == 0 && PositionSelectByTicket(_storedTicket))
        {
            return true;
        }

        // For all open positions
        for (int i = PositionsTotal() - 1; i >= 0; i--)
        {
            // Select current position
            ulong ticket = PositionGetTicket(i);
            if (PositionSelectByTicket(ticket))
            {
                // Check with magic number
                if (PositionGetInteger(POSITION_MAGIC) == _magicNumber)
                {
                    if (direction == 0)
                    {
                        _storedTicket = ticket;
                        return true;
                    }

                    // Get position type
                    ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)(PositionGetInteger(POSITION_TYPE));

                    ENUM_POSITION_TYPE selectedType = direction == 1 ? POSITION_TYPE_BUY
                                                                     : POSITION_TYPE_SELL;
                    if (positionType == selectedType)
                    {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    /**
     * Check for placed orders by magic num, return true if one placed order is found
     */
    bool IsAnyOrderPlaced()
    {
        // Check stored ticket first
        if (OrderSelect(_storedTicket))
        {
            return true;
        }

        // For all placed orders
        for (int i = 0; i < OrdersTotal(); i++)
        {
            // Select order
            ulong ticket = OrderGetTicket(i);
            if (OrderSelect(ticket))
            {
                // Check with magic number
                if (OrderGetInteger(ORDER_MAGIC) == _magicNumber)
                {
                    _storedTicket = ticket;
                    return true;
                }
            }
        }

        return false;
    }
}