#include "../Enums/TradeSignalTypeEnum.mqh";
#include "../../Libraries/List/BasicList.mqh";

/**
 * Interface defining a strategy for iterating over trade signal types.
 */
interface ITradeSignalTypeEnumHelperStrategy
{
    /**
     * Processes each signal type using the provided algorithm.
     * @param signalType The current trade signal type being processed.
     */
    void ForEachAlgorithmInterface(int signalType);
};

/**
 * Helper class for iterating over TradeSignalTypeEnum values.
 */
class TradeSignalTypeEnumHelper
{
public:
    /**
     * Iterates over all defined TradeSignalTypeEnum values and applies a given strategy.
     * @param strategy An instance of ITradeSignalTypeEnumHelperStrategy
     *  to process each signal type.
     */
    static void ForEach(ITradeSignalTypeEnumHelperStrategy &strategy)
    {
        // Define each enumerator explicitly
        const int signalTypes[] = {
            TradeSignalTypeEnum::NONE,
            TradeSignalTypeEnum::OPEN_BUY_MARKET,
            TradeSignalTypeEnum::OPEN_BUY_LIMIT_ORDER,
            TradeSignalTypeEnum::OPEN_BUY_STOP_ORDER,
            TradeSignalTypeEnum::CLOSE_BUY_MARKET,
            TradeSignalTypeEnum::DELETE_BUY_ORDER,
            TradeSignalTypeEnum::OPEN_SELL_MARKET,
            TradeSignalTypeEnum::OPEN_SELL_LIMIT_ORDER,
            TradeSignalTypeEnum::OPEN_SELL_STOP_ORDER,
            TradeSignalTypeEnum::CLOSE_SELL_MARKET,
            TradeSignalTypeEnum::DELETE_SELL_ORDER};

        for (int i = 0; i < ArraySize(signalTypes); i++)
        {
            strategy.ForEachAlgorithmInterface(signalTypes[i]);
        }
    }

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

    /**
     * Provides string of comma separated trade signal enum values translated to string.
     * */
    static string FormatBinFlags(BinFlags &signals)
    {
        // Define each enumerator explicitly
        const int signalTypes[] = {
            TradeSignalTypeEnum::NONE,
            TradeSignalTypeEnum::OPEN_BUY_MARKET,
            TradeSignalTypeEnum::OPEN_BUY_LIMIT_ORDER,
            TradeSignalTypeEnum::OPEN_BUY_STOP_ORDER,
            TradeSignalTypeEnum::CLOSE_BUY_MARKET,
            TradeSignalTypeEnum::DELETE_BUY_ORDER,
            TradeSignalTypeEnum::OPEN_SELL_MARKET,
            TradeSignalTypeEnum::OPEN_SELL_LIMIT_ORDER,
            TradeSignalTypeEnum::OPEN_SELL_STOP_ORDER,
            TradeSignalTypeEnum::CLOSE_SELL_MARKET,
            TradeSignalTypeEnum::DELETE_SELL_ORDER};

        string result = "";
        string separator = "";
        for (int i = 0; i < ArraySize(signalTypes); i++)
        {
            int flag = signalTypes[i];
            if (signals.HasFlag(flag))
            {
                result += separator + EnumToString((TradeSignalTypeEnum)flag);
            }

            if (separator == "")
            {
                separator = ", ";
            }
        }

        return result;
    }
};