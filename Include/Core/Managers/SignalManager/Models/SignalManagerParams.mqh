#include "../../../Shared/Interfaces/ITradeSignalProvider.mqh";
#include "../../../../Libraries/List/ObjectList.mqh";

class SignalManagerParams
{
public:
    /**
     * List of signal providers.
     */
    ObjectList<ITradeSignalProvider> *TradeSignalProviders;

    // Constructor
    SignalManagerParams(ObjectList<ITradeSignalProvider> &tradeSignalProvidersList)
        : TradeSignalProviders(&tradeSignalProvidersList) {}
}