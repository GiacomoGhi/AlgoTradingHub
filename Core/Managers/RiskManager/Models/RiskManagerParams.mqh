#include "../../../Libraries/List/ObjectList.mqh";
#include "./SizeCalculationTypeEnum.mqh";

class RiskManagerParams
{
  public:
    /**
     * Long trades type of size calculation.
     */
    const SizeCalculationTypeEnum SizeCalculationTypeLong;

    /**
     * Long trades value used to calculate lot size based on selected SizeCaluclationType.
     */
    const double SizeValueOrPercentageLong;

    /**
     * Short trades type of size calculation.
     */
    const SizeCalculationTypeEnum SizeCalculationTypeShort;

    /**
     * Short trades value used to calculate lot size based on selected SizeCaluclationType.
     */
    const double SizeValueOrPercentageShort;

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
            riskManagerParams.SizeCalculationTypeLong,
            riskManagerParams.SizeValueOrPercentageLong,
            riskManagerParams.SizeCalculationTypeShort,
            riskManagerParams.SizeValueOrPercentageShort,
            riskManagerParams.PeriodAllowedDrawdownStore);
    };

    /**
     * Contructor.
     */
    RiskManagerParams(
        SizeCalculationTypeEnum sizeCalculationTypeLong,
        double sizeValueOrPercentageLong,
        SizeCalculationTypeEnum sizeCalculationTypeShort,
        double sizeValueOrPercentageShort,
        ObjectList<CKeyValuePair<ENUM_TIMEFRAMES, double>> &periodAllowedDrawdownStore)
        : SizeCalculationTypeLong(sizeCalculationTypeLong),
          SizeValueOrPercentageLong(sizeValueOrPercentageLong),
          SizeCalculationTypeShort(sizeCalculationTypeShort),
          SizeValueOrPercentageShort(sizeValueOrPercentageShort),
          PeriodAllowedDrawdownStore(&periodAllowedDrawdownStore) {};
}