//+------------------------------+
//|   Trade Position Management  |
//+==============================+
//|
//|   Rev Date: 2010.06.07
//|
//|   Contains the following Functions:
//|
//|   EquityAtRisk()
//|   LotSize()
//|   NormalizeLotSize()
//|
//+------------------------------+

#property copyright "1005phillip"
#include <stderror.mqh>
#include <stdlib.mqh>

//+-----------------------+
//|   EquityAtRisk()      |
//+=======================+
//|
//|   double EquityAtRisk(double LotSize,double StopLossPrice,int CurrentOrderType,int CurrentSymbolType,string CurrentCounterPairForCross,bool verbose=false)
//|
//|   Computes the equity at risk for the impending trade based on the input lotsize and stoploss.
//|   Returns a double value representing the equity at risk (expressed as a positive value) if possible, otherwise, it returns a zero value.
//|
//|   Parameters:
//|      LotSize           -  Position size that will be used in the impending trade.
//|      StopLossPrice     -  The price at which point the stops will be activated and the position will be closed for total loss of the equity at risk.
//|      CurrentOrderType  -  Is the impending order going to be an OP_BUY or OP_SELL.
//|      CurrentSymbolType -  The type of currency pair represented by Symbol().
//|      CurrentCounterPairForCross -  The name of the financial instrument which is the counter currency pair to Symbol() (relevant to crosses)
//|      verbose           -  Determines whether Print messages are committed to the experts log. By default, print messages are disabled.
//|
//|   Sample:
//|
//|      CurrentLotSize=0.1;           // setting the position size at a fixed 0.1 lots
//|      CurrentStopLossPrice= 92.36   // setting the stops at a fixed price of 92.36
//|      CurrentEquityAtRisk=EquityAtRisk(CurrentLotSize,CurrentStopLossPrice,OP_BUY,1,CurrentCounterPairForCross);
//|      Print("StopLossPrice = ",StopLossPrice," and StopLoss in Pips = ",(StopLossPrice-Bid)/MarketInfo(Symbol(),MODE_POINT));
//|
//+-----------------------+

double EquityAtRisk(double LotSize,double StopLossPrice,int CurrentOrderType,int CurrentSymbolType,string CurrentCounterPairForCross,bool verbose=false)
   {  // EquityAtRisk body start
   double   CalculatedEquityAtRisk=0.;
   string   CurrentSymbol="";
   
   CurrentSymbol=Symbol();
   
   switch(CurrentSymbolType) // Determine the equity at risk based on the SymbolType for the financial instrument
      {
      case 1   :  switch(CurrentOrderType)
                     {
                     case OP_BUY    :  CalculatedEquityAtRisk=-MarketInfo(CurrentSymbol,MODE_LOTSIZE)*LotSize*(StopLossPrice-Ask)/StopLossPrice; break;
                     case OP_SELL   :  CalculatedEquityAtRisk=-MarketInfo(CurrentSymbol,MODE_LOTSIZE)*LotSize*(Bid-StopLossPrice)/StopLossPrice; break;
                     default        :  Print("Error encountered in the OrderType() routine for calculating the EquityAtRisk"); // The expression did not generate a case value
                     }
                  break;
      case 2   :  switch(CurrentOrderType)
                     {
                     case OP_BUY    :  CalculatedEquityAtRisk=-MarketInfo(CurrentSymbol,MODE_LOTSIZE)*LotSize*(StopLossPrice-Ask); break;
                     case OP_SELL   :  CalculatedEquityAtRisk=-MarketInfo(CurrentSymbol,MODE_LOTSIZE)*LotSize*(Bid-StopLossPrice); break;
                     default        :  Print("Error encountered in the OrderType() routine for calculating the EquityAtRisk"); // The expression did not generate a case value
                     }
                  break;
      case 3   :  // e.g. Symbol() = CHFJPY, the counter currency is JPY and the USD is the base to the JPY in the pair USDJPY
                  // falls thru and is treated the same as SymbolType()==4 for the purpose of these calculations
      case 4   :  switch(CurrentOrderType)  // e.g. Symbol() = AUDCAD, the counter currency is CAD and the USD is the base to the CAD in the pair USDCAD
                     {
                     case OP_BUY    :  CalculatedEquityAtRisk=-MarketInfo(CurrentSymbol,MODE_LOTSIZE)*LotSize*(StopLossPrice-Ask)/MarketInfo(CurrentCounterPairForCross,MODE_BID); break;
                     case OP_SELL   :  CalculatedEquityAtRisk=-MarketInfo(CurrentSymbol,MODE_LOTSIZE)*LotSize*(Bid-StopLossPrice)/MarketInfo(CurrentCounterPairForCross,MODE_ASK); break;
                     default        :  Print("Error encountered in the OrderType() routine for calculating the EquityAtRisk"); // The expression did not generate a case value
                     }
                  break;
      case 5   :  switch(CurrentOrderType)  // e.g. Symbol() = EURGBP, the counter currency is GBP and the USD is the counter to the GBP in the pair GBPUSD
                     {
                     case OP_BUY    :  CalculatedEquityAtRisk=-MarketInfo(CurrentSymbol,MODE_LOTSIZE)*MarketInfo(CurrentCounterPairForCross,MODE_BID)*LotSize*(StopLossPrice-Ask); break;
                     case OP_SELL   :  CalculatedEquityAtRisk=-MarketInfo(CurrentSymbol,MODE_LOTSIZE)*MarketInfo(CurrentCounterPairForCross,MODE_ASK)*LotSize*(Bid-StopLossPrice); break;
                     default        :  Print("Error encountered in the OrderType() routine for calculating the EquityAtRisk"); // The expression did not generate a case value
                     }
                  break;
      default        :  Print("Error encountered in the SWITCH routine for calculating the EquityAtRisk"); // The expression did not generate a case value
      }
   
   if(verbose==true) Print("The equity at risk with this trade is ",DoubleToStr(CalculatedEquityAtRisk,2));
   
   return(CalculatedEquityAtRisk);
   
   }  // EquityAtRisk body end

// Program End

//+------------------------+
//|   LotSize()            |
//+========================+
//|
//|   double LotSize(double EquityAtRisk,double StopLossPrice,int CurrentOrderType,int CurrentSymbolType,string CurrentCounterPairForCross,bool ReturnNormalizedLots=false,bool verbose=false)
//|
//|   Computes the lotsize that will result in placing the specificed amount of equity at risk of loss equity in the event that the specified stoploss price is reached.
//|   Returns a double value representing the lotsize if possible, otherwise, it returns a zero value.
//|
//|   Parameters:
//|      EquityAtRisk      -  Maximum allowed equity to be lost in the event the stoploss price is reached
//|      StopLossPrice     -  The price at which point the stops will be activated and the position will be closed for total loss of the equity at risk.
//|      CurrentOrderType  -  Is the impending order going to be an OP_BUY or OP_SELL.
//|      CurrentSymbolType -  The type of currency pair represented by Symbol().
//|      CurrentCounterPairForCross -  The name of the financial instrument which is the counter currency pair to Symbol() (relevant to crosses)
//|      ReturnNormalizedLots -  Computes the normalized lotsize for the broker dependent on MODE_LOTSTEP and MODE_MINLOT.
//|      verbose           -  Determines whether Print messages are committed to the experts log. By default, print messages are disabled.
//|
//|   Sample:
//|
//|      CurrentStopLossPrice= 92.36   // setting the stops at a fixed price of 92.36
//|      CurrentEquityAtRisk=500;   // Risk budget allows a loss of up to $500 per trade
//|      CurrentLotSize=LotSize(CurrentEquityAtRisk,CurrentStopLossPrice,OP_BUY,1,CurrentCounterPairForCross);
//|      Print("The calculated lot size is ",CurrentLotSize");
//|
//+-----------------------+

double LotSize(double EquityAtRisk,double StopLossPrice,int CurrentOrderType,int CurrentSymbolType,string CurrentCounterPairForCross,bool ReturnNormalizedLots=false,bool verbose=false)
   {  // LotSize body start
   double   CalculatedLotSize=0.;
   string   CurrentSymbol="";
   
   CurrentSymbol=Symbol();
   
   switch(CurrentSymbolType) // Determine the equity at risk based on the SymbolType for the financial instrument
      {
      case 1   :  switch(CurrentOrderType)   // Currency Pairs with USD as base - e.g. USDJPY
                     {
                     case OP_BUY    :  CalculatedLotSize=(-EquityAtRisk*StopLossPrice)/(MarketInfo(CurrentSymbol,MODE_LOTSIZE)*(StopLossPrice-Ask)); break;
                     case OP_SELL   :  CalculatedLotSize=(-EquityAtRisk*StopLossPrice)/(MarketInfo(CurrentSymbol,MODE_LOTSIZE)*(Bid-StopLossPrice)); break;
                     default        :  Print("Error encountered in the OrderType() routine for calculating the EquityAtRisk"); // The expression did not generate a case value
                     }
                  break;
      case 2   :  switch(CurrentOrderType)   // Currency Pairs with USD as counter - e.g. EURUSD
                     {
                     case OP_BUY    :  CalculatedLotSize=-EquityAtRisk/(MarketInfo(CurrentSymbol,MODE_LOTSIZE)*(StopLossPrice-Ask)); break;
                     case OP_SELL   :  CalculatedLotSize=-EquityAtRisk/(MarketInfo(CurrentSymbol,MODE_LOTSIZE)*(Bid-StopLossPrice)); break;
                     default        :  Print("Error encountered in the OrderType() routine for calculating the EquityAtRisk"); // The expression did not generate a case value
                     }
                  break;
      case 3   :  // e.g. Symbol() = CHFJPY, the counter currency is JPY and the USD is the base to the JPY in the pair USDJPY
                  // falls thru and is treated the same as SymbolType()==4 for the purpose of these calculations
      case 4   :  switch(CurrentOrderType)  // e.g. Symbol() = AUDCAD, the counter currency is CAD and the USD is the base to the CAD in the pair USDCAD
                     {
                     case OP_BUY    :  CalculatedLotSize=(-EquityAtRisk*MarketInfo(CurrentCounterPairForCross,MODE_BID))/(MarketInfo(CurrentSymbol,MODE_LOTSIZE)*(StopLossPrice-Ask)); break;
                     case OP_SELL   :  CalculatedLotSize=(-EquityAtRisk*MarketInfo(CurrentCounterPairForCross,MODE_ASK))/(MarketInfo(CurrentSymbol,MODE_LOTSIZE)*(Bid-StopLossPrice)); break;
                     default        :  Print("Error encountered in the OrderType() routine for calculating the EquityAtRisk"); // The expression did not generate a case value
                     }
                  break;
      case 5   :  switch(CurrentOrderType)  // e.g. Symbol() = EURGBP, the counter currency is GBP and the USD is the counter to the GBP in the pair GBPUSD
                     {
                     case OP_BUY    :  CalculatedLotSize=-EquityAtRisk/(MarketInfo(CurrentSymbol,MODE_LOTSIZE)*MarketInfo(CurrentCounterPairForCross,MODE_BID)*(StopLossPrice-Ask)); break;
                     case OP_SELL   :  CalculatedLotSize=-EquityAtRisk/(MarketInfo(CurrentSymbol,MODE_LOTSIZE)*MarketInfo(CurrentCounterPairForCross,MODE_ASK)*(Bid-StopLossPrice)); break;
                     default        :  Print("Error encountered in the OrderType() routine for calculating the EquityAtRisk"); // The expression did not generate a case value
                     }
                  break;
      default        :  Print("Error encountered in the SWITCH routine for calculating the EquityAtRisk"); // The expression did not generate a case value
      }
   
   if(CalculatedLotSize<0) CalculatedLotSize=0;
   
   if(ReturnNormalizedLots==true) CalculatedLotSize=NormalizeLotSize(CalculatedLotSize);
   
   if(verbose==true) Print("The calculated lot size is ",CalculatedLotSize);
   
   return(CalculatedLotSize);
   
   }  // LotSize body end

// Program End

//+------------------------+
//|   NormalizeLotSize()   |
//+========================+
//|
//|   double NormalizeLotSize(double CurrentLotSize,bool verbose=false)
//|
//|   Computes the normalized lotsize for the broker dependent on MODE_LOTSTEP and MODE_MINLOT.
//|   Returns a double value representing the largest normalized lotsize that is less than or equal to CurrentLotSize if possible, otherwise, it returns a zero value.
//|
//|   Parameters:
//|      CurrentLotSize -  Position size that is proposed for usage in an impending trade.
//|      verbose        -  Determines whether Print messages are committed to the experts log. By default, print messages are disabled.
//|
//|   Sample:
//|
//|      CurrentLotSize=0.12345678                                      // previously calculated lotsize based on max allowed equity at risk
//|      NormalizedLotSize=NormalizeLotSize(CurrentLotSize);            // determine the properly normalized (broker specific) lotsize
//|      Print("The normalized lot size is ",NormalizedLotSize");       // The normalized lot size is 0.12, for example
//|
//+-----------------------+

double NormalizeLotSize(double CurrentLotSize,bool verbose=false)
   {  // NormalizeLotSize body start
   double   CalculatedNormalizeLotSize=0.;
   int      LotSizeDigits=0;
   string   CurrentSymbol="";
   
   CurrentSymbol=Symbol();
      
   LotSizeDigits=-MathRound(MathLog(MarketInfo(CurrentSymbol,MODE_LOTSTEP))/MathLog(10.)); // Number of digits after decimal point for the Lot for the current broker, like Digits for symbol prices
   
   CalculatedNormalizeLotSize=NormalizeDouble(MathFloor((CurrentLotSize-MarketInfo(CurrentSymbol,MODE_MINLOT))/MarketInfo(CurrentSymbol,MODE_LOTSTEP))*MarketInfo(CurrentSymbol,MODE_LOTSTEP)+MarketInfo(CurrentSymbol,MODE_MINLOT),LotSizeDigits);
   
   if(verbose==true) Print("The broker-normalized lotsize is ",DoubleToStr(CalculatedNormalizeLotSize,LotSizeDigits));
   
   return(CalculatedNormalizeLotSize);
   
   }  // NormalizeLotSize body end

// Program End

/*
   +------------------------------------------------------------------+
   |                                                                  |
   |   Revision History                                               |
   |                                                                  |
   +------------------------------------------------------------------+

 Objective: This include file will contain the routines necessary for computing stoplossprice based on a stoplosspercent stops method as well as compute the equity at risk for a
            given trade position size (lotsize) and the stops that will be used in the trade.
            
 Future Work:  tbd
            
 Worklog:
   
   Jun 07   Changed NormalizeLotSize() to incorporate LotSizeDigits determination internally, no longer a passed parameter
            Stripped property details to protect the wannabe innocent (me!)
   
   May 20   Removing StopLossPrice() and placing it in a new include file that will house various stoploss calculation implementations.
   
   May 03   Creating call function LotSize() and NormalizeLotSize().
   
   Apr 29   Creating call functions StopLossPrice() and EquityAtRisk().
   
*/


