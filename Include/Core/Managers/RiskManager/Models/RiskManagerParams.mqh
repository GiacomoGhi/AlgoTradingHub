#include "../../../../Libraries/List/ObjectList.mqh";
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
   * If true, long trades calculation type and value will be used also for shorts.
   */
  const bool UseLongValueForBoth;

  /**
   * List of max allowed dowrdown (value) during the selected period (time frame)
   */
  ObjectList<CKeyValuePair<ENUM_TIMEFRAMES, double>> *PeriodAllowedDrawdownStore;

  /**
   * Price based size calculation parameters.
   * MaxPrice is the price at which the minimum lot size will be used.
   * MinPrice is the price at which the maximum lot size will be used.
   * PriceDelta is the difference between each possible price level.
   */
  double MaxPrice;
  double MinPrice;
  double PriceDelta;

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
        riskManagerParams.PeriodAllowedDrawdownStore,
        riskManagerParams.UseLongValueForBoth,
        riskManagerParams.MaxPrice,
        riskManagerParams.MinPrice,
        riskManagerParams.PriceDelta);
  };

  /**
   * Contructor.
   */
  RiskManagerParams(
      SizeCalculationTypeEnum sizeCalculationTypeLong,
      double sizeValueOrPercentageLong,
      SizeCalculationTypeEnum sizeCalculationTypeShort,
      double sizeValueOrPercentageShort,
      ObjectList<CKeyValuePair<ENUM_TIMEFRAMES, double>> &periodAllowedDrawdownStore,
      bool useLongValueForBoth = false,
      double maxPrice = 0,
      double minPrice = 0,
      double priceDelta = 0)
      : SizeCalculationTypeLong(sizeCalculationTypeLong),
        SizeValueOrPercentageLong(sizeValueOrPercentageLong),
        SizeCalculationTypeShort(sizeCalculationTypeShort),
        SizeValueOrPercentageShort(sizeValueOrPercentageShort),
        PeriodAllowedDrawdownStore(&periodAllowedDrawdownStore),
        MaxPrice(maxPrice),
        MinPrice(minPrice),
        PriceDelta(priceDelta),
        UseLongValueForBoth(useLongValueForBoth) {};
}