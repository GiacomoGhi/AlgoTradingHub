#include "../index.mqh";
/*********
 * This file was needed to check if classes were actually compiling
 * The introduction of templates brought some confusion since
 * I am not able to use BinFlags as a template class and declare BaseIndicator._produceSignalTypeFlags
 * as of type BinFlags<TradeSignalTypeEnum>
 * but I am able to do so when using ObjectList<T> in SignalManager.list;
 * */
void OnStart()
{
    BinFlags binFlags = new BinFlags();
    TradeSignalTypeEnum buy = BUY_SIGNAL;
    TradeSignalTypeEnum sell = SELL_SIGNAL;
    binFlags.SetFlag(buy);
    binFlags.SetFlag(sell);

    BaseIndicator *baseIndicator = new BaseIndicator("Test", PERIOD_H1, &binFlags);

    ObjectList<BaseIndicator> objectList;
    objectList.Append(baseIndicator);

    SignalManager *signalManager = new SignalManager(&objectList);
}