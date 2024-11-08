#include "./BaseIndicator.mqh";

// This class provides basic list functionalities plus it allows to check multiple signal validity
class TradeSignalList
{
  public:
    BaseIndicator *Items[];

  public:
    // Constructor
    TradeSignalList(BaseIndicator &items[])
    {
        // Resize internal items array to match external items array
        int initialArrayLenght = ArraySize(items);
        if (initialArrayLenght > 0)
        {
            ArrayResize(Items, initialArrayLenght);
        }
        else
        {
            ArrayResize(Items, 1);
        }

        // Copy each object into internal item array
        for (int i = 0; i < initialArrayLenght; i++)
        {
            Items[i] = &items[i];
        }
    }

    // Add item to the list
    void Add(BaseIndicator &item)
    {
        // Add one spece to the array
        int newSize = ArraySize(Items) + 1;
        ArrayResize(Items, newSize);

        // Add item to the array
        Items[newSize - 1] = &item;
    }

    // TODO Remove an item from the list

    // Check trade signals
    bool IsValidSignal(TradeSignalTypeEnum signalType)
    {
        bool isValid = true;
        for (int i = 0; i < ArraySize(Items); i++)
        {
            BaseIndicator *currentItem = Items[i];
            if (currentItem.ProduceSignal(signalType))
            {
                isValid = isValid && currentItem.IsValidSignal(signalType);
            }
        }

        return isValid;
    };
}