//+------------------------------------------------------------------+
//|                                       SBY_VolTrailStopHidden.mqh |
//|                                       Copyright 2016, SmartBYtes |
//|  Hidden Volatility Trailing Stop Library for SmartBYtes Template |
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
extern string  VolTrailStopsHidHeader="----------Hidden Volatility Trailing Stops Settings-----------";
extern bool    UseHiddenVolTrailing=False;
extern double  VolTrailingDistMultiplier_Hidden=0; // In units of ATR
extern double  VolTrailingBuffMultiplier_Hidden=0; // In units of ATR


//----------Service Variables-----------//

double HiddenVolTrailingList[][3]; // First dimension is for position ticket numbers, second is for the hidden trailing stop levels, third is for recording of volatility amount (one unit of ATR) at the time of trade

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                     FUNCTIONS LIBRARY                                   
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

Content:
   1) 

*/

//+------------------------------------------------------------------+
//| Update Hidden Volatility Trailing Stops List                     |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function clears the elements of your HiddenVolTrailingList if the corresponding positions has been closed

void UpdateHiddenVolTrailingList(){

   int ordersPos=OrdersTotal();
   int orderTicketNumber;
   bool doesPosExist;

   // Check the HiddenVolTrailingList, match with current list of positions. Make sure the all the positions exists. 
   // If it doesn't, it means there are positions that have been closed

   for(int x=0; x<ArrayRange(HiddenVolTrailingList,0); x++){ // Looping through all order number in list

      doesPosExist=False;
      orderTicketNumber=(int)HiddenVolTrailingList[x,0];

      if(orderTicketNumber!=0){ // Order exists
         for(int y=ordersPos-1; y>=0; y--){ // Looping through all current open positions
            if(OrderSelect(y,SELECT_BY_POS,MODE_TRADES)==true && OrderSymbol()==Symbol() && 
               OrderMagicNumber()==MagicNumber){
               if(orderTicketNumber==OrderTicket()){ // Checks order number in list against order number of current positions
                  doesPosExist=True;
                  break;
               }
            }
         }

         if(doesPosExist==False){ // Deletes elements if the order number does not match any current positions
            HiddenVolTrailingList[x,0] = 0;
            HiddenVolTrailingList[x,1] = 0;
            HiddenVolTrailingList[x,2] = 0;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Set Hidden Volatility Trailing Stop                              |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing 

// This function adds new hidden volatility trailing stop record 

void SetHiddenVolTrailing(int OrderNum){

   double VolTrailingStopLevel=0;
   double VolTrailingStopDist;

   VolTrailingStopDist=VolTrailingDistMultiplier_Hidden*myATR/(P*Point); // Volatility trailing stop amount in Pips

   if(OrderSelect(OrderNum,SELECT_BY_TICKET)==true && OrderSymbol()==Symbol() && 
      OrderMagicNumber()==MagicNumber){
      
      RefreshRates();
      if(OrderType()==OP_BUY)  
         VolTrailingStopLevel = MathMax(Bid, OrderOpenPrice()) 
                                - VolTrailingStopDist*P*Point; // Volatility trailing stop level of buy trades
      if(OrderType()==OP_SELL) 
         VolTrailingStopLevel = MathMin(Ask, OrderOpenPrice()) 
                                + VolTrailingStopDist*P*Point; // Volatility trailing stop level of sell trades
   }

   for(int x=0; x<ArrayRange(HiddenVolTrailingList,0); x++){ // Loop through elements in HiddenVolTrailingList
      if(HiddenVolTrailingList[x,0]==0){  // Checks if the element is empty
         HiddenVolTrailingList[x,0] = OrderNum; // Add order number
         HiddenVolTrailingList[x,1] = VolTrailingStopLevel; // Add volatility trailing stop level 
         HiddenVolTrailingList[x,2] = myATR/(P*Point); // Add volatility measure aka 1 unit of ATR
         if(OnJournaling) Print("EA Journaling: Order "+(string)HiddenVolTrailingList[x,0]+
                                " assigned with a hidden volatility trailing stop level of "+
                                (string)NormalizeDouble(HiddenVolTrailingList[x,1],Digits)+".");
         break;
      }
   }
}

//+------------------------------------------------------------------+
//| Trigger and Review Hidden Volatility Trailing Stop               |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing 

// This function does 2 things. 
//    1) It closes the positions if hidden volatility trailing stops levels are breached. 
//    2) It updates hidden volatility trailing stops for all positions if appropriate conditions are met

void TriggerAndReviewHiddenVolTrailing(){

   bool doesHiddenVolTrailingRecordExist;
   int posTicketNumber;

   for(int i=OrdersTotal()-1; i>=0; i--){ // Looping through all orders

      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true && OrderSymbol()==Symbol() && 
         OrderMagicNumber()==MagicNumber){
         
         doesHiddenVolTrailingRecordExist = False;
         posTicketNumber=OrderTicket();

         // 1) Check if we need to close the order.

         for(int x=0; x<ArrayRange(HiddenVolTrailingList,0); x++) { // Looping through all order number in list 

            if(posTicketNumber==HiddenVolTrailingList[x,0]) { // If condition holds, it means the position have a 
                                                              // hidden volatility trailing stop level attached to it
               doesHiddenVolTrailingRecordExist = True; 
               bool Closing=false;
               RefreshRates();

               if(OrderType()==OP_BUY && HiddenVolTrailingList[x,1]>=Bid) {

                  if(OnJournaling)Print("EA Journaling: Trying to close position "+(string)OrderTicket()+
                                        " using hidden volatility trailing stop...");
                  HandleTradingEnvironment();
                  Closing=OrderClose(OrderTicket(),OrderLots(),Bid,(int)(Slippage*P),Blue);
                  if(OnJournaling && !Closing) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                                  GetErrorDescription(GetLastError()));
                  if(OnJournaling &&  Closing) Print("EA Journaling: Position successfully closed due to hidden volatility trailing stop.");

               } else 
               if (OrderType()==OP_SELL && HiddenVolTrailingList[x,1]<=Ask){
                  if(OnJournaling)Print("EA Journaling: Trying to close position "+(string)OrderTicket()+
                                        " using hidden volatility trailing stop...");
                  HandleTradingEnvironment();
                  Closing=OrderClose(OrderTicket(),OrderLots(),Ask,(int)(Slippage*P),Red);
                  if(OnJournaling && !Closing) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                                     GetErrorDescription(GetLastError()));
                  if(OnJournaling &&  Closing) Print("EA Journaling: Position successfully closed due to hidden volatility trailing stop.");

               } else {

                  // 2) If orders was not closed in 1), we update the hidden volatility trailing stop record.
                  if(OrderType()==OP_BUY && (Bid-HiddenVolTrailingList[x,1]>
                                              (VolTrailingDistMultiplier_Hidden*HiddenVolTrailingList[x,2]+
                                               VolTrailingBuffMultiplier_Hidden*HiddenVolTrailingList[x,2])*P*Point)) {
                     // Assigns new hidden trailing stop level
                     HiddenVolTrailingList[x,1]=Bid-VolTrailingDistMultiplier_Hidden*HiddenVolTrailingList[x,2]*P*Point; 
                     if(OnJournaling) Print("EA Journaling: Order "+(string)posTicketNumber+" successfully modified, hidden volatility "+
                                            "trailing stop updated to "+(string)NormalizeDouble(HiddenVolTrailingList[x,1],Digits)+".");
                  }
                  if(OrderType()==OP_SELL && (HiddenVolTrailingList[x,1]-Ask>
                                               (VolTrailingDistMultiplier_Hidden*HiddenVolTrailingList[x,2]+
                                                VolTrailingBuffMultiplier_Hidden*HiddenVolTrailingList[x,2])*P*Point)){
                     // Assigns new hidden trailing stop level
                     HiddenVolTrailingList[x,1]=Ask+VolTrailingDistMultiplier_Hidden*HiddenVolTrailingList[x,2]*P*Point; 
                     if(OnJournaling)Print("EA Journaling: Order "+(string)posTicketNumber+" successfully modified, hidden volatility "+
                                         "trailing stop updated "+(string)NormalizeDouble(HiddenVolTrailingList[x,1],Digits)+".");
                  }
               }
               break;
            }
         }
         // If order does not have a record attached to it. Alert the trader.
         if(!doesHiddenVolTrailingRecordExist && OnJournaling) 
            Print("EA Journaling: Error. Order "+(string)posTicketNumber+
                  " has no hidden volatility trailing stop attached to it.");
      }
   }
}
