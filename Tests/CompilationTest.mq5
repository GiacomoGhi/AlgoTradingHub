#include "../index.mqh";
/**
 * This file was needed to check if classes were actually compiling
 * The introduction of templates brought some confusion since
 * I am not able to use BinFlags as a template class and declare BaseIndicator._produceSignalTypeFlags
 * as of type BinFlags<TradeSignalTypeEnum>
 * but I am able to do so when using ObjectList<T> in SignalManager.indicatorsList;
 */
// TODO fix formatting and just give it more sense
// TODO now it looks like poop
void OnStart()
{

    // Libraries
    BinFlags binFlags = new BinFlags();
    binFlags.SetFlag(TradeSignalTypeEnum::OPEN_BUY_MARKET);
    binFlags.SetFlag(TradeSignalTypeEnum::OPEN_SELL_MARKET);
    
    ObjectList<ITradeSignal> objectList;
    objectList.Append(new MovingAvarage(
        "Test",
        PERIOD_H1,
        &binFlags,
        1,
        1,
        MODE_SMA,
        PRICE_CLOSE,
        AlwaysTrue,
        AlwaysTrue,
        AlwaysTrue,
        AlwaysTrue));

    // Indicators
    MovingAvarage *movingAvarage = new MovingAvarage(
        "Test",
        PERIOD_H1,
        &binFlags,
        1,
        1,
        MODE_SMA,
        PRICE_CLOSE,
        AlwaysTrue,
        AlwaysTrue,
        AlwaysTrue,
        AlwaysTrue);

    // Managers
    SignalManagerParams *signalManagerParams = new SignalManagerParams(&objectList, 123);
    SignalManager *signalManager = new SignalManager(signalManagerParams);
}