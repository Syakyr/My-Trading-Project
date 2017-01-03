//+------------------------------------------------------------------+
//|                                             SBY_VolTrailStop.mqh |
//|                                       Copyright 2016, SmartBYtes |
//|         Volatility Trailing Stop Library for SmartBYtes Template |
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
extern string  VolTrailStopsHeader="----------Volatility Trailing Stops Settings-----------";
extern bool    UseVolTrailingStops=False;
extern double  VolTrailingDistMultiplier=0; // In units of ATR
extern double  VolTrailingBuffMultiplier=0; // In units of ATR

//----------Service Variables-----------//

double VolTrailingList[][2]; // First dimension is for position ticket numbers, second is for recording of volatility amount (one unit of ATR) at the time of trade

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                     FUNCTIONS LIBRARY                                   
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

Content:
   1) 

*/

//+------------------------------------------------------------------+
//| Initialise Volatility Trailing Stops                             |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function initialises the volatility traling stop function

void InitialiseVolTrailStop(){
   if(UseVolTrailingStops){ UpdateVolTrailingList(); ReviewVolTrailingStop(); }
}

//+------------------------------------------------------------------+
//| Update Volatility Trailing Stops List                            |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function clears the elements of your VolTrailingList if the corresponding positions has been closed

void UpdateVolTrailingList(){

   int ordersPos=OrdersTotal();
   int orderTicketNumber;
   bool doesPosExist;

   // Check the VolTrailingList, match with current list of positions. Make sure the all the positions exists. 
   // If it doesn't, it means there are positions that have been closed

   for(int x=0; x<ArrayRange(VolTrailingList,0); x++){ // Looping through all order number in list

      doesPosExist=False;
      orderTicketNumber=(int)VolTrailingList[x,0];

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
            VolTrailingList[x,0] = 0;
            VolTrailingList[x,1] = 0;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Set Volatility Trailing Stop                                     |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing 

// This function adds new volatility trailing stop level using OrderModify()

void SetVolTrailingStop(int OrderNum){
   if(UseVolTrailingStops){
      double VolTrailingStopDist;
      bool Modify=False;
      bool IsVolTrailingStopAdded=False;
      
      VolTrailingStopDist=VolTrailingDistMultiplier*myATR/(P*Point); // Volatility trailing stop amount in Pips
   
      if(OrderSelect(OrderNum,SELECT_BY_TICKET)==true && OrderSymbol()==Symbol() && 
         OrderMagicNumber()==MagicNumber){
         
         RefreshRates();
         if(OrderType()==OP_BUY){
            if(OnJournaling)Print("EA Journaling: Trying to modify order "+(string)OrderTicket()+" ...");
            HandleTradingEnvironment();
            Modify=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-VolTrailingStopDist*P*Point,OrderTakeProfit(),0,CLR_NONE);
            IsVolTrailingStopAdded=True;
            if(OnJournaling && !Modify) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                              GetErrorDescription(GetLastError()));
            if(OnJournaling &&  Modify) Print("EA Journaling: Order successfully modified, volatility trailing stop changed.");
         }
         if(OrderType()==OP_SELL){
            if(OnJournaling)Print("EA Journaling: Trying to modify order "+(string)OrderTicket()+" ...");
            HandleTradingEnvironment();
            Modify=OrderModify(OrderTicket(),OrderOpenPrice(),Ask+VolTrailingStopDist*P*Point,OrderTakeProfit(),0,CLR_NONE);
            IsVolTrailingStopAdded=True;
            if(OnJournaling && !Modify) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                              GetErrorDescription(GetLastError()));
            if(OnJournaling &&  Modify) Print("EA Journaling: Order successfully modified, volatility trailing stop changed.");
         } 
        
         // Records volatility measure (ATR value) for future use
         if(IsVolTrailingStopAdded==True){
            for(int x=0; x<ArrayRange(VolTrailingList,0); x++){ // Loop through elements in VolTrailingList
               if(VolTrailingList[x,0]==0){  // Checks if the element is empty
                  VolTrailingList[x,0]=OrderNum; // Add order number
                  VolTrailingList[x,1]=myATR/(P*Point); // Add volatility measure aka 1 unit of ATR
                  break;
               }
            }
         }
      }     
   }
}

//+------------------------------------------------------------------+
//| Review Volatility Trailing Stop                                  |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing 

// This function updates volatility trailing stops levels for all positions (using OrderModify) if appropriate conditions are met

void ReviewVolTrailingStop(){

   bool doesVolTrailingRecordExist;
   int posTicketNumber;

   for(int i=OrdersTotal()-1; i>=0; i--){ // Looping through all orders

      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true && OrderSymbol()==Symbol() && 
         OrderMagicNumber()==MagicNumber){
         doesVolTrailingRecordExist = False;
         posTicketNumber=OrderTicket();

         for(int x=0; x<ArrayRange(VolTrailingList,0); x++){ // Looping through all order number in list 

            if(posTicketNumber==VolTrailingList[x,0]){ // If condition holds, it means the position have a volatility trailing stop level attached to it

               doesVolTrailingRecordExist = True;
               bool Modify=false;
               RefreshRates();

               // We update the volatility trailing stop record using OrderModify.
               if(OrderType()==OP_BUY  && ((Bid-OrderStopLoss()>((VolTrailingDistMultiplier*VolTrailingList[x,1]+
                                                                 VolTrailingBuffMultiplier*VolTrailingList[x,1])*P*Point)) || 
                                                                 (OrderStopLoss()==0))){
                  if(OnJournaling)Print("EA Journaling: Trying to modify order "+(string)OrderTicket()+" ...");
                  HandleTradingEnvironment();
                  Modify=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-VolTrailingDistMultiplier*
                                     VolTrailingList[x,1]*P*Point,OrderTakeProfit(),0,CLR_NONE);
                  if(OnJournaling && !Modify) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                                    GetErrorDescription(GetLastError()));
                  if(OnJournaling &&  Modify) Print("EA Journaling: Order successfully modified, volatility trailing stop changed.");
               }
               if(OrderType()==OP_SELL && ((OrderStopLoss()-Ask>((VolTrailingDistMultiplier*VolTrailingList[x,1]+
                                                                  VolTrailingBuffMultiplier*VolTrailingList[x,1])*P*Point)) || 
                                                                  (OrderStopLoss()==0))){
                  if(OnJournaling)Print("EA Journaling: Trying to modify order "+(string)OrderTicket()+" ...");
                  HandleTradingEnvironment();
                  Modify=OrderModify(OrderTicket(),OrderOpenPrice(),Ask+VolTrailingDistMultiplier*
                                     VolTrailingList[x,1]*P*Point,OrderTakeProfit(),0,CLR_NONE);
                  if(OnJournaling && !Modify) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                                    GetErrorDescription(GetLastError()));
                  if(OnJournaling &&  Modify) Print("EA Journaling: Order successfully modified, volatility trailing stop changed.");
               }
               break;
            }
         }
         // If order does not have a record attached to it. Alert the trader.
         if(!doesVolTrailingRecordExist && OnJournaling) 
            Print("EA Journaling: Error. Order "+(string)posTicketNumber+
                  " has no volatility trailing stop attached to it.");
      }
   }
}
