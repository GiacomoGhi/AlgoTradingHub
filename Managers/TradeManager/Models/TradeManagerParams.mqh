#include "../../RiskManager/Models/RiskManagerParams.mqh";
class TradeManagerParams
{
  public:
    ulong MagicNumber;
    string Comment;
    RiskManagerParams *RiskManagerParams;

    TradeManagerParams(
        ulong magicNumber,
        string comment,
        RiskManagerParams &riskManagerParams)
        : MagicNumber(magicNumber),
          Comment(comment),
          RiskManagerParams(&riskManagerParams) {};
}