class TradeManagerParams
{
  public:
    ulong MagicNumber;
    string Comment;

    TradeManagerParams(
        ulong magicNumber,
        string comment)
        : MagicNumber(magicNumber),
          Comment(comment) {};
}