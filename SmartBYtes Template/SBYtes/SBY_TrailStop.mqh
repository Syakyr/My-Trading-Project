//+------------------------------------------------------------------+
//|                                                SBY_TrailStop.mqh |
//|                                       Copyright 2016, SmartBYtes |
//|              Fixed Trailing Stop Library for SmartBYtes Template |
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
extern string  TrailStopsHeader="----------Trailing Stops Settings-----------";
extern bool    UseTrailingStops=False;
extern double  TrailingStopDistance=0; // In pips
extern double  TrailingStopBuffer=0; // In pips


//----------Service Variables-----------//


//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                     FUNCTIONS LIBRARY                                   
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

Content:
1) TrailingStopAll

*/

//+------------------------------------------------------------------+
//| Trailing Stop
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing 

// This function sets trailing stops for all positions

void TrailingStopAll(){

   if (UseTrailingStops){
      for(int i=OrdersTotal()-1; i>=0; i--){ // Looping through all orders
         bool Modify=false;
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true && OrderSymbol()==Symbol() && 
            OrderMagicNumber()==MagicNumber){
            RefreshRates();
            if(OrderType()==OP_BUY  && ((Bid-OrderStopLoss()>((TrailingStopDistance+TrailingStopBuffer)*P*Point)) ||
               (OrderStopLoss()==0))){
               if(OnJournaling)Print("EA Journaling: Trying to modify order "+(string)OrderTicket()+" ...");
               HandleTradingEnvironment();
               Modify=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TrailingStopDistance*P*Point,OrderTakeProfit(),0,CLR_NONE);
               if(OnJournaling && !Modify) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                                 GetErrorDescription(GetLastError()));
               if(OnJournaling &&  Modify) Print("EA Journaling: Order successfully modified, trailing stop changed.");
            }
            if(OrderType()==OP_SELL && ((OrderStopLoss()-Ask>((TrailingStopDistance+TrailingStopBuffer)*P*Point)) || 
               (OrderStopLoss()==0))){
               if(OnJournaling)Print("EA Journaling: Trying to modify order "+(string)OrderTicket()+" ...");
               HandleTradingEnvironment();
               Modify=OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TrailingStopDistance*P*Point,OrderTakeProfit(),0,CLR_NONE);
               if(OnJournaling && !Modify) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                                 GetErrorDescription(GetLastError()));
               if(OnJournaling &&  Modify) Print("EA Journaling: Order successfully modified, trailing stop changed.");
            }
         }
      }
   }
}