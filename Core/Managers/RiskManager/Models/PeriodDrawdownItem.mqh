class PeriodDrawdownItem
{
public:
    /**
     * Drawdown period.
     */
    const ulong PeriodDurationInSeconds;

    /**
     * Max allowed drawdown in period.
     */
    const double MaxAllowedDrawdownPercent;

    /**
     * Account balance value when period started.
     */
    double BalanceAtPeriodStart;

    /**
     * Date time of start of the period.
     */
    datetime PeriodStartTime;

    /**
     * Falg set to true if limit is exceeded. Gets reset to false when period expire
     */
    bool IsLimitExceeded;

    /**
     * Constructor.
     */
    PeriodDrawdownItem(
        ENUM_TIMEFRAMES period,
        double maxAllowedDrawdownPercent,
        double balanceAtPeriodStart,
        datetime periodStartTime)
        : PeriodDurationInSeconds(MapEnumTimeFramesToSeconds(period)),
          MaxAllowedDrawdownPercent(maxAllowedDrawdownPercent),
          BalanceAtPeriodStart(balanceAtPeriodStart),
          PeriodStartTime(periodStartTime),
          IsLimitExceeded(false) {}

    /**
     * Retruns a readable description the object properties content
     */
    string ToString()
    {
        return "PeriodDurationInSeconds: " + (string)PeriodDurationInSeconds + "; " +
               "MaxAllowedDrawdownPercent: " + (string)MaxAllowedDrawdownPercent + "; " +
               "BalanceAtPeriodStart: " + (string)BalanceAtPeriodStart + "; " +
               "PeriodStartTime: " + (string)PeriodStartTime + "; ";
    }

private:
    ulong MapEnumTimeFramesToSeconds(ENUM_TIMEFRAMES period)
    {
        switch (period)
        {
        case PERIOD_M1:
            return 60;

        case PERIOD_M2:
            return 60 * 2;

        case PERIOD_M3:
            return 60 * 3;

        case PERIOD_M4:
            return 60 * 4;

        case PERIOD_M5:
            return 60 * 5;

        case PERIOD_M6:
            return 60 * 6;

        case PERIOD_M10:
            return 60 * 10;

        case PERIOD_M12:
            return 60 * 12;

        case PERIOD_M15:
            return 60 * 15;

        case PERIOD_M20:
            return 60 * 20;

        case PERIOD_M30:
            return 60 * 30;

        case PERIOD_H1:
            return 60 * 60;

        case PERIOD_H2:
            return 60 * 60 * 2;

        case PERIOD_H3:
            return 60 * 60 * 3;

        case PERIOD_H4:
            return 60 * 60 * 4;

        case PERIOD_H6:
            return 60 * 60 * 6;

        case PERIOD_H8:
            return 60 * 60 * 8;

        case PERIOD_H12:
            return 60 * 60 * 12;

        case PERIOD_D1:
            return 60 * 60 * 24;

        case PERIOD_W1:
            return 60 * 60 * 24 * 7;

        // Month is approx to 30 days
        case PERIOD_MN1:
            return (ulong)(60 * 60 * 24 * 30);

        // Default is 20 year period.
        default:
            return (ulong)(60 * 60 * 24 * 365 * 20);
        }
    }
}