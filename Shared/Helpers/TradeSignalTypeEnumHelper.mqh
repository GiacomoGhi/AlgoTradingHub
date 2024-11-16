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
     * rappresents an open signal
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
};