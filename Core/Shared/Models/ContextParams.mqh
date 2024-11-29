class ContextParams
{
public:
    const string Symbol;
    const double Points;
    const int Digits;

    // Constructor
    ContextParams(string symbol)
        : Symbol(symbol),
          Points(SymbolInfoDouble(symbol, SYMBOL_POINT)),
          Digits((int)SymbolInfoInteger(symbol, SYMBOL_DIGITS))
    {
    }
}