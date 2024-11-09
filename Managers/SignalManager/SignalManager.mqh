#include "../../Indicators/BaseModels/TradeSignalList.mqh";
#include "../../Libraries/List/ObjectList.mqh";

class SignalManager
{
  private:
    ObjectList<BaseIndicator> *_list;

  public:
    // Constructor
    SignalManager(ObjectList<BaseIndicator> &list)
        : _list(&list)
    {
    }

    bool IsValidSignal(TradeSignalTypeEnum signalType)
    {
        bool isValid = true;
        for (int i = 0; i < _list.Count(); i++)
        {
            BaseIndicator *currentItem = _list[i];
            if (currentItem.ProduceSignal(signalType))
            {
                isValid = isValid && currentItem.IsValidSignal(signalType);
            }
        }

        return isValid;
    };
};