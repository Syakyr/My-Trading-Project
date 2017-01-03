//+------------------------------------------------------------------+
//|                                                     SBY_TPSL.mqh |
//|                                       Copyright 2016, SmartBYtes |
//|                      Fixed TP/SL Library for SmartBYtes Template |
//+------------------------------------------------------------------+

// TODO: Add dependancies comment notes to indicate the links between functions
// TODO: Give a short description on each of the include files and how to use them
// TODO: Break its dependency towards volatility and set it to accept custom-calculated TP/SL levels

#property copyright "Copyright 2016, SmartBYtes"
#property strict
#property version "1.00"
#include <SBYtes/SBY_Main.mqh>

//+------------------------------------------------------------------+
//| Setup                                                            |
//+------------------------------------------------------------------+

extern string  TPSLHeader="----------TP & SL Settings-----------";

extern bool    UseFixedStopLoss=True; // If this is false and IsSizingOn = True, sizing algo will not be able to calculate correct lot size. 
extern bool    IsVolatilityStopOn=True;
extern double  HardSLVariable=6; // Stop Loss ATR Multiplier/Pips

extern bool    UseFixedTakeProfit=True;
extern bool    IsVolatilityTakeProfitOn=True;
extern double  HardTPVariable=6; // Take Profit Amount/Pips

//----------Service Variables-----------//

double Stop,Take;

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                     FUNCTIONS LIBRARY                                   
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

Content:
1) InitialiseHardTPSL

*/

//+------------------------------------------------------------------+
//| Initialise Hard TP and SL Levels                                 |
//+------------------------------------------------------------------+ 
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function initialises the TP and SL variables

void InitialiseHardTPSL(){
   if(UseFixedStopLoss==False) Stop=0;
   else Stop=VolBasedStopLoss();

   if(UseFixedTakeProfit==False) Take=0;
   else Take=VolBasedTakeProfit();
}

//+------------------------------------------------------------------+
//| Volatility-Based Stop Loss                                       |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function calculates stop loss amount based on volatility

double VolBasedStopLoss(){
   double StopL;
   if (!IsVolatilityStopOn) StopL=HardSLVariable; // If Volatility Stop Loss not activated. Stop Loss = Fixed Pips Stop Loss
   else StopL=HardSLVariable*myATR/(P*Point); // Stop Loss in Pips
   return(StopL);
}

//+------------------------------------------------------------------+
//| Volatility-Based Take Profit                                     |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function calculates take profit amount based on volatility

double VolBasedTakeProfit(){
   double TakeP;
   if(!IsVolatilityTakeProfitOn) TakeP=HardTPVariable; // If Volatility Take Profit not activated. Take Profit = Fixed Pips Take Profit
   else TakeP=HardTPVariable*myATR/(P*Point); // Take Profit in Pips
   return(TakeP);
}
