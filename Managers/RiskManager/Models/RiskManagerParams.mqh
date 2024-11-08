#include "./SizeCalculationTypeEnum.mqh";

class RiskManagerParams
{
  public:
    double SizeValueOrPercentage;
    double MaxDailyDrawDownPercentage;
    double MaxOverallDrawDown;
    SizeCalculationTypeEnum SizeCalculationType;

    // Contructor by copy
    RiskManagerParams(RiskManagerParams &riskManagerParams)
    {
        RiskManagerParams(
            riskManagerParams.SizeValueOrPercentage,
            riskManagerParams.MaxDailyDrawDownPercentage,
            riskManagerParams.MaxOverallDrawDown,
            riskManagerParams.SizeCalculationType);
    };

    RiskManagerParams(
        double sizeValueOrPercentage,
        double maxDailyDrawDownPercentage,
        double maxOverallDrawDown,
        SizeCalculationTypeEnum sizeCalculationType)
        : SizeValueOrPercentage(sizeValueOrPercentage),
          MaxDailyDrawDownPercentage(maxDailyDrawDownPercentage),
          MaxOverallDrawDown(maxOverallDrawDown),
          SizeCalculationType(sizeCalculationType) {};
}

// TODO add safety stop loss value?