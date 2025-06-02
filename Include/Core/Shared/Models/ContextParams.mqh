class ContextParams
{
  public:
    const string Symbol;
    const double Points;
    const int Digits;
    const ulong MagicNumber;

    // Constructor
    ContextParams(string symbol, ulong magicNumber)
        : Symbol(symbol),
          MagicNumber(magicNumber),
          Points(SymbolInfoDouble(symbol, SYMBOL_POINT)),
          Digits((int)SymbolInfoInteger(symbol, SYMBOL_DIGITS))
    {
    }
}