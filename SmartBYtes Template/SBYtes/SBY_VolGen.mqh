//+------------------------------------------------------------------+
//|                                                   SBY_VolGen.mqh |
//|                                       Copyright 2016, SmartBYtes |
//|     General Volatility Variables Library for SmartBYtes Template |
//+------------------------------------------------------------------+

// TODO: Add dependancies comment notes to indicate the links between functions
// TODO: Give a short description on each of the include files and how to use them

#property copyright "Copyright 2016, SmartBYtes"
#property strict
#property version "1.00"
#include <SBYtes/SBY_Main.mqh>

//+------------------------------------------------------------------+
//| Setup                                                            |
//+------------------------------------------------------------------+

extern string  MaxVolHeader="----------Set Max Volatility Limit-----------";
extern bool    IsVolLimitActivated=False;
extern double  VolatilityMultiplier=3; // In units of ATR
extern int     ATRTimeframe=60; // In minutes
extern int     ATRPeriod=14;

//----------Errors Handling Settings-----------//

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                     FUNCTIONS LIBRARY                                   
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

Content:
1) MainInitialise
2) GetP
3) GetYenAdjustFactor
4) CrossInitialise
5) Crossed
6) CountPosOrders
7) IsMaxOrdersReached
8) Set

*/

//+------------------------------------------------------------------+
//| Is Volitility Limit Breached                                     |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function determines if our maximum volatility threshold is breached

// 2 steps to this function: 
// 1) It checks the price movement between current time and the closing price of the last completed 1min bar (shift 1 of 1min timeframe).
// 2) Return True if this price movement > VolLimitMulti * VolATR

bool IsVolLimitBreached(){

   bool output = False;
   if(IsVolLimitActivated==False) return(output);
   
   double priceMovement = MathAbs(Bid-iClose(NULL,PERIOD_M1,1)); // Not much difference if we use bid or ask prices here. We can also use iOpen at shift 0 here, it will be similar to using iClose at shift 1.
   double VolATR = iATR(NULL, ATRTimeframe, ATRPeriod, 1);
   
   if(priceMovement > VolatilityMultiplier*VolATR) output = True;

   return(output);
  }

