//+------------------------------------------------------------------+
//|                                            SBY_PendingMarket.mqh |
//|                                       Copyright 2016, SmartBYtes |
//|                   Pending Orders Library for SmartBYtes Template |
//+------------------------------------------------------------------+

// TODO: Add dependancies comment notes to indicate the links between functions
// TODO: Give a short description on each of the include files and how to use them

#property copyright "Copyright 2016, SmartBYtes"
#property strict
#property version "1.00"
#include <SBYtes/SBY_Main.mqh>

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                     FUNCTIONS LIBRARY                                   
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

Content:
1) OpenPositionPending

*/

//+------------------------------------------------------------------+
//| Open Pending Orders                                              |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing 

// This function submits new pending orders

int OpenPositionPending(double lots, int TYPE, double OpenPrice, datetime expiration, double SL, double TP){
   OpenPrice= NormalizeDouble(OpenPrice,Digits);
   int tries=0;
   string symbol=Symbol();
   int cmd=TYPE;
   double volume=lots;
   
   if(MarketInfo(symbol,MODE_MARGINREQUIRED)*volume>AccountFreeMargin()){
      Print("Can not open a trade. Not enough free margin to open "+(string)volume+" on "+symbol);
      return(-1);
   }
   
   int slippage=(int)(Slippage*P); // Slippage is in points. 1 point = 0.0001 on 4 digit broker and 0.00001 on a 5 digit broker
   int magic=MagicNumber;
   string comment=" "+(string)TYPE+"(#"+(string)magic+")";
   color arrow_color=0; 
      if(TYPE==OP_BUYLIMIT  || TYPE==OP_BUYSTOP ) arrow_color=Blue; 
      if(TYPE==OP_SELLLIMIT || TYPE==OP_SELLSTOP) arrow_color=Green;
   double stoploss=0;
   double takeprofit=0;
   double initTP = TP;
   double initSL = SL;
   int Ticket=-1;
   double price=0;

   while(tries<MaxRetriesPerTick){ // Edits stops and take profits before the market order is placed
      RefreshRates();

      // We are able to send in TP and SL when we open our orders even if we are using ECN brokers

      // Sets Take Profits and Stop Loss. Check against Stop Level Limitations.
      if((TYPE==OP_BUYLIMIT || TYPE==OP_BUYSTOP) && SL!=0){
         stoploss=NormalizeDouble(OpenPrice-SL*P*Point,Digits);
         if(OpenPrice-stoploss<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point){
            stoploss=NormalizeDouble(OpenPrice-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point,Digits);
            if(OnJournaling) Print("EA Journaling: Stop Loss changed from "+
                                   (string)initSL+" to "+(string)((OpenPrice-stoploss)/(P*Point))+" pips");
         }
      }
      if((TYPE==OP_BUYLIMIT || TYPE==OP_BUYSTOP) && TP!=0){
         takeprofit=NormalizeDouble(OpenPrice+TP*P*Point,Digits);
         if(takeprofit-OpenPrice<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point){
            takeprofit=NormalizeDouble(OpenPrice+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point,Digits);
            if(OnJournaling) Print("EA Journaling: Take Profit changed from "+
                                   (string)initTP+" to "+(string)((takeprofit-OpenPrice)/(P*Point))+" pips");
         }
      }
      if((TYPE==OP_SELLLIMIT || TYPE==OP_SELLSTOP) && SL!=0){
         stoploss=NormalizeDouble(OpenPrice+SL*P*Point,Digits);
         if(stoploss-OpenPrice<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point){
            stoploss=NormalizeDouble(OpenPrice+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point,Digits);
            if(OnJournaling) Print("EA Journaling: Stop Loss changed from " + 
                                   (string)initTP+" to "+(string)((stoploss-OpenPrice)/(P*Point))+" pips");
         }
      }
      if((TYPE==OP_SELLLIMIT || TYPE==OP_SELLSTOP) && TP!=0){
         takeprofit=NormalizeDouble(OpenPrice-TP*P*Point,Digits);
         if(OpenPrice-takeprofit<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point){
            takeprofit=NormalizeDouble(OpenPrice-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point,Digits);
            if(OnJournaling) Print("EA Journaling: Take Profit changed from " + 
                                   (string)initSL+" to "+(string)((OpenPrice-takeprofit)/(P*Point))+" pips");
         }
      }
      if(OnJournaling) Print("EA Journaling: Trying to place a pending order...");
      HandleTradingEnvironment();

      //Note: We did not modify Open Price if it breaches the Stop Level Limitations as Open Prices are sensitive and important. It is unsafe to change it automatically.
      Ticket=OrderSend(symbol,cmd,volume,OpenPrice,slippage,stoploss,takeprofit,comment,magic,expiration,arrow_color);
      if(Ticket>0) break;
      tries++;
   }

   if(OnJournaling && Ticket<0) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                      GetErrorDescription(GetLastError()));
   if(OnJournaling && Ticket>0) Print("EA Journaling: Order successfully placed. Ticket: "+(string)Ticket);

   return(Ticket);
}
