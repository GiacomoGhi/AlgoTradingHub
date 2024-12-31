#include "./SizeCalculationTypeEnum.mqh";
#include "../../../Libraries/List/ObjectList.mqh";

class RiskManagerParams
{
public:
    /**
     * Type of size calculation.
     */
    const SizeCalculationTypeEnum SizeCalculationType;

    /**
     * Value used to calculate lot size based on selected SizeCaluclationType.
     */
    const double SizeValueOrPercentage;

    /**
     * List of max allowed dowrdown (value) during the selected period (time frame)
     */
    ObjectList<CKeyValuePair<ENUM_TIMEFRAMES, double>> *PeriodAllowedDrawdownStore;

    /**
     * Contructor by copy.
     */
    RiskManagerParams(RiskManagerParams &riskManagerParams)
    {
        RiskManagerParams(
            riskManagerParams.SizeCalculationType,
            riskManagerParams.SizeValueOrPercentage,
            riskManagerParams.PeriodAllowedDrawdownStore);
    };

    /**
     * Contructor.
     */
    RiskManagerParams(
        SizeCalculationTypeEnum sizeCalculationType,
        double sizeValueOrPercentage,
        ObjectList<CKeyValuePair<ENUM_TIMEFRAMES, double>> &periodAllowedDrawdownStore)
        : SizeCalculationType(sizeCalculationType),
          SizeValueOrPercentage(sizeValueOrPercentage),
          PeriodAllowedDrawdownStore(&periodAllowedDrawdownStore) {};
}