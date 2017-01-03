//+------------------------------------------------------------------+
//|                                                   SBY_VolGen.mqh |
//|                                       Copyright 2016, SmartBYtes |
//|           Hidden Breakeven Stops Library for SmartBYtes Template |
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

extern string  BEStopsHidHeader="----------Hidden Breakeven Stops Settings-----------";
extern bool    UseHiddenBreakevenStops=False;
extern double  BreakevenBuffer_Hidden=0; // In pips

//----------Errors Handling Settings-----------//

double HiddenBEList[]; // First dimension is for position ticket numbers

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                     FUNCTIONS LIBRARY                                   
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

Content:
   1) UpdateHiddenBEList
   2) SetAndTriggerBEHidden
*/

//+------------------------------------------------------------------+
//| Update Hidden Breakeven Stops List                               |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function clears the elements of your HiddenBEList if the corresponding positions has been closed

void UpdateHiddenBEList(){

   int ordersPos=OrdersTotal();
   int orderTicketNumber;
   bool doesPosExist;

   // Check the HiddenBEList, match with current list of positions. Make sure the all the positions exists. 
   // If it doesn't, it means there are positions that have been closed

   for(int x=0; x<ArrayRange(HiddenBEList,0); x++){ 
      
      // Looping through all order number in list
      doesPosExist=False;
      orderTicketNumber=(int)HiddenBEList[x];

      if(orderTicketNumber!=0){
         // Order exists
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
         if(doesPosExist==False){
            // Deletes elements if the order number does not match any current positions
            HiddenBEList[x]=0;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Set and Trigger Hidden Breakeven Stops                           |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

/* 
This function scans through the current positions and does 2 things:
1) If the position is in the hidden breakeven list, it closes it if the appropriate conditions are met
2) If the positon is not the hidden breakeven list, it adds it to the list if the appropriate conditions are met
*/

void SetAndTriggerBEHidden(){

   bool isOrderInBEList=False;
   int  orderTicketNumber;

   for(int i=OrdersTotal()-1; i>=0; i--){
      bool Modify=false;
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true && OrderSymbol()==Symbol() && 
         OrderMagicNumber()==MagicNumber){
         // Loop through list of current positions
         RefreshRates();
         orderTicketNumber=OrderTicket();
         for(int x=0; x<ArrayRange(HiddenBEList,0); x++){
            // Loops through hidden BE list
            if(orderTicketNumber==HiddenBEList[x]){
               // Checks if the current position is in the list 
               isOrderInBEList=True;
               break;
            }
         }
         if(isOrderInBEList==True){
            // If current position is in the list, close it if hidden breakeven stop is breached
            bool Closing=false;
            if(OrderType()==OP_BUY && OrderOpenPrice()>=Bid){
               // Checks BE condition for closing long orders    
               if(OnJournaling) Print("EA Journaling: Trying to close position "+(string)OrderTicket()+" using hidden breakeven stop...");
               HandleTradingEnvironment();
               Closing=OrderClose(OrderTicket(),OrderLots(),Bid,(int)(Slippage*P),Blue);
               if(OnJournaling && !Closing) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                                  GetErrorDescription(GetLastError()));
               if(OnJournaling &&  Closing) Print("EA Journaling: Position successfully closed due to hidden breakeven stop.");
            }
            if(OrderType()==OP_SELL && OrderOpenPrice()<=Ask){
               // Checks BE condition for closing short orders
               if(OnJournaling) Print("EA Journaling: Trying to close position "+(string)OrderTicket()+" using hidden breakeven stop...");
               HandleTradingEnvironment();
               Closing=OrderClose(OrderTicket(),OrderLots(),Ask,(int)(Slippage*P),Red);
               if(OnJournaling && !Closing) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                                  GetErrorDescription(GetLastError()));
               if(OnJournaling &&  Closing) Print("EA Journaling: Position successfully closed due to hidden breakeven stop.");
            }
         } else { 
            // If current position is not in the hidden BE list. We check if we need to add this position to the hidden BE list.
            if((OrderType()==OP_BUY  && (Bid-OrderOpenPrice())>(BreakevenBuffer_Hidden*P*Point)) || 
               (OrderType()==OP_SELL && (OrderOpenPrice()-Ask)>(BreakevenBuffer_Hidden*P*Point))){
               for(int y=0; y<ArrayRange(HiddenBEList,0); y++){
                  // Loop through of elements in column 1
                  if(HiddenBEList[y]==0){
                     // Checks if the element is empty
                     HiddenBEList[y]= orderTicketNumber;
                     if(OnJournaling) Print("EA Journaling: Order "+(string)HiddenBEList[y]+" assigned with a hidden breakeven stop.");
                     break;
                  }
               }
            }
         }
      }
   }
}
