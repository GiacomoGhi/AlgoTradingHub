#include "./SizeCalculationTypeEnum.mqh";

class RiskManagerParams
{
public:
    /**
     * Value used to calculate lot size based on selected SizeCaluclationType.
     */
    const double SizeValueOrPercentage;

    /**
     * Max allowd daily drowdown percentage.
     */
    const double MaxDailyDrawDownPercentage;

    /**
     * Max overall allowed drowdown percentage.
     */
    const double MaxOverallDrawDown;

    /**
     * Type of size calculation.
     */
    const SizeCalculationTypeEnum SizeCalculationType;

    /**
     * Contructor by copy.
     */
    RiskManagerParams(RiskManagerParams &riskManagerParams)
    {
        RiskManagerParams(
            riskManagerParams.SizeValueOrPercentage,
            riskManagerParams.MaxDailyDrawDownPercentage,
            riskManagerParams.MaxOverallDrawDown,
            riskManagerParams.SizeCalculationType);
    };

    /**
     * Contructor.
     */
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