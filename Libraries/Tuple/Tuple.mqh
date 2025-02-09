template <typename TItem1, typename TItem2>
class Tuple
{
public:
    const TItem1 Item1;
    const TItem2 Item2;

    Tuple(TItem1 item1, TItem2 item2)
        : Item1(item1),
          Item2(item2)
    {
    }
}