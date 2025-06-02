#include "../../Libraries/List/ObjectList.mqh";
#include "../Shared/Helpers/TradeSignalTypeEnumHelper.mqh";
#include "../Shared/Interfaces/ITradeSignalProvider.mqh";
#include "../Shared/Logger/Logger.mqh";
#include <Libraries/MetaQuotes/Generic\HashMap.mqh>;

template <typename TSignalsTypeEnum>
class BaseIndicator : public ITradeSignalProvider
{
protected:
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
     * Array of key value pairs,
     * Contians the trade signal type produced from the indicator and
     * indicator condition used to validate the signal.
     */
    ObjectList<CKeyValuePair<TradeSignalTypeEnum, TSignalsTypeEnum>> *_signalTypeTriggerList;

public:
    /**
     * Constructor
     */
    BaseIndicator(
        Logger &logger,
        string symbol,
        ObjectList<CKeyValuePair<TradeSignalTypeEnum, TSignalsTypeEnum>> &signalTypeTriggerList,
        ENUM_TIMEFRAMES timeFrame = PERIOD_H1,
        int handle = 0)
        : _logger(&logger),
          _symbol(symbol),
          _signalTypeTriggerList(&signalTypeTriggerList),
          _timeFrame(timeFrame),
          _handle(handle) {};

    /**
     * Deconstructor
     */
    void BaseIndicatorDeconstructor()
    {
        // Signals store
        _signalTypeTriggerList.RemoveAll();
        delete _signalTypeTriggerList;
    }

    /**
     * ITradeSignalProvider implementation
     */
    void UpdateSignalStore(CHashMap<TradeSignalTypeEnum, bool> &signalsStore) override
    {
        for (int i = 0; i < _signalTypeTriggerList.Count(); i++)
        {
            // Variable for readability
            TradeSignalTypeEnum signalType = _signalTypeTriggerList[i].Key();

            if (signalType == TradeSignalTypeEnum::NONE)
            {
                continue;
            }

            // Add entry if missing
            bool isValidSignal = true;
            if (!signalsStore.TryGetValue(signalType, isValidSignal))
            {
                signalsStore.Add(signalType, isValidSignal);
            }

            // Update signal validity
            // TODO update this, creates condition groups
            isValidSignal &= IsIndicatorValidSignal(_signalTypeTriggerList[i].Value());
            signalsStore.TrySetValue(signalType, isValidSignal);
        }
    };

protected:
    // Get a signle value of the indicator
    double GetIndicatorValue(int shift = 0, int bufferNumber = 0)
    {
        if (_handle <= 0)
        {
            _logger.Log(ERROR, __FUNCTION__, "Invalid or null indicator handle");
            return 0;
        }
        double valueContainer[1];

        // Copy requested value inside the container
        CopyBuffer(_handle, bufferNumber, shift, 1, valueContainer);

        return valueContainer[0];
    };

    /**
     * Override this method to implement indicator
     * specific logic to validate signal types.
     */
    virtual bool IsIndicatorValidSignal(TSignalsTypeEnum signalType)
    {
        switch (signalType)
        {
        default:
            return false;
        };
    }
}