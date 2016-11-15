//+----------------------------+
//|   Analyze Currency Symbol  |
//+============================+
//|
//|   Rev Date: 2010.06.07
//|
//|   Contains the following Functions:
//|
//|   SymbolType()
//|   BasePairForCross()
//|   CounterPairForCross()
//|   SymbolLeverage()
//|   AnalyzeSymbol()
//|
//+----------------------------+

#property copyright "1005phillip"
#include <stderror.mqh>
#include <stdlib.mqh>

//+---------------------------------------------------------------------------------------------------------------------------------------+
//|   SymbolType()                                                                                                                        |
//|=======================================================================================================================================|
//|   int SymbolType(bool verbose=false)                                                                                                  |
//|                                                                                                                                       |
//|   Analyzes Symbol() to determine the SymbolType for use with Profit/Loss and lotsize calcs.                                           |
//|   The function returns an integer value which is the SymbolType.                                                                      |
//|   An integer value of 6 for SymbolType is returned in the event of an error                                                           |
//|                                                                                                                                       |
//|   Parameters:                                                                                                                         |
//|                                                                                                                                       |
//|      verbose     -  Determines whether Print messages are committed to the experts log. By default, print messages are disabled.      |
//|                                                                                                                                       |
//|   Examples:                                                                                                                           |
//|                                                                                                                                       |
//|      SymbolType 1:  Symbol() = USDJPY                                                                                                 |
//|                                                                                                                                       |
//|                     Base = USD                                                                                                        |
//|                     Counter = JPY                                                                                                     |
//|                                                                                                                                       |
//|      SymbolType 2:  Symbol() = EURUSD                                                                                                 |
//|                                                                                                                                       |
//|                     Base = EUR                                                                                                        |
//|                     Counter = USD                                                                                                     |
//|                                                                                                                                       |
//|      SymbolType 3:  Symbol() = CHFJPY                                                                                                 |
//|                                                                                                                                       |
//|                     Base = CHF                                                                                                        |
//|                     Counter = JPY                                                                                                     |
//|                                                                                                                                       |
//|                     USD is base to the base currency pair - USDCHF                                                                    |
//|                                                                                                                                       |
//|                     USD is base to the counter currency pair - USDJPY                                                                 |
//|                                                                                                                                       |
//|      SymbolType 4:  Symbol() = AUDCAD                                                                                                 |
//|                                                                                                                                       |
//|                     Base = AUD                                                                                                        |
//|                     Counter = CAD                                                                                                     |
//|                                                                                                                                       |
//|                     USD is counter to the base currency pair - AUDUSD                                                                 |
//|                                                                                                                                       |
//|                     USD is base to the counter currency pair - USDCAD                                                                 |
//|                                                                                                                                       |
//|      SymbolType 5:  Symbol() = EURGBP                                                                                                 |
//|                                                                                                                                       |
//|                     Base = EUR                                                                                                        |
//|                     Counter = GBP                                                                                                     |
//|                                                                                                                                       |
//|                     USD is counter to the base currency pair - EURUSD                                                                 |
//|                                                                                                                                       |
//|                     USD is counter to the counter currency pair - GBPUSD                                                              |
//|                                                                                                                                       |
//|      SymbolType 6:  Error occurred, SymbolType could not be identified                                                                |
//|                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------+
int SymbolType(bool verbose=false)
   {  // SymbolType body start
   int   CalculatedSymbolType=6;
   string   CurrentSymbol="",SymbolBase="",SymbolCounter="",postfix="",CalculatedBasePairForCross="",CalculatedCounterPairForCross="";
   
   CurrentSymbol=Symbol();
   
   if(verbose==true) Print("Account currency is ", AccountCurrency()," and Current Symbol = ",CurrentSymbol);
   
   SymbolBase=StringSubstr(CurrentSymbol,0,3);
   SymbolCounter=StringSubstr(CurrentSymbol,3,3);
   postfix=StringSubstr(CurrentSymbol,6);
   
   if(SymbolBase==AccountCurrency()) CalculatedSymbolType=1;
   if(SymbolCounter==AccountCurrency()) CalculatedSymbolType=2;
   
   if((CalculatedSymbolType==1 || CalculatedSymbolType==2) && verbose==true) Print("Base currency is ",SymbolBase," and the Counter currency is ",SymbolCounter," (this pair is a major)");

   if(CalculatedSymbolType!=1 && CalculatedSymbolType!=2)
      {
      if(verbose==true) Print("Base currency is ",SymbolBase," and the Counter currency is ",SymbolCounter," (this pair is a cross)");

      // Determine if AccountCurrency() is the COUNTER currency or the BASE currency for the COUNTER currency forming Symbol()
      if(MarketInfo(StringConcatenate(AccountCurrency(),SymbolCounter,postfix),MODE_LOTSIZE)>0)
         {
         CalculatedSymbolType=4; // SymbolType can also be 3 but this will be determined later when the Base pair is identified
         CalculatedCounterPairForCross=StringConcatenate(AccountCurrency(),SymbolCounter,postfix);
         if(verbose==true) Print((string) AccountCurrency()," is the Base currency to the Counter currency for this cross, the CounterPair is ",CalculatedCounterPairForCross,", Bid = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_BID),MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_ASK),MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS)));
         }
      else if(MarketInfo(StringConcatenate(SymbolCounter,AccountCurrency(),postfix),MODE_LOTSIZE)>0)
         {
         CalculatedSymbolType=5;
         CalculatedCounterPairForCross=StringConcatenate(SymbolCounter,AccountCurrency(),postfix);
         if(verbose==true) Print(AccountCurrency()," is the Counter currency to the Counter currency for this cross, the CounterPair is ",CalculatedCounterPairForCross,", Bid = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_BID),MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_ASK),MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS)));
         }
      
      // Determine if AccountCurrency() is the COUNTER currency or the BASE currency for the BASE currency forming Symbol()
      if(MarketInfo(StringConcatenate(AccountCurrency(),SymbolBase,postfix),MODE_LOTSIZE)>0)
         {
         CalculatedSymbolType=3;
         CalculatedBasePairForCross=StringConcatenate(AccountCurrency(),SymbolBase,postfix);
         if(verbose==true) Print(AccountCurrency()," is the Base currency to the Base currency for this cross, the BasePair is ",CalculatedBasePairForCross,", Bid = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_BID),MarketInfo(CalculatedBasePairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_ASK),MarketInfo(CalculatedBasePairForCross,MODE_DIGITS)));
         }
      else if(MarketInfo(StringConcatenate(SymbolBase,AccountCurrency(),postfix),MODE_LOTSIZE)>0)
         {
         CalculatedBasePairForCross=StringConcatenate(SymbolBase,AccountCurrency(),postfix);
         if(verbose==true) Print(AccountCurrency()," is the Counter currency to the Base currency for this cross, the BasePair is ",CalculatedBasePairForCross,", Bid = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_BID),MarketInfo(CalculatedBasePairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_ASK),MarketInfo(CalculatedBasePairForCross,MODE_DIGITS)));
         }
      }
   if(verbose==true) Print("SymbolType() = ",CalculatedSymbolType);
   
   if(CalculatedSymbolType==6) Print("Error occurred while identifying SymbolType(), calculated SymbolType() = ",CalculatedSymbolType);
   
   return(CalculatedSymbolType);
   }  // SymbolType body end

//+---------------------------------------------------------------------------------------------------------------------------------------+
//|   BasePairForCross()                                                                                                                  |
//|=======================================================================================================================================|
//|   string BasePairForCross(bool verbose=false)                                                                                         |
//|                                                                                                                                       |
//|   Analyzes Symbol() to determine if AccountCurrency() is the COUNTER currency or the BASE currency for the BASE currency in Symbol()  |
//|   in the event that Symbol() is a cross-currency financial instrument.                                                                |
//|   Returns a text string with the name of the financial instrument which is the base currency pair to Symbol() if possible,            |
//|   otherwise, it returns an empty string.                                                                                              |
//|                                                                                                                                       |
//|   Parameters:                                                                                                                         |
//|                                                                                                                                       |
//|      verbose     -  Determines whether Print messages are committed to the experts log. By default, print messages are disabled.      |
//|                                                                                                                                       |
//|   Sample:                                                                                                                             |
//|                                                                                                                                       |
//|      // Symbol()=CHFJPY                                                                                                               |
//|      // AccountCurrency()=USD                                                                                                         |
//|      string   CrossBasePair=BasePairForCross();   // USD is base to the base currency pair - USDCHF                                   |
//|      Print("The base pair for the cross-currency instrument ",Symbol()," is ",CrossBasePair);                                         |
//|                                                                                                                                       |
//|   Examples:                                                                                                                           |
//|                                                                                                                                       |
//|      SymbolType 3:  Symbol() = CHFJPY                                                                                                 |
//|                                                                                                                                       |
//|                     Base = CHF                                                                                                        |
//|                     Counter = JPY                                                                                                     |
//|                                                                                                                                       |
//|                     USD is base to the base currency pair - USDCHF                                                                    |
//|                                                                                                                                       |
//|                     USD is base to the counter currency pair - USDJPY                                                                 |
//|                                                                                                                                       |
//|      SymbolType 4:  Symbol() = AUDCAD                                                                                                 |
//|                                                                                                                                       |
//|                     Base = AUD                                                                                                        |
//|                     Counter = CAD                                                                                                     |
//|                                                                                                                                       |
//|                     USD is counter to the base currency pair - AUDUSD                                                                 |
//|                                                                                                                                       |
//|                     USD is base to the counter currency pair - USDCAD                                                                 |
//|                                                                                                                                       |
//|      SymbolType 5:  Symbol() = EURGBP                                                                                                 |
//|                                                                                                                                       |
//|                     Base = EUR                                                                                                        |
//|                     Counter = GBP                                                                                                     |
//|                                                                                                                                       |
//|                     USD is counter to the base currency pair - EURUSD                                                                 |
//|                                                                                                                                       |
//|                     USD is counter to the counter currency pair - GBPUSD                                                              |
//|                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------+
string BasePairForCross(bool verbose=false)
   {  // BasePairForCross body start
   string   CurrentSymbol="",SymbolBase="",SymbolCounter="",postfix="",CalculatedBasePairForCross="";
   
   CurrentSymbol=Symbol();
   
   if(verbose==true) Print("Account currency is ", AccountCurrency()," and Current Symbol = ",CurrentSymbol);
   
   SymbolBase=StringSubstr(CurrentSymbol,0,3);
   SymbolCounter=StringSubstr(CurrentSymbol,3,3);
   postfix=StringSubstr(CurrentSymbol,6);
   
   switch(SymbolType()) // Determine if AccountCurrency() is the COUNTER currency or the BASE currency for the BASE currency forming Symbol()
      {
      case 1   :  break;
      case 2   :  break;
      case 3   :  CalculatedBasePairForCross=StringConcatenate(AccountCurrency(),SymbolBase,postfix);
                  if(verbose==true) Print(AccountCurrency()," is the Base currency to the Base currency for this cross, the BasePair is ",CalculatedBasePairForCross,", Bid = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_BID),MarketInfo(CalculatedBasePairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_ASK),MarketInfo(CalculatedBasePairForCross,MODE_DIGITS))); break;
      case 4   :  CalculatedBasePairForCross=StringConcatenate(SymbolBase,AccountCurrency(),postfix);
                  if(verbose==true) Print(AccountCurrency()," is the Counter currency to the Base currency for this cross, the BasePair is ",CalculatedBasePairForCross,", Bid = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_BID),MarketInfo(CalculatedBasePairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_ASK),MarketInfo(CalculatedBasePairForCross,MODE_DIGITS))); break;
      case 5   :  CalculatedBasePairForCross=StringConcatenate(SymbolBase,AccountCurrency(),postfix);
                  if(verbose==true) Print(AccountCurrency()," is the Counter currency to the Base currency for this cross, the BasePair is ",CalculatedBasePairForCross,", Bid = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_BID),MarketInfo(CalculatedBasePairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_ASK),MarketInfo(CalculatedBasePairForCross,MODE_DIGITS))); break;
      case 6   :  Print("Error occurred while identifying SymbolType(), calculated SymbolType() = 6"); break;
      default  :  Print("Error encountered in the SWITCH routine for identifying BasePairForCross on financial instrument ",CurrentSymbol); // The expression did not generate a case value
      }
   
   return(CalculatedBasePairForCross);
   
   }  // BasePairForCross body end

//+---------------------------------------------------------------------------------------------------------------------------------------+
//|   CounterPairForCross()                                                                                                               |
//|=======================================================================================================================================|
//|   string CounterPairForCross(bool verbose=false)                                                                                      |
//|                                                                                                                                       |
//|   Analyzes Symbol() to determine if AccountCurrency() is the COUNTER currency or the BASE currency for the COUNTER currency in        |
//|   Symbol() in the event that Symbol() is a cross-currency financial instrument.                                                       |
//|   Returns a text string with the name of the financial instrument which is the counter currency pair to Symbol() if possible,         |
//|   otherwise, it returns an empty string.                                                                                              |
//|                                                                                                                                       |
//|   Parameters:                                                                                                                         |
//|                                                                                                                                       |
//|      verbose     -  Determines whether Print messages are committed to the experts log. By default, print messages are disabled.      |
//|                                                                                                                                       |
//|   Sample:                                                                                                                             |
//|                                                                                                                                       |
//|      // Symbol()=CHFJPY                                                                                                               |
//|      // AccountCurrency()=USD                                                                                                         |
//|      string   CrossCounterPair=CounterPairForCross();   // USD is base to the counter currency pair - USDJPY                          |
//|      Print("The counter pair for the cross-currency instrument ",Symbol()," is ",CrossCounterPair);                                   |
//|                                                                                                                                       |
//|   Examples:                                                                                                                           |
//|                                                                                                                                       |
//|      SymbolType 3:  Symbol() = CHFJPY                                                                                                 |
//|                                                                                                                                       |
//|                     Base = CHF                                                                                                        |
//|                     Counter = JPY                                                                                                     |
//|                                                                                                                                       |
//|                     USD is base to the base currency pair - USDCHF                                                                    |
//|                                                                                                                                       |
//|                     USD is base to the counter currency pair - USDJPY                                                                 |
//|                                                                                                                                       |
//|      SymbolType 4:  Symbol() = AUDCAD                                                                                                 |
//|                                                                                                                                       |
//|                     Base = AUD                                                                                                        |
//|                     Counter = CAD                                                                                                     |
//|                                                                                                                                       |
//|                     USD is counter to the base currency pair - AUDUSD                                                                 |
//|                                                                                                                                       |
//|                     USD is base to the counter currency pair - USDCAD                                                                 |
//|                                                                                                                                       |
//|      SymbolType 5:  Symbol() = EURGBP                                                                                                 |
//|                                                                                                                                       |
//|                     Base = EUR                                                                                                        |
//|                     Counter = GBP                                                                                                     |
//|                                                                                                                                       |
//|                     USD is counter to the base currency pair - EURUSD                                                                 |
//|                                                                                                                                       |
//|                     USD is counter to the counter currency pair - GBPUSD                                                              |
//|                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------+
string CounterPairForCross(bool verbose=false)
   {  // CounterPairForCross body start
   string   CurrentSymbol="",SymbolBase="",SymbolCounter="",postfix="",CalculatedCounterPairForCross="";
   
   CurrentSymbol=Symbol();
   
   if(verbose==true) Print("Account currency is ", AccountCurrency()," and Current Symbol = ",CurrentSymbol);
   
   SymbolBase=StringSubstr(CurrentSymbol,0,3);
   SymbolCounter=StringSubstr(CurrentSymbol,3,3);
   postfix=StringSubstr(CurrentSymbol,6);
   
   switch(SymbolType()) // Determine if AccountCurrency() is the COUNTER currency or the BASE currency for the COUNTER currency forming Symbol()
      {
      case 1   :  break;
      case 2   :  break;
      case 3   :  CalculatedCounterPairForCross=StringConcatenate(AccountCurrency(),SymbolCounter,postfix);
                  if(verbose==true) Print(AccountCurrency()," is the Base currency to the Counter currency for this cross, the CounterPair is ",CalculatedCounterPairForCross,", Bid = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_BID),MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_ASK),MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS))); break;
      case 4   :  CalculatedCounterPairForCross=StringConcatenate(AccountCurrency(),SymbolCounter,postfix);
                  if(verbose==true) Print(AccountCurrency()," is the Base currency to the Counter currency for this cross, the CounterPair is ",CalculatedCounterPairForCross,", Bid = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_BID),MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_ASK),MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS))); break;
      case 5   :  CalculatedCounterPairForCross=StringConcatenate(SymbolCounter,AccountCurrency(),postfix);
                  if(verbose==true) Print(AccountCurrency()," is the Counter currency to the Counter currency for this cross, the CounterPair is ",CalculatedCounterPairForCross,", Bid = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_BID),MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_ASK),MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS))); break;
      case 6   :  Print("Error occurred while identifying SymbolType(), calculated SymbolType() = 6"); break;
      default  :  Print("Error encountered in the SWITCH routine for identifying CounterPairForCross on financial instrument ",CurrentSymbol); // The expression did not generate a case value
      }
   
   return(CalculatedCounterPairForCross);
   
   }  // CounterPairForCross body end

//+---------------------------------------------------------------------------------------------------------------------------------------+
//|   SymbolLeverage()                                                                                                                    |
//|=======================================================================================================================================|
//|   int SymbolLeverage(bool verbose=false)                                                                                              |
//|                                                                                                                                       |
//|   Analyzes Symbol() to determine the broker's required leverage for the financial instrument.                                         |
//|   Returns an integer value representing leverage ratio if possible, otherwise, it returns a zero value.                               |
//|                                                                                                                                       |
//|   Parameters:                                                                                                                         |
//|                                                                                                                                       |
//|      verbose     -  Determines whether Print messages are committed to the experts log. By default, print messages are disabled.      |
//|                                                                                                                                       |
//|   Sample:                                                                                                                             |
//|                                                                                                                                       |
//|      // Symbol()=CHFJPY                                                                                                               |
//|      // AccountCurrency()=USD                                                                                                         |
//|      int   CalculatedLeverage=SymbolLeverage();   // Leverage for USDJPY is set to 100:1                                           |
//|      Print("Leverage for ",Symbol()," is set at ",CalculatedLeverage,":1");                                                           |
//|                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------+
int SymbolLeverage(bool verbose=false)
   {  // SymbolLeverage body start
   int   CalculatedLeverage=0;
   string   CurrentSymbol="",CalculatedBasePairForCross="";
   
   CurrentSymbol=Symbol();
   
   switch(SymbolType()) // Determine the leverage for the financial instrument based on the instrument's SymbolType (major, cross, etc)
      {
      case 1   :  CalculatedLeverage=NormalizeDouble(MarketInfo(CurrentSymbol,MODE_LOTSIZE)/MarketInfo(CurrentSymbol,MODE_MARGINREQUIRED),2); break;
      case 2   :  CalculatedLeverage=NormalizeDouble(MarketInfo(CurrentSymbol,MODE_ASK)*MarketInfo(CurrentSymbol,MODE_LOTSIZE)/MarketInfo(CurrentSymbol,MODE_MARGINREQUIRED),2); break;
      case 3   :  CalculatedBasePairForCross=BasePairForCross();
                  CalculatedLeverage=NormalizeDouble(2*MarketInfo(CurrentSymbol,MODE_LOTSIZE)/((MarketInfo(CalculatedBasePairForCross,MODE_BID)+MarketInfo(CalculatedBasePairForCross,MODE_ASK))*MarketInfo(CurrentSymbol,MODE_MARGINREQUIRED)),2); break;
      case 4   :  CalculatedBasePairForCross=BasePairForCross();
                  CalculatedLeverage=NormalizeDouble(MarketInfo(CurrentSymbol,MODE_LOTSIZE)*(MarketInfo(CalculatedBasePairForCross,MODE_BID)+MarketInfo(CalculatedBasePairForCross,MODE_ASK))/(2*MarketInfo(CurrentSymbol,MODE_MARGINREQUIRED)),2); break;
      case 5   :  CalculatedBasePairForCross=BasePairForCross();
                  CalculatedLeverage=NormalizeDouble(MarketInfo(CurrentSymbol,MODE_LOTSIZE)*(MarketInfo(CalculatedBasePairForCross,MODE_BID)+MarketInfo(CalculatedBasePairForCross,MODE_ASK))/(2*MarketInfo(CurrentSymbol,MODE_MARGINREQUIRED)),2); break;
      case 6   :  Print("Error occurred while identifying SymbolType(), calculated SymbolType() = 6"); break;
      default  :  Print("Error encountered in the SWITCH routine for calculating Leverage on financial instrument ",CurrentSymbol); // The expression did not generate a case value
      }
   
   if(verbose==true) Print("Leverage for ",CurrentSymbol," is set at ",CalculatedLeverage,":1");
   
   return(CalculatedLeverage);
   
   }  // SymbolLeverage body end

//+------------------------------------------------------------------------------------------------+
//| AnalyzeSymbol()                                                                                |
//|================================================================================================|
//| Analysis routines for characterizing the resultant trade metrics                               |
//+------------------------------------------------------------------------------------------------+
void AnalyzeSymbol()
   {  // AnalyzeSymbol body start
   double   CalculatedLeverage=0,CalculatedMarginRequiredLong=0,CalculatedMarginRequiredShort=0;
   int      CalculatedSymbolType=0,ticket=0,LotSizeDigits=0,CurrentOrderType=0;
   string   CurrentSymbol="",SymbolBase="",SymbolCounter="",postfix="",CalculatedBasePairForCross="",CalculatedCounterPairForCross="";
   
   CurrentSymbol=Symbol();
   
   Print("Account currency is ", AccountCurrency()," and max allowed account leverage is ",AccountLeverage(),":1");
   
   Print("Current Symbol = ",CurrentSymbol,", Bid = ",DoubleToStr(MarketInfo(CurrentSymbol,MODE_BID),MarketInfo(CurrentSymbol,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(CurrentSymbol,MODE_ASK),MarketInfo(CurrentSymbol,MODE_DIGITS)));
   
   SymbolBase=StringSubstr(CurrentSymbol,0,3);
   SymbolCounter=StringSubstr(CurrentSymbol,3,3);
   postfix=StringSubstr(CurrentSymbol,6);
   
   CalculatedSymbolType=SymbolType();
   
   if(CalculatedSymbolType==6)
      {
      Print("Error occurred while identifying SymbolType(), calculated SymbolType() = ",CalculatedSymbolType);
      return;
      }
   Print("CalculatedSymbolType() = ",CalculatedSymbolType);
   
   CalculatedLeverage=SymbolLeverage();
   
   switch(CalculatedSymbolType) // Determine the Base and Counter pairs for the financial instrument based on the instrument's SymbolType (major, cross, etc)
      {
      case 1   :  Print("Base currency is ",SymbolBase," and the Counter currency is ",SymbolCounter); break;
      case 2   :  Print("Base currency is ",SymbolBase," and the Counter currency is ",SymbolCounter); break;
      case 3   :  Print("Base currency is ",SymbolBase," and the Counter currency is ",SymbolCounter," (this pair is a cross)");
                  CalculatedBasePairForCross=BasePairForCross();
                  CalculatedCounterPairForCross=CounterPairForCross();
                  Print(AccountCurrency()," is the Base currency to the Base currency for this cross, the BasePair is ",CalculatedBasePairForCross,", Bid = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_BID),MarketInfo(CalculatedBasePairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_ASK),MarketInfo(CalculatedBasePairForCross,MODE_DIGITS)));
                  Print(AccountCurrency()," is the Base currency to the Counter currency for this cross, the CounterPair is ",CalculatedCounterPairForCross,", Bid = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_BID),MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_ASK),MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS))); break;
      case 4   :  Print("Base currency is ",SymbolBase," and the Counter currency is ",SymbolCounter," (this pair is a cross)");
                  CalculatedBasePairForCross=BasePairForCross();
                  CalculatedCounterPairForCross=CounterPairForCross();
                  Print(AccountCurrency()," is the Counter currency to the Base currency for this cross, the BasePair is ",CalculatedBasePairForCross,", Bid = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_BID),MarketInfo(CalculatedBasePairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_ASK),MarketInfo(CalculatedBasePairForCross,MODE_DIGITS)));
                  Print(AccountCurrency()," is the Base currency to the Counter currency for this cross, the CounterPair is ",CalculatedCounterPairForCross,", Bid = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_BID),MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_ASK),MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS))); break;
      case 5   :  Print("Base currency is ",SymbolBase," and the Counter currency is ",SymbolCounter," (this pair is a cross)");
                  CalculatedBasePairForCross=BasePairForCross();
                  CalculatedCounterPairForCross=CounterPairForCross();
                  Print(AccountCurrency()," is the Counter currency to the Base currency for this cross, the BasePair is ",CalculatedBasePairForCross,", Bid = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_BID),MarketInfo(CalculatedBasePairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_ASK),MarketInfo(CalculatedBasePairForCross,MODE_DIGITS)));
                  Print(AccountCurrency()," is the Counter currency to the Counter currency for this cross, the CounterPair is ",CalculatedCounterPairForCross,", Bid = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_BID),MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_ASK),MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS))); break;
      default  :  Print("Error encountered in the SWITCH routine for reporting on financial instrument ",CurrentSymbol); // The expression did not generate a case value
      }
   
   Print("MODE_POINT = ",DoubleToStr(MarketInfo(CurrentSymbol,MODE_POINT),MarketInfo(CurrentSymbol,MODE_DIGITS))," (Point size in the quote currency)");
   Print("MODE_TICKSIZE = ",DoubleToStr(MarketInfo(CurrentSymbol,MODE_TICKSIZE),MarketInfo(CurrentSymbol,MODE_DIGITS))," (Tick size in the quote currency)");
   
   Print("MODE_TICKVALUE = ",DoubleToStr(MarketInfo(CurrentSymbol,MODE_TICKVALUE),6)," (Tick value in the deposit currency)");
   switch(CalculatedSymbolType) // Determine the tickvalue for the financial instrument based on the instrument's SymbolType (major, cross, etc)
      {
      case 1   :  Print("Calculated TICKVALUE = ",DoubleToStr(MarketInfo(CurrentSymbol,MODE_POINT)*MarketInfo(CurrentSymbol,MODE_LOTSIZE)/MarketInfo(CurrentSymbol,MODE_BID),6)," (Tick value in the deposit currency - base)"); break;
      case 2   :  Print("Calculated TICKVALUE = ",DoubleToStr(MarketInfo(CurrentSymbol,MODE_POINT)*MarketInfo(CurrentSymbol,MODE_LOTSIZE),6)," (Tick value in the deposit currency - counter)"); break;
      case 3   :  Print("Calculated TICKVALUE = ",DoubleToStr(MarketInfo(CurrentSymbol,MODE_POINT)*MarketInfo(CurrentSymbol,MODE_LOTSIZE)/MarketInfo(CalculatedCounterPairForCross,MODE_BID),6)," (Tick value in the deposit currency - ",AccountCurrency()," is Base to Counter)"); break;
      case 4   :  Print("Calculated TICKVALUE = ",DoubleToStr(MarketInfo(CurrentSymbol,MODE_POINT)*MarketInfo(CurrentSymbol,MODE_LOTSIZE)/MarketInfo(CalculatedCounterPairForCross,MODE_BID),6)," (Tick value in the deposit currency - ",AccountCurrency()," is Base to Counter)"); break;
      case 5   :  Print("Calculated TICKVALUE = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_BID)*MarketInfo(CurrentSymbol,MODE_POINT)*MarketInfo(CurrentSymbol,MODE_LOTSIZE),6)," (Tick value in the deposit currency - ",AccountCurrency()," is Counter to Counter)"); break;
      default  :  Print("Error encountered in the SWITCH routine for calculating tickvalue of financial instrument ",CurrentSymbol); // The expression did not generate a case value
      }
   
   Print("MODE_DIGITS = ",MarketInfo(CurrentSymbol,MODE_DIGITS)," (Count of digits after decimal point in the symbol prices)");
   Print("MODE_SPREAD = ",MarketInfo(CurrentSymbol,MODE_SPREAD)," (Spread value in points)");
   Print("MODE_STOPLEVEL = ",MarketInfo(CurrentSymbol,MODE_STOPLEVEL)," (Stop level in points)");
   Print("MODE_LOTSIZE = ",MarketInfo(CurrentSymbol,MODE_LOTSIZE)," (Lot size in the Base currency)");
   Print("MODE_MINLOT = ",MarketInfo(CurrentSymbol,MODE_MINLOT)," (Minimum permitted amount of a lot)");
   Print("MODE_LOTSTEP = ",MarketInfo(CurrentSymbol,MODE_LOTSTEP)," (Step for changing lots)");
   Print("MODE_MARGINREQUIRED = ",MarketInfo(CurrentSymbol,MODE_MARGINREQUIRED)," (Free margin required to open 1 lot for buying)");
   
   switch(CalculatedSymbolType) // Determine the margin required to open 1 lot position for the financial instrument based on the instrument's SymbolType (major, cross, etc)
      {
      case 1   :  CalculatedMarginRequiredLong=NormalizeDouble(MarketInfo(CurrentSymbol,MODE_LOTSIZE)/CalculatedLeverage,2);
                  Print("Calculated MARGINREQUIRED = ",CalculatedMarginRequiredLong," (Free margin required to open 1 lot for buying)");
                  Print("Calculated Leverage = ",CalculatedLeverage,":1 for this specific financial instrument (",CurrentSymbol,")"); break;
      case 2   :  CalculatedMarginRequiredLong=NormalizeDouble(MarketInfo(CurrentSymbol,MODE_ASK)*MarketInfo(CurrentSymbol,MODE_LOTSIZE)/CalculatedLeverage,2);
                  CalculatedMarginRequiredShort=NormalizeDouble(MarketInfo(CurrentSymbol,MODE_BID)*MarketInfo(CurrentSymbol,MODE_LOTSIZE)/CalculatedLeverage,2);
                  Print("Calculated MARGINREQUIRED = ",CalculatedMarginRequiredLong," for Buy (free margin required to open 1 lot position as long), and Calculated MARGINREQUIRED = ",CalculatedMarginRequiredShort," for Sell (free margin required to open 1 lot position as short)");
                  Print("Calculated Leverage = ",CalculatedLeverage,":1 for this specific financial instrument (",CurrentSymbol,")"); break;
      case 3   :  CalculatedMarginRequiredLong=NormalizeDouble(2*MarketInfo(CurrentSymbol,MODE_LOTSIZE)/((MarketInfo(CalculatedBasePairForCross,MODE_BID)+MarketInfo(CalculatedBasePairForCross,MODE_ASK))*CalculatedLeverage),2);
                  Print("Calculated MARGINREQUIRED = ",CalculatedMarginRequiredLong," (Free margin required to open 1 lot for buying)");
                  Print("Calculated Leverage = ",CalculatedLeverage,":1 for this specific financial instrument (",CurrentSymbol,")"); break;
      case 4   :  CalculatedMarginRequiredLong=NormalizeDouble(MarketInfo(CurrentSymbol,MODE_LOTSIZE)*(MarketInfo(CalculatedBasePairForCross,MODE_BID)+MarketInfo(CalculatedBasePairForCross,MODE_ASK))/(2*CalculatedLeverage),2);
                  Print("Calculated MARGINREQUIRED = ",CalculatedMarginRequiredLong," (Free margin required to open 1 lot for buying)");
                  Print("Calculated Leverage = ",CalculatedLeverage,":1 for this specific financial instrument (",CurrentSymbol,")"); break;
      case 5   :  CalculatedMarginRequiredLong=NormalizeDouble(MarketInfo(CurrentSymbol,MODE_LOTSIZE)*(MarketInfo(CalculatedBasePairForCross,MODE_BID)+MarketInfo(CalculatedBasePairForCross,MODE_ASK))/(2*CalculatedLeverage),2);
                  Print("Calculated MARGINREQUIRED = ",CalculatedMarginRequiredLong," (Free margin required to open 1 lot for buying)");
                  Print("Calculated Leverage = ",CalculatedLeverage,":1 for this specific financial instrument (",CurrentSymbol,")"); break;
      default  :  Print("Error encountered in the SWITCH routine for calculating required margin for financial instrument ",CurrentSymbol); // The expression did not generate a case value
      }
   
   LotSizeDigits=-MathRound(MathLog(MarketInfo(CurrentSymbol,MODE_LOTSTEP))/MathLog(10.)); // Number of digits after decimal point for the Lot for the current broker, like Digits for symbol prices
   Print("Digits for lotsize = ",LotSizeDigits);
   
   }  // AnalyzeSymbol body end

// Program End

/*
   +------------------------------------------------------------------+
   |                                                                  |
   |   Revision History                                               |
   |                                                                  |
   +------------------------------------------------------------------+

 Objective: Analyze the symbol() used by the calling application and determine whether the USD is the base currency or the counter currency (in the case of symbol() being a major).
            In the case where symbol() is a cross-currency pair then the SymbolAnalysis routine will determine whether the USD is the base currency or the counter currency to the base currency for symbol() as well
            as whether the USD is the base currency or the counter currency to the counter currency of symbol()
            
            SymbolType 1:  Symbol() = USDJPY
                           
                           Base = USD
                           Counter = JPY
            
            SymbolType 2:  Symbol() = EURUSD
                           
                           Base = EUR
                           Counter = USD

            SymbolType 3:  Symbol() = CHFJPY
                           
                           Base = CHF
                           Counter = JPY
                           
                           USD is base to the base currency pair - USDCHF
                           
                           USD is base to the counter currency pair - USDJPY
            
            SymbolType 4:  Symbol() = AUDCAD
                           
                           Base = AUD
                           Counter = CAD
                           
                           USD is counter to the base currency pair - AUDUSD
                           
                           USD is base to the counter currency pair - USDCAD
            
            SymbolType 5:  Symbol() = EURGBP
                           
                           Base = EUR
                           Counter = GBP
                           
                           USD is counter to the base currency pair - EURUSD
                           
                           USD is counter to the counter currency pair - GBPUSD
            
            SymbolType 6:  Error occurred, SymbolType could not be identified
            
            The filename for the include file will be incremented to the date of the most recent changes which will correspond to the date listed below in the worklog.

 Future Work:  create versions of tickvalue calcs for use with backtester on cross-pairs
            
 Worklog:
   
   Jun 07   Stripped property details to protect the wannabe innocent (me!)

   Apr 27   Created SymbolType(), BasePairForCross(), CounterPairForCross(), and SymbolLeverage() functions.
   
   Apr 24   Creating call function "AnalyzeSymbol" for determining the base currency and counter currency for the symbol passed to it by the calling routine.
   
*/


