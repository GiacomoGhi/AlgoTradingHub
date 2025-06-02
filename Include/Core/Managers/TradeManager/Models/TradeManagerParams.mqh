#include "./BreakEvenExecutionMode.mqh";

class TradeManagerParams
{
public:
  /**
   * Trades comment.
   */
  const string Comment;

  /**
   * Points in profit to set stop loss at break even.
   * If zero, is inactive.
   */
  const int BreakEvenAtPointsInProfit;

  /**
   * Break even execution mode.
   */
  const BreakEvenExecutionModeEnum BreakEvenExecutionMode;

  /**
   * If true and if calculated lots are more then max allowed
   * position or order volume it will as many positions as needed to
   * consume all calculated lots.
   */
  const bool ConsumeAllCalculatedLots;

  TradeManagerParams(
      string comment,
      int breakEvenAtPointsInProfit,
      BreakEvenExecutionModeEnum breakEvenExecutionMode,
      bool consumeAllCalculatedLots)
      : Comment(comment),
        BreakEvenAtPointsInProfit(breakEvenAtPointsInProfit),
        BreakEvenExecutionMode(breakEvenExecutionMode),
        ConsumeAllCalculatedLots(consumeAllCalculatedLots) {};
}