//+------------------------------------------------------------------+
//|                                               SBY_OpenMarket.mqh |
//|                                       Copyright 2016, SmartBYtes |
//|               Open Market Orders Library for SmartBYtes Template |
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
   1) SendOpenOrder
   2) SetTPSL
   3) OpenPositionMarket

*/

//+------------------------------------------------------------------+
//| Send Open Orders                                                 |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing 

// This function adds journaling and trading environment handling on top of sending the order directly. 

int SendOpenOrder (string symbol,
                   int    cmd,
                   double volume,
                   double price,
                   int    slippage,
                   double SL, 
                   double TP,
                   string comment,
                   int    magic,
                   datetime expiration,
                   color arrow_color){
   int Ticket = 0;
   if(OnJournaling)Print("EA Journaling: Trying to place a market order...");
   HandleTradingEnvironment();
   Ticket=OrderSend(symbol,cmd,volume,price,slippage,SL,TP,comment,magic,expiration,arrow_color);
   return (Ticket);
}

//+------------------------------------------------------------------+
//| Set Fixed TP and SL                                              |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing 

// This function sets TP and SL. 

void SetTPSL(int TYPE, double initSL, double initTP, double SL, double TP){

   // Sets Take Profits and Stop Loss. Check against Stop Level Limitations.
   if(TYPE==OP_BUY && initSL!=0){
      SL=NormalizeDouble(Ask-initSL*P*Point,Digits);
      if(Bid-SL<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point){
         SL=NormalizeDouble(Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point,Digits);
         if(OnJournaling)Print("EA Journaling: Stop Loss changed from "+(string)initSL+" to "+
                               (string)(MarketInfo(Symbol(),MODE_STOPLEVEL)/P)+" pips");
      }
   }
   if(TYPE==OP_SELL && initSL!=0){
      SL=NormalizeDouble(Bid+initSL*P*Point,Digits);
      if(SL-Ask<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point){
         SL=NormalizeDouble(Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point,Digits);
         if(OnJournaling)Print("EA Journaling: Stop Loss changed from "+(string)initSL+" to "+
                               (string)(MarketInfo(Symbol(),MODE_STOPLEVEL)/P)+" pips");
      }
   }
   if(TYPE==OP_BUY && initTP!=0){
      TP=NormalizeDouble(Ask+initTP*P*Point,Digits);
      if(TP-Bid<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point){
         TP=NormalizeDouble(Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point,Digits);
         if(OnJournaling)Print("EA Journaling: Take Profit changed from "+(string)initTP+" to "+
                               (string)(MarketInfo(Symbol(),MODE_STOPLEVEL)/P)+" pips");
      }
   }
   if(TYPE==OP_SELL && initTP!=0){
      TP=NormalizeDouble(Bid-initTP*P*Point,Digits);
      if(Ask-TP<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point){
         TP=NormalizeDouble(Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point,Digits);
         if(OnJournaling)Print("EA Journaling: Take Profit changed from "+(string)initTP+" to "+
                               (string)(MarketInfo(Symbol(),MODE_STOPLEVEL)/P)+" pips");
      }
   }
}

//+------------------------------------------------------------------+
//| Open From Market                                                 |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing 

// This function submits new orders

int OpenPositionMarket(double lots, int TYPE, double SL, double TP){
   int tries=0;
   string symbol=Symbol();
   int cmd=TYPE;
   double volume=lots;

   if(MarketInfo(symbol,MODE_MARGINREQUIRED)*volume>AccountFreeMargin()){
      Print("Can not open a trade. Not enough free margin to open "+(string)volume+" on "+symbol);
      return(-1);
   }
   
   int slippage=(int)(Slippage*P); // Slippage is in points. 1 point = 0.0001 on 4 digit broker and 0.00001 on a 5 digit broker
   string comment=" "+(string)TYPE+"(#"+(string)MagicNumber+")";
   int magic=MagicNumber;
   datetime expiration=0;
   color arrow_color=0; if(TYPE==OP_BUY)arrow_color=Blue; if(TYPE==OP_SELL)arrow_color=Green;
   double stoploss=0;
   double takeprofit=0;
   double initTP = TP;
   double initSL = SL;
   int Ticket=-1;
   double price=0;
   if(!IsECNbroker){
      while(tries<MaxRetriesPerTick){ // Edits stops and take profits before the market order is placed
         RefreshRates();
         if(TYPE==OP_BUY) price=Ask; if(TYPE==OP_SELL) price=Bid;
         SetTPSL(TYPE,initSL,initTP,SL,TP);
         Ticket = SendOpenOrder(symbol,cmd,volume,price,slippage,stoploss,takeprofit,comment,magic,expiration,arrow_color);
         if(Ticket>0) break;
         tries++;
      }
   }
   if(IsECNbroker){ // Edits stops and take profits after the market order is placed
      if(TYPE==OP_BUY)price=Ask;if(TYPE==OP_SELL)price=Bid;
      Ticket = SendOpenOrder(symbol,cmd,volume,price,slippage,0,0,comment,magic,expiration,arrow_color);
      if(Ticket>0 && OrderSelect(Ticket,SELECT_BY_TICKET)==true && (SL!=0 || TP!=0)){
         SetTPSL(TYPE,initSL,initTP,SL,TP);
         bool ModifyOpen=false;
         while(!ModifyOpen){
            HandleTradingEnvironment();
            ModifyOpen=OrderModify(Ticket,OrderOpenPrice(),stoploss,takeprofit,expiration,arrow_color);
            if(OnJournaling && !ModifyOpen) Print("EA Journaling: Take Profit and Stop Loss not set. "+
                                                  "Error Description: "+GetErrorDescription(GetLastError()));
         }
      }
   }

   if(OnJournaling && Ticket<0) Print("EA Journaling: Unexpected Error has happened. "+
                                      "Error Description: "+GetErrorDescription(GetLastError()));
   if(OnJournaling && Ticket>0) Print("EA Journaling: Order successfully placed. Ticket: "+(string)Ticket);
   
   return(Ticket);
}
  