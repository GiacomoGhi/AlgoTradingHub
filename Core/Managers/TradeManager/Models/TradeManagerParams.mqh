class TradeManagerParams
{
public:
    const ulong MagicNumber;
    const string Comment;

    TradeManagerParams(
        ulong magicNumber,
        string comment)
        : MagicNumber(magicNumber),
          Comment(comment) {};
}