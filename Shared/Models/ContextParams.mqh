class ContextParams
{
  public:
    string Symbol;
    double Points;
    int Digits;

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