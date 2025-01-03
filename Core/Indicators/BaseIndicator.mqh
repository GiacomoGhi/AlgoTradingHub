#include <Generic\HashMap.mqh>;
#include "../Libraries/BinFlags/BinFlags.mqh";
#include "../Shared/Helpers/TradeSignalTypeEnumHelper.mqh";
#include "../Shared/Interfaces/ITradeSignalProvider.mqh";
#include "../Shared/Logger/Logger.mqh";

template <typename TSignalsTypeEnum>
class BaseIndicator : public ITradeSignalProvider
{
protected:
    /**
     * Name of the child class.
     */
    const string _className;

    /**
     * Logger.
     */
    Logger *_logger;

    /**
     * Market signal related to this indicator.
     */
    const string _symbol;

    /**
     * Indicator handle.
     */
    const int _handle;

    /**
     * Indicator time frame
     */
    ENUM_TIMEFRAMES _timeFrame;

    /**
     * Int to indicate the size of the array of signals types produced from this indicator.
     */
    int _signalsStoreArraySize;

    /**
     * Array of key value pairs,
     * Contians the trade signal type produced from the indicator and
     * indicator condition used to validate the signal.
     */
    CKeyValuePair<TradeSignalTypeEnum, TSignalsTypeEnum> *_signalsStoreArray[];

public:
    /**
     * Constructor
     */
    BaseIndicator(
        string className,
        Logger &logger,
        string symbol,
        CHashMap<TradeSignalTypeEnum, TSignalsTypeEnum> &signalTypeTriggerStore,
        ENUM_TIMEFRAMES timeFrame = PERIOD_H1,
        int handle = 0)
        : _className(className),
          _logger(&logger),
          _symbol(symbol),
          _timeFrame(timeFrame),
          _handle(handle)
    {
        // Store signal types and related triggers as array to allow looping.
        signalTypeTriggerStore.CopyTo(_signalsStoreArray);
        _signalsStoreArraySize = ArraySize(_signalsStoreArray);

        // Delete dto
        delete &signalTypeTriggerStore;
    };

    /**
     * Deconstructor
     */
    void BaseIndicatorDeconstructor()
    {
        // Signals store
        for (int i = 0; i < ArraySize(_signalsStoreArray); i++)
        {
            delete _signalsStoreArray[i];
        }
        ArrayFree(_signalsStoreArray);
    }

protected:
    // Get a signle value of the indicator
    double GetIndicatorValue(int shift = 0, int bufferNumber = 0)
    {
        if (_handle <= 0)
        {
            // TODO log error
            return 0;
        }
        double valueContainer[1];

        // Copy requested value inside the container
        CopyBuffer(_handle, bufferNumber, shift, 1, valueContainer);

        return valueContainer[0];
    };
}