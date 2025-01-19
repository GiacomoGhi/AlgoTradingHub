#include "./LogTypeEnum.mqh";

class Logger
{
private:
    const int _logLevel;
    const string _eaName;
    const ulong _magicNumber;

public:
    Logger(
        LogTypeEnum logLevel,
        string eaName,
        ulong magicNumber)
        : _logLevel((int)logLevel),
          _eaName(eaName),
          _magicNumber(magicNumber) {};

    /**
     * Logs generic information.
     */
    void Log(LogTypeEnum logType, string source, string message)
    {
        if ((int)logType > _logLevel)
        {
            return;
        }

        PrintFormat(
            "id: %u [%s] %s %s: %s",
            _magicNumber,
            _eaName,
            source,
            EnumToString(logType),
            message);
    }

    /**
     * Logs "Init completed" message.
     */
    void LogInitCompleted(string source)
    {
        if ((int)LogTypeEnum::INFO > _logLevel)
        {
            return;
        }

        this.Log(INFO, source, "Init completed!");
    }

    /**
     * Logs "Init completed" message.
     */
    void LogInitFailed(string source)
    {
        if ((int)LogTypeEnum::ERROR > _logLevel)
        {
            return;
        }

        this.Log(ERROR, source, "Init failed!");
    }
}