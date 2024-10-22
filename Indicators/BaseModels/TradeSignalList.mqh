#include "./ITradeSignal.mqh";

// This class provides basic list functionalities plus it allows to check multiple signal validity
class TradeSignalList
{
  public:
    ITradeSignal *Items[];

  public:
    // Constructor
    TradeSignalList(ITradeSignal &items[])
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
    void Add(ITradeSignal &item)
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
            isValid = isValid && Items[i].IsValidSignal(signalType);
        }

        return isValid;
    };
}