//+------------------------------------------------------------------+
//|                                          SBY_TrailStopHidden.mqh |
//|                                       Copyright 2016, SmartBYtes |
//|             Hidden Trailing Stop Library for SmartBYtes Template |
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

extern string  TrailStopsHidHeader="----------Hidden Trailing Stops Settings-----------";
extern bool    UseHiddenTrailingStops=False;
extern double  TrailingStopDistance_Hidden=0; // In pips
extern double  TrailingStopBuffer_Hidden=0; // In pips

//----------Service Variables-----------//

double HiddenTrailingList[][2]; // First dimension is for position ticket numbers, second is for the hidden trailing stop levels

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                     FUNCTIONS LIBRARY                                   
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

Content:
   1) UpdateHiddenTrailingList
   2) SetAndTriggerHiddenTrailing

*/

//+------------------------------------------------------------------+
//| Update Hidden Trailing Stops List                                |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function clears the elements of your HiddenTrailingList if the corresponding positions has been closed

void UpdateHiddenTrailingList(){

   int ordersPos=OrdersTotal();
   int orderTicketNumber;
   bool doesPosExist;

   // Check the HiddenTrailingList, match with current list of positions. Make sure the all the positions exists. 
   // If it doesn't, it means there are positions that have been closed

   for(int x=0; x<ArrayRange(HiddenTrailingList,0); x++){ // Looping through all order number in list

      doesPosExist=False;
      orderTicketNumber=(int)HiddenTrailingList[x,0];

      if(orderTicketNumber!=0){ // Order exists

         for(int y=ordersPos-1; y>=0; y--){
            // Looping through all current open positions
            if(OrderSelect(y,SELECT_BY_POS,MODE_TRADES)==true && OrderSymbol()==Symbol() && 
               OrderMagicNumber()==MagicNumber){
               if(orderTicketNumber==OrderTicket()){
                  // Checks order number in list against order number of current positions
                  doesPosExist=True;
                  break;
               }
            }
         }

         if(doesPosExist==False){ // Deletes elements if the order number does not match any current positions

            HiddenTrailingList[x,0] = 0;
            HiddenTrailingList[x,1] = 0;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Set and Trigger Hidden Trailing Stop
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing 

// This function does 2 things. 
//    1) It sets hidden trailing stops for all positions 
//    2) It closes the positions if hidden trailing stops levels are breached

void SetAndTriggerHiddenTrailing(){

   bool doesHiddenTrailingRecordExist;
   int posTicketNumber;

   for(int i=OrdersTotal()-1; i>=0; i--){ // Looping through all orders

      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true && OrderSymbol()==Symbol() && 
         OrderMagicNumber()==MagicNumber){

         doesHiddenTrailingRecordExist=False;
         posTicketNumber=OrderTicket();

         // Step 1: Check if there is any hidden trailing stop records pertaining to this order. 
         // If yes, check if we need to close the order.
         for(int x=0; x<ArrayRange(HiddenTrailingList,0); x++){ // Looping through all order number in list 
            
            if(posTicketNumber==HiddenTrailingList[x,0]){

               // If condition holds, it means the position have a hidden trailing stop level attached to it
               doesHiddenTrailingRecordExist=True;
               bool Closing=false;
               RefreshRates();

               if(OrderType()==OP_BUY && HiddenTrailingList[x,1]>=Bid){
                  if(OnJournaling) Print("EA Journaling: Trying to close position "+(string)OrderTicket()+" using hidden trailing stop...");
                  HandleTradingEnvironment();
                  Closing=OrderClose(OrderTicket(),OrderLots(),Bid,(int)(Slippage*P),Blue);
                  if(OnJournaling && !Closing) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                                     GetErrorDescription(GetLastError()));
                  if(OnJournaling &&  Closing) Print("EA Journaling: Position successfully closed due to hidden trailing stop.");

               } else 
               if(OrderType()==OP_SELL && HiddenTrailingList[x,1]<=Ask){

                  if(OnJournaling) Print("EA Journaling: Trying to close position "+(string)OrderTicket()+" using hidden trailing stop...");
                  HandleTradingEnvironment();
                  Closing=OrderClose(OrderTicket(),OrderLots(),Ask,(int)(Slippage*P),Red);
                  if(OnJournaling && !Closing) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                                     GetErrorDescription(GetLastError()));
                  if(OnJournaling &&  Closing) Print("EA Journaling: Position successfully closed due to hidden trailing stop.");

               } else {

                  // Step 2: If there are hidden trailing stop records and the position was not closed in Step 1. 
                  // We update the hidden trailing stop record.
                  if(OrderType()==OP_BUY && (Bid-HiddenTrailingList[x,1]>
                                               (TrailingStopDistance_Hidden+TrailingStopBuffer_Hidden)*P*Point)){
                     HiddenTrailingList[x,1]=Bid-TrailingStopDistance_Hidden*P*Point; // Assigns new hidden trailing stop level
                     if(OnJournaling)Print("EA Journaling: Order "+(string)posTicketNumber+" successfully modified, "+
                                           "hidden trailing stop updated to "+(string)NormalizeDouble(HiddenTrailingList[x,1],Digits)+".");
                  }
                  if(OrderType()==OP_SELL && (HiddenTrailingList[x,1]-Ask>
                                                (TrailingStopDistance_Hidden+TrailingStopBuffer_Hidden)*P*Point)){
                     HiddenTrailingList[x,1]=Ask+TrailingStopDistance_Hidden*P*Point; // Assigns new hidden trailing stop level
                     if(OnJournaling)Print("EA Journaling: Order "+(string)posTicketNumber+" successfully modified, "+
                                           "hidden trailing stop updated to "+(string)NormalizeDouble(HiddenTrailingList[x,1],Digits)+".");
                  }
               }
               break;
            }
         }

         // Step 3: If there are no hidden trailing stop records, add new record.
         if(doesHiddenTrailingRecordExist==False){

            for(int y=0; y<ArrayRange(HiddenTrailingList,0); y++){ // Looping through list

               if(HiddenTrailingList[y,0]==0){ // Slot is empty
                  
                  RefreshRates();
                  HiddenTrailingList[y,0]=posTicketNumber; // Assigns Order Number
                  if(OrderType()==OP_BUY){
                     // Hidden trailing stop level = Higher of Bid or OrderOpenPrice - Trailing Stop Distance
                     HiddenTrailingList[y,1]=MathMax(Bid,OrderOpenPrice())-TrailingStopDistance_Hidden*P*Point; 
                     if(OnJournaling) Print("EA Journaling: Order "+(string)posTicketNumber+" successfully modified, "+
                                            "hidden trailing stop added. Trailing Stop = "+
                                            (string)NormalizeDouble(HiddenTrailingList[y,1],Digits)+".");
                  }
                  if(OrderType()==OP_SELL){
                     // Hidden trailing stop level = Lower of Ask or OrderOpenPrice + Trailing Stop Distance
                     HiddenTrailingList[y,1]=MathMin(Ask,OrderOpenPrice())+TrailingStopDistance_Hidden*P*Point; 
                     if(OnJournaling) Print("EA Journaling: Order "+(string)posTicketNumber+" successfully modified, "+
                                            "hidden trailing stop added. Trailing Stop = "+
                                            (string)NormalizeDouble(HiddenTrailingList[y,1],Digits)+".");
                  }
                  break;
               }
            }
         }
      }
   }
}