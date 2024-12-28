#include "../Enums/TradeSignalTypeEnum.mqh";
#include "../../Libraries/List/BasicList.mqh";

/**
 * Helper class for iterating over TradeSignalTypeEnum values.
 */
class TradeSignalTypeEnumHelper
{
public:
    /**
     * Gets all enumerator values that
     * rappresents an open signal.
     */
    static BasicList<int> *GetOpenTypesValues()
    {
        BasicList<int> *list = new BasicList<int>();

        list.Append((int)TradeSignalTypeEnum::OPEN_BUY_MARKET);
        list.Append((int)TradeSignalTypeEnum::OPEN_BUY_LIMIT_ORDER);
        list.Append((int)TradeSignalTypeEnum::OPEN_BUY_STOP_ORDER);
        list.Append((int)TradeSignalTypeEnum::OPEN_SELL_MARKET);
        list.Append((int)TradeSignalTypeEnum::OPEN_SELL_LIMIT_ORDER);
        list.Append((int)TradeSignalTypeEnum::OPEN_SELL_STOP_ORDER);

        return list;
    }

    /**
     * Returns true if signal type is of type: OPEN_* .
     * */
    static bool IsOpenType(TradeSignalTypeEnum signalType)
    {
        return signalType == OPEN_BUY_MARKET || signalType == OPEN_BUY_LIMIT_ORDER || signalType == OPEN_BUY_STOP_ORDER || signalType == OPEN_SELL_MARKET || signalType == OPEN_SELL_LIMIT_ORDER || signalType == OPEN_SELL_STOP_ORDER;
    }

    /**
     * Returns true if signal type is of type: OPEN_BUY_* .
     * */
    static bool IsOpenBuyType(TradeSignalTypeEnum signalType)
    {
        return signalType == OPEN_BUY_MARKET || signalType == OPEN_BUY_LIMIT_ORDER || signalType == OPEN_BUY_STOP_ORDER;
    }

    /**
     * Returns true if signal type is of type: OPEN_SELL_* .
     * */
    static bool IsOpenSellType(TradeSignalTypeEnum signalType)
    {
        return signalType == OPEN_SELL_MARKET || signalType == OPEN_SELL_LIMIT_ORDER || signalType == OPEN_SELL_STOP_ORDER;
    }

    /**
     * Returns true if signal type is of type: *_MARKET .
     * */
    static bool IsMarketType(TradeSignalTypeEnum signalType)
    {
        return signalType == OPEN_BUY_MARKET || signalType == CLOSE_BUY_MARKET || signalType == OPEN_SELL_MARKET || signalType == CLOSE_SELL_MARKET;
    }

    /**
     * Returns true if signal type is of type: *_LIMIT_ORDER .
     * */
    static bool IsLimitType(TradeSignalTypeEnum signalType)
    {
        return signalType == OPEN_BUY_LIMIT_ORDER || signalType == OPEN_SELL_LIMIT_ORDER;
    }

    /**
     * Returns true if signal type is OPEN_BUY_MARKET or OPEN_SELL_MARKET.
     * */
    static bool IsOpenAtMarketType(TradeSignalTypeEnum signalType)
    {
        return signalType == OPEN_BUY_MARKET || signalType == OPEN_SELL_MARKET;
    }
};