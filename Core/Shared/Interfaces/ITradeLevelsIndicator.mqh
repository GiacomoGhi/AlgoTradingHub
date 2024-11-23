#include "../Models/TradeLevels.mqh";

interface ITradeLevelsIndicator
{
    /**
     * Returns trade levels object.
     */
    TradeLevels *GetTradeLevels();
}