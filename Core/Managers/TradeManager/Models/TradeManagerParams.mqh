class TradeManagerParams
{
  public:
    /**
     * Trades comment.
     */
    const string Comment;

    /**
     * If true and if calculated lots are more then max allowed
     * position or order volume it will as many positions as needed to
     * consume all calculated lots.
     */
    const bool ConsumeAllCalculatedLots;

    TradeManagerParams(
        string comment,
        bool consumeAllCalculatedLots = false)
        : Comment(comment),
          ConsumeAllCalculatedLots(consumeAllCalculatedLots) {};
}