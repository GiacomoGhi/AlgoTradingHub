class ContextParams
{
public:
    const string Symbol;
    const double Points;
    const int Digits;

    // Constructor
    ContextParams(
        string symbol,
        double points,
        int digits)
        : Symbol(symbol),
          Points(points),
          Digits(digits)
    {
    }
}