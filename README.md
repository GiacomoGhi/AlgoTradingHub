# AlgoTradingHub, MQL5 Expert Advisor Development Library

## Table of Contents

- [Disclaimer](#disclaimer)
- [Mission](#mission)
- [Values](#values)
- [Community](#community)
- [Contribute](#contribute)
- [Overview](#Overview)    

## Disclaimer

The content of this repository is intended for educational and informational purposes only. 
It does not contain any form of investment advice, solicitation, or recommendation to buy or sell any financial instruments. 
Use of this code and any related trading activities are done at your own risk. Past performance is not indicative of future 
results, and users are responsible for their own actions in financial markets.

## Mission

This library aims to simplify and streamline the development of Expert Advisors (EAs) for MetaTrader 5 (MT5) 
using the MQL5 programming language. 
By providing reusable components, developers can quickly create highly customized and maintainable trading strategies, 
reducing the complexity of building EAs from scratch.

## Values

At **AlgoTradingHub**, we believe in responsible and sustainable trading practices. 
We do not endorse get-rich-quick schemes, unrealistic 1000% win rates, or consistently upward-sloping 
balance lines with no drawdowns. 
Instead, we encourage developers and traders to prioritize risk management, consistency, and discipline.

Key principles we stand by:

- **Patience Over Profits**
- **Avoid Risky Practices**
- **Education and Growth**

## Community

Join our community to connect with like-minded developers and traders, share ideas, 
and stay updated on the latest developments!

- **Discord**: [Join our Discord Server](https://discord.gg/fR2vxYsn2a)
- **Instagram**: [Follow us on Instagram](https://www.instagram.com/algo_trading_hub/)

## Contribute

If you'd like to contribute to the development of this library, 
we welcome you to join our mission! 
Here are a few simple guidelines:

1. Fork the repository.
2. Submit pull requests with a clear explanation of the changes.
3. Ensure that your contributions align with our mission and values.
4. Discuss new ideas or features in the [Issues](https://github.com/yourrepo/issues) section before implementing.
5. Make sure to follow our naming conventions and code formatting. 
    We suggest you to install **ms-vscode.cpptools-extension-pack** and enable vscode option for auto formatting on save.

## Overview

This library is composed of two main types of classes:
    
- **Managers** 

    This classes will handle different aspects that are common across all trading strategies, such as:
    * Risk managment and position sizing;
    * Signal managment, checking indicators for trading signals to execute;
    * Trades managment,  opening or closing new trading operations
    * User authorization managment (still to implement) validate user's license to use the trading software.


- **Indicators**
    
    This classes can be splitted into two subclasses: signal providers and trade levels indicators. 
    Note that the same indicator can be used both as signal provider or trade levels indicator. 
    
    The signal provider can be queryed to validate trading condition to perform a specific trading operation such as 
    opening a buy trade.
    
    The trade levels indicators are a type of indicator that is used to produce trade levels such as 
    a pending order entry, take profit or stop loss prices.

It is important to note that both managers and indicators could be use alone in an Expert Advisor 
not fully built using the ATH library (except for the signal manager which require to use indicators 
that implements ATH base classes and interfaces). 

### ATHExpertAdvisor
This is a single class that wraps and use managers and indicators