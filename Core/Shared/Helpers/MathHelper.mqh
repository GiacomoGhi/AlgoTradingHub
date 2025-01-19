#include "../Logger/Logger.mqh";

class MathHelper
{
private:
    MathHelper() {}

public:
    /**
     * Safe division implementation to avoid critical error zero divide.
     * Returns zero if divisor is zero.
     */
    static double SafeDivision(Logger &logger, double dividend, double divisor)
    {
        if (divisor == 0)
        {
            logger.Log(ERROR, getClassName(), "Cannot divide by zero");
            return 0;
        }
        return dividend / divisor;
    }

    static string getClassName()
    {
        return "MathHelper";
    }
}