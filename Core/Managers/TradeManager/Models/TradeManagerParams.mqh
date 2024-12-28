class TradeManagerParams
{
public:
  /**
   * Magic number.
   */
  const ulong MagicNumber;

  /**
   * Trades comment.
   */
  const string Comment;

  TradeManagerParams(
      ulong magicNumber,
      string comment)
      : MagicNumber(magicNumber),
        Comment(comment) {};
}