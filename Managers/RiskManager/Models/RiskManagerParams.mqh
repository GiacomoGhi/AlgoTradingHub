class RiskManagerParams
{
  public:
    double SizeValueOrPercentage;
    double MaxDailyDrawDownPercentage;
    double MaxOverallDrawDown;

    RiskManagerParams(
        double sizeValueOrPercentage,
        double maxDailyDrawDownPercentage,
        double maxOverallDrawDown)
        : SizeValueOrPercentage(sizeValueOrPercentage),
          MaxDailyDrawDownPercentage(maxDailyDrawDownPercentage),
          MaxOverallDrawDown(maxOverallDrawDown)
    {
    }
}