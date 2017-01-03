//+------------------------------------------------------------------+
//|                                                   SBY_VolGen.mqh |
//|                                       Copyright 2016, SmartBYtes |
//|                   Breakeven Stop Library for SmartBYtes Template |
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

extern string  BEStopsHeader="----------Breakeven Stops Settings-----------";
extern bool    UseBreakevenStops=False;
extern double  BreakevenBuffer=0; // In pips

//----------Errors Handling Settings-----------//

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                     FUNCTIONS LIBRARY                                   
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

Content:
   1) BreakevenStopAll

*/

//+------------------------------------------------------------------+
//| Breakeven Stop                                                   |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing 

// This function sets breakeven stops for all positions

void BreakevenStopAll(){

   if (UseBreakevenStops){
      for(int i=OrdersTotal()-1; i>=0; i--){
         bool Modify=false;
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true && OrderSymbol()==Symbol() && 
            OrderMagicNumber()==MagicNumber){
            RefreshRates();
            if(OrderType()==OP_BUY && (Bid-OrderOpenPrice())>(BreakevenBuffer*P*Point)){
               if(OnJournaling)Print("EA Journaling: Trying to modify order "+(string)OrderTicket()+" ...");
               HandleTradingEnvironment();
               Modify=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,CLR_NONE);
               if(OnJournaling && !Modify) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                                 GetErrorDescription(GetLastError()));
               if(OnJournaling &&  Modify) Print("EA Journaling: Order successfully modified, breakeven stop updated.");
            }
            if(OrderType()==OP_SELL && (OrderOpenPrice()-Ask)>(BreakevenBuffer*P*Point)){
               if(OnJournaling)Print("EA Journaling: Trying to modify order "+(string)OrderTicket()+" ...");
               HandleTradingEnvironment();
               Modify=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,CLR_NONE);
               if(OnJournaling && !Modify) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                                 GetErrorDescription(GetLastError()));
               if(OnJournaling &&  Modify) Print("EA Journaling: Order successfully modified, breakeven stop updated.");
            }
         }
      }
   }
}
