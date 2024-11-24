#include "../Libraries/Tuple/Tuple.mqh";

template <typename TSignalsTypeEnum>
class IndicatorSignals
{
public:
    const Tuple<bool, TSignalsTypeEnum> *OpenBuy;
    const Tuple<bool, TSignalsTypeEnum> *CloseBuy;
    const Tuple<bool, TSignalsTypeEnum> *OpenSell;
    const Tuple<bool, TSignalsTypeEnum> *CloseSell;

    IndicatorSignals(
        Tuple<bool, TSignalsTypeEnum> &openBuy,
        Tuple<bool, TSignalsTypeEnum> &closeBuy,
        Tuple<bool, TSignalsTypeEnum> &openSell,
        Tuple<bool, TSignalsTypeEnum> &closeSell)
        : OpenBuy(&openBuy),
          OpenSell(&openSell),
          CloseBuy(&closeBuy),
          CloseSell(&closeSell)
    {
    }
}