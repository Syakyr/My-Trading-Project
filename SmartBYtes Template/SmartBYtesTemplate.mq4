//+------------------------------------------------------------------+
//|                                      SmartBYtes EA Template v1.0 |
//|                                       Copyright 2016, SmartBYtes |
//|                 Adapted from Lucas Liew, Black Algo Technologies |
//+------------------------------------------------------------------+

// TODO: Add dependancies comment notes to indicate the links between functions
// TODO: Give a short description on each of the include files and how to use them

#property copyright "Copyright 2016, SmartBYtes"
#property version   "1.00"
//#property link      ""

/* 

SmartBYtes v1.0: 
- Adapted from the Falcon template by Lucas Liew, 
  making the template more modular so as to reduce 
  the final filesize to use.

*/

//+------------------------------------------------------------------+
//| Setup                                                            |
//+------------------------------------------------------------------+
extern string  TradingRulesHeader="----------Trading Rules Variables-----------";
extern int     FastMAPeriod=10;
extern int     SlowMAPeriod=50;
extern int     KeltnerPeriod=15;
extern int     KeltnerMulti=3;

//+------------------------------------------------------------------+
//| Include Files                                                    |
//+------------------------------------------------------------------+
// To include whatever that is needed for the strategy

#include <SBYtes/SBY_Main.mqh>
#include <SBYtes/SBY_VolGen.mqh>

#include <SBYtes/SBY_TPSL.mqh>
#include <SBYtes/SBY_TPSLHidden.mqh>

#include <SBYtes/SBY_OpenMarket.mqh>
#include <SBYtes/SBY_PendingMarket.mqh>

#include <SBYtes/SBY_BEStop.mqh>
#include <SBYtes/SBY_BEStopHidden.mqh>
#include <SBYtes/SBY_TrailStop.mqh>
#include <SBYtes/SBY_TrailStopHidden.mqh>
#include <SBYtes/SBY_VolTrailStop.mqh>
#include <SBYtes/SBY_VolTrailStopHidden.mqh>

//----------Service Variables-----------//

// Trading Rules Service Variables
// Change this as you see fit.
double FastMA1, SlowMA1, Price1;
double KeltnerUpper1, KeltnerLower1;
int    CrossTrigArraySize = 3;       // Number of variables which looks for crosses

int OrderNumber;

//+------------------------------------------------------------------+
//| Expert Initialization                                            |
//+------------------------------------------------------------------+
int init(){
   
   MainInitialise();
   CrossInitialise(CrossTrigArraySize);

//----------(Hidden) TP, SL and Breakeven Stops Variables-----------  

// If EA disconnects abruptly and there are open positions from this EA, records form these arrays will be gone.
// Block or delete the lines according to your needs in your strategy.
   if(UseHiddenStopLoss)       ArrayResize(HiddenSLList,MaxPositionsAllowed,0);          // If SBY_TPSLHidden.mqh is activated
   if(UseHiddenTakeProfit)     ArrayResize(HiddenTPList,MaxPositionsAllowed,0);          // If SBY_TPSLHidden.mqh is activated
   if(UseHiddenBreakevenStops) ArrayResize(HiddenBEList,MaxPositionsAllowed,0);          // If SBY_BEStopHidden.mqh is activated
   if(UseHiddenTrailingStops)  ArrayResize(HiddenTrailingList,MaxPositionsAllowed,0);    // If SBY_TrailStopHidden.mqh is activated
   if(UseVolTrailingStops)     ArrayResize(VolTrailingList,MaxPositionsAllowed,0);       // If SBY_VolTrailStop.mqh is activated
   if(UseHiddenVolTrailing)    ArrayResize(HiddenVolTrailingList,MaxPositionsAllowed,0); // If SBY_VolTrailStopHidden.mqh is activated

   start();
   return(0);
}

//+------------------------------------------------------------------+
//| Expert Deinitialization                                          |
//+------------------------------------------------------------------+
int deinit(){
//----

//----
   return(0);
}

//+------------------------------------------------------------------+
//| Expert start                                                     |
//+------------------------------------------------------------------+
int start(){

//----------Variables to be Refreshed-----------

   OrderNumber=0; // OrderNumber used in Entry Rules

//----------Entry & Exit Variables-----------
   
   // Assigning Values to Variables
   FastMA1=iMA(Symbol(),Period(),FastMAPeriod,0, MODE_SMA, PRICE_CLOSE,1); // Shift 1
   SlowMA1=iMA(Symbol(),Period(),SlowMAPeriod,0, MODE_SMA, PRICE_CLOSE,1); // Shift 1
   KeltnerUpper1 = iCustom(NULL, 0, "Keltner_Channels", KeltnerPeriod, 0, 0, KeltnerPeriod, KeltnerMulti, True, 0, 1); // Shift 1
   KeltnerLower1 = iCustom(NULL, 0, "Keltner_Channels", KeltnerPeriod, 0, 0, KeltnerPeriod, KeltnerMulti, True, 2, 1); // Shift 1
   
   // Use CrossTriggered array variable to store crossing signals
   // Change CrossTrigArraySize variable to store more crossing signals
   CrossTriggered[0]=Crossed(0,FastMA1,SlowMA1);
   CrossTriggered[1]=Crossed(1,Ask,KeltnerUpper1);
   CrossTriggered[2]=Crossed(2,Bid,KeltnerLower1);

//----------TP, SL, Breakeven and Trailing Stops Variables-----------
   
   // Comment this variable out if you do not use ATR values
   myATR=iATR(NULL,Period(),atr_period,1);
   
   InitialiseHardTPSL();      // If SBY_TPSL.mqh is activated
   BreakevenStopAll();        // If SBY_BEStops.mqh is activated
   TrailingStopAll();         // If SBY_Trailstop.mqh is activated
   InitialiseVolTrailStop();  // If SBY_VolTrailStop.mqh is activated
   
//----------(Hidden) TP, SL, Breakeven and Trailing Stops Variables-----------  
   
   // If SBY_TPSLHidden.mqh is activated
   if(UseHiddenStopLoss) TriggerStopLossHidden();
   if(UseHiddenTakeProfit) TriggerTakeProfitHidden();
   
   // If SBY_BEStopsHidden.mqh is activated
   if(UseHiddenBreakevenStops){ UpdateHiddenBEList(); SetAndTriggerBEHidden(); }
   
   if(UseHiddenTrailingStops){ UpdateHiddenTrailingList(); SetAndTriggerHiddenTrailing(); }
   if(UseHiddenVolTrailing){ UpdateHiddenVolTrailingList(); TriggerAndReviewHiddenVolTrailing(); }

//----------Exit Rules (All Opened Positions)-----------

   // Modify the ExitSignal() function to suit your needs.

   if(CountPosOrders(OP_BUY)>=1 && ExitSignal(CrossTriggered[2])==2){ 
      // Close Long Positions
      CloseOrderPosition(OP_BUY); 
   }
   if(CountPosOrders(OP_SELL)>=1 && ExitSignal(CrossTriggered[1])==1){ 
      // Close Short Positions
      CloseOrderPosition(OP_SELL);
   }

//----------Entry Rules (Market and Pending) -----------

   if(!IsLossLimitBreached(EntrySignal(CrossTriggered[0])) &&
      !IsMaxPositionsReached() 
      && !IsVolLimitBreached() // If SBY_VolGen.mqh is activated
      ){
            
      if(EntrySignal(CrossTriggered[0])==1){
         
         // Open Long Positions
         OrderNumber=OpenPositionMarket(GetLot(Stop),OP_BUY,Stop,Take);
   
         // If SBY_TPSLHidden.mqh is activated
         // Set Stop Loss and Take Profit value for Hidden SL/TP
         SetStopLossHidden(OrderNumber);
         SetTakeProfitHidden(OrderNumber);
         
         // Set Volatility Trailing Stop Level           
         SetVolTrailingStop(OrderNumber);
         
         // Set Hidden Volatility Trailing Stop Level 
         if(UseHiddenVolTrailing) SetHiddenVolTrailing(OrderNumber);
       
      }
   
      if(EntrySignal(CrossTriggered[0])==2){ 
         
         // Open Short Positions
         OrderNumber=OpenPositionMarket(GetLot(Stop),OP_SELL,Stop,Take);
         
         // If SBY_TPSLHidden.mqh is activated
         // Set Stop Loss and Take Profit value for Hidden SL/TP
         SetStopLossHidden(OrderNumber);
         SetTakeProfitHidden(OrderNumber);
         
         // Set Volatility Trailing Stop Level 
         SetVolTrailingStop(OrderNumber);
          
         // Set Hidden Volatility Trailing Stop Level  
         if(UseHiddenVolTrailing) SetHiddenVolTrailing(OrderNumber);
       
      }
   }

//----------Pending Order Management-----------
/*
        Not Applicable (See Desiree for example of pending order rules).
   */

//----

   return(0);
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                     FUNCTIONS LIBRARY                                   
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

Content:
   1) EntrySignal
   2) ExitSignal

*/


//+------------------------------------------------------------------+
//| Entry Signal                                                     |
//+------------------------------------------------------------------+
// Type: Customisable 
// Modify this function to suit your trading robot

// This function checks for entry signals
// If the number returned is 0, there is no signal
// If the number returned is 1, it is a buy signal
// If the number returned is 2, it is a sell signal

int EntrySignal(int CrossOccurred){
   int entryOutput=0;

   if(CrossOccurred==1) entryOutput=1; 

   if(CrossOccurred==2) entryOutput=2;

   return(entryOutput);
}

//+------------------------------------------------------------------+
//| Exit Signal                                                      |
//+------------------------------------------------------------------+
// Type: Customisable 
// Modify this function to suit your trading robot

// This function checks for exit signals
// If the number returned is 0, there is no signal
// If the number returned is 1, it is a sell close signal
// If the number returned is 2, it is a buy close signal

int ExitSignal(int CrossOccurred){
   int ExitOutput=0;

   if(CrossOccurred==1) ExitOutput=1;
   if(CrossOccurred==2) ExitOutput=2;

   return(ExitOutput);
}
