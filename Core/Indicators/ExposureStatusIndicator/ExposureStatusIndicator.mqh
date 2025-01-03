#include "../BaseIndicator.mqh";
#include "./Models/ExposureStatusIndicatorSignalsEnum.mqh";

class ExposureStatusIndicator : public BaseIndicator<ExposureStatusIndicatorSignalsEnum>
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
        ulong magicNumber,
        CHashMap<TradeSignalTypeEnum, ExposureStatusIndicatorSignalsEnum> &signalTypeTriggerStore,
        string className = "ExposureStatusIndicator")
        : _magicNumber(magicNumber),
          _storedTicket(0),
          BaseIndicator(className, &logger, symbol, signalTypeTriggerStore)
    {
        _logger.LogInitCompleted(_className);
    }

    /**
     * Deconstructor
     */
    ~ExposureStatusIndicator()
    {
        this.BaseIndicatorDeconstructor();
    }

    /**
     * Base class ITradeSignalProvider implementation
     */
    void UpdateSignalStore(CHashMap<TradeSignalTypeEnum, bool> &signalsStore) override
    {
        for (int i = 0; i < _signalsStoreArraySize; i++)
        {
            // Variable for readability
            TradeSignalTypeEnum signalType = _signalsStoreArray[i].Key();

            // Add entry if missing
            bool isValidSignal = true;
            if (!signalsStore.TryGetValue(signalType, isValidSignal))
            {
                signalsStore.Add(signalType, isValidSignal);
            }

            // Update signal validity
            isValidSignal &= IsExposureStatusIndicatorValidSignal(_signalsStoreArray[i].Value());
            signalsStore.TrySetValue(signalType, isValidSignal);
        }
    };

private:
    /**
     * Return signal method result given a signal type
     */
    bool IsExposureStatusIndicatorValidSignal(ExposureStatusIndicatorSignalsEnum signalType)
    {
        switch (signalType)
        {
        case NOT_ANY_OPEN_POSITION:
            return !IsAnyPositionOpen();

        case NOT_ANY_PLACED_ORDER:
            return !IsAnyOrderPlaced();

        default:
            return false;
        };
    }

    /**
     * Check for open positions by magic num, return true if one open position is found
     */
    bool IsAnyPositionOpen()
    {
        // Check stored ticket first
        if (PositionSelectByTicket(_storedTicket))
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
                    _storedTicket = ticket;
                    return true;
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