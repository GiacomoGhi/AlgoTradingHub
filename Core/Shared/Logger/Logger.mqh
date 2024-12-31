#include "./LogTypeEnum.mqh";

class Logger
{
private:
    const bool _isLogginEnabled;
    const string _eaName;
    const ulong _magicNumber;

public:
    Logger(
        bool isLoggingEnabled,
        string eaName,
        ulong magicNumber)
        : _isLogginEnabled(isLoggingEnabled),
          _eaName(eaName),
          _magicNumber(magicNumber) {};

    /**
     * Logs generic information.
     */
    void Log(LogTypeEnum logType, string source, string message)
    {
        if (!_isLogginEnabled)
        {
            return;
        }

        PrintFormat(
            "[(%u) %s.%s] %s: %s",
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
        if (!_isLogginEnabled)
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
        if (!_isLogginEnabled)
        {
            return;
        }

        this.Log(ERROR, source, "Init failed!");
    }
}