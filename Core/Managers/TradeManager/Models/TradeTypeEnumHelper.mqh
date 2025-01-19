#include "./TradeTypeEnum.mqh";
#include "../../../Shared/Enums/TradeSignalTypeEnum.mqh";

class TradeTypeEnumHelper
{
public:
    static TradeTypeEnum Map(ENUM_POSITION_TYPE source)
    {
        switch (source)
        {
        case ENUM_POSITION_TYPE::POSITION_TYPE_BUY:
            return TradeTypeEnum::TRADE_TYPE_BUY;

        case ENUM_POSITION_TYPE::POSITION_TYPE_SELL:
            return TradeTypeEnum::TRADE_TYPE_SELL;

        default:
            return TradeTypeEnum::TRADE_TYPE_UNDEFINED;
        }
    }

    static TradeTypeEnum Map(ENUM_ORDER_TYPE source)
    {
        switch (source)
        {
        case ENUM_ORDER_TYPE::ORDER_TYPE_BUY_LIMIT:
            return TradeTypeEnum::TRADE_TYPE_BUY_LIMIT;

        case ENUM_ORDER_TYPE::ORDER_TYPE_BUY_STOP:
            return TradeTypeEnum::TRADE_TYPE_BUY_STOP;

        case ENUM_ORDER_TYPE::ORDER_TYPE_SELL_LIMIT:
            return TradeTypeEnum::TRADE_TYPE_SELL_LIMIT;

        case ENUM_ORDER_TYPE::ORDER_TYPE_SELL_STOP:
            return TradeTypeEnum::TRADE_TYPE_SELL_STOP;

        default:
            return TradeTypeEnum::TRADE_TYPE_UNDEFINED;
        }
    }

    static TradeTypeEnum Map(TradeSignalTypeEnum source)
    {
        switch (source)
        {
        case TradeSignalTypeEnum::CLOSE_BUY_MARKET:
        case TradeSignalTypeEnum::OPEN_BUY_MARKET:
            return TradeTypeEnum::TRADE_TYPE_BUY;

        case TradeSignalTypeEnum::DELETE_BUY_LIMIT_ORDER:
        case TradeSignalTypeEnum::OPEN_BUY_LIMIT_ORDER:
            return TradeTypeEnum::TRADE_TYPE_BUY_LIMIT;

        case TradeSignalTypeEnum::DELETE_BUY_STOP_ORDER:
        case TradeSignalTypeEnum::OPEN_BUY_STOP_ORDER:
            return TradeTypeEnum::TRADE_TYPE_BUY_STOP;

        case TradeSignalTypeEnum::CLOSE_SELL_MARKET:
        case TradeSignalTypeEnum::OPEN_SELL_MARKET:
            return TradeTypeEnum::TRADE_TYPE_SELL;

        case TradeSignalTypeEnum::DELETE_SELL_LIMIT_ORDER:
        case TradeSignalTypeEnum::OPEN_SELL_LIMIT_ORDER:
            return TradeTypeEnum::TRADE_TYPE_SELL_LIMIT;

        case TradeSignalTypeEnum::DELETE_SELL_STOP_ORDER:
        case TradeSignalTypeEnum::OPEN_SELL_STOP_ORDER:
            return TradeTypeEnum::TRADE_TYPE_SELL_STOP;

        default:
            return TradeTypeEnum::TRADE_TYPE_UNDEFINED;
        }
    }

    static bool IsLong(TradeSignalTypeEnum source)
    {
        switch (source)
        {
        case TradeSignalTypeEnum::CLOSE_BUY_MARKET:
        case TradeSignalTypeEnum::OPEN_BUY_MARKET:
        case TradeSignalTypeEnum::DELETE_BUY_LIMIT_ORDER:
        case TradeSignalTypeEnum::OPEN_BUY_LIMIT_ORDER:
        case TradeSignalTypeEnum::DELETE_BUY_STOP_ORDER:
        case TradeSignalTypeEnum::OPEN_BUY_STOP_ORDER:
            return true;

        case TradeSignalTypeEnum::CLOSE_SELL_MARKET:
        case TradeSignalTypeEnum::OPEN_SELL_MARKET:
        case TradeSignalTypeEnum::DELETE_SELL_LIMIT_ORDER:
        case TradeSignalTypeEnum::OPEN_SELL_LIMIT_ORDER:
        case TradeSignalTypeEnum::DELETE_SELL_STOP_ORDER:
        case TradeSignalTypeEnum::OPEN_SELL_STOP_ORDER:
            return false;

        default:
            return false;
        }
    }
}