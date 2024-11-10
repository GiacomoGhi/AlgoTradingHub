#include "../../RiskManager/Models/RiskManagerParams.mqh";
class TradeManagerParams
{
public:
    const ulong MagicNumber;
    const string Comment;
    RiskManagerParams *RiskManagerParams;

    TradeManagerParams(
        ulong magicNumber,
        string comment,
        RiskManagerParams &riskManagerParams)
        : MagicNumber(magicNumber),
          Comment(comment),
          RiskManagerParams(&riskManagerParams) {};
}