class TradingSignalCondition
{
public:
    const int ParentConditionId;

    const int TradingSignalConditionType;

    TradingSignalCondition(
        int parentConditionId,
        int tradingSignalConditionType)
        : ParentConditionId(parentConditionId),
          TradingSignalConditionType(tradingSignalConditionType) {};
}