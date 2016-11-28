//+------------------------------------------------------------------+
//|                                                SmartBYtesStd.mqh |
//|                                       Copyright 2016, SmartBYtes |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, SmartBYtes"
#property strict
#property version "2.00"

//+---------------------------------------------------------------+
//| Magic Number using ChartID()                                  |
//+---------------------------------------------------------------+

int MagicNo = (int)ChartID();

//+---------------------------------------------------------------+
//| NormalizeDouble, with implied point settings                  |
//+---------------------------------------------------------------+

double  ND(double value){
   return(NormalizeDouble(value,Digits));
}

//+---------------------------------------------------------------+
//| Trail stop switch                                             |
//+---------------------------------------------------------------+
//ordertypeTSL = 1 if buy, 0 if sell

double TrailSL(bool TrailStopOn, 
               bool ordertypeTSL, 
               int  TrailStop){
               
   double resultTSL;
   if (TrailStopOn){
      if (ordertypeTSL){
         resultTSL=ND(Bid-(MarketInfo(Symbol(),MODE_STOPLEVEL)+TrailStop)*Point);
      } else {
         resultTSL=ND(Ask+(MarketInfo(Symbol(),MODE_STOPLEVEL)+TrailStop)*Point);
      }
   } else {
      resultTSL=OrderOpenPrice();
   }
   return resultTSL;
}

//+---------------------------------------------------------------+
//| Summation of Geometric Series                                 |
//+---------------------------------------------------------------+

double SumGeo (double commonratio, int term){

   double result;
   if (commonratio==1){
      result=term;
   } else {
      double top = 1-pow(commonratio,term);
      double bottom = 1-commonratio;
      result=top/bottom;
   }
   
   return result;
   
}

//+---------------------------------------------------------------+
//| Lot Size                                                      |
//+---------------------------------------------------------------+

//Adapted from 1005phillip's Lot Size Management code



enum ENUM_MM{
   MM_Fix,     //Fixed Lot Size
   MM_FM,      //Free Margin Size
   MM_PS,      //Position Size (SL)
   MM_ATR      //Not Applicable Yet
};

string MMstring(ENUM_MM mm) {
   string result;
   if (mm==0) result="Fixed Lot Size";
   else if (mm==1) result="Free Margin Size";
   else if (mm==2) result="Position Size";
   return (result);
}

double CalcLots  (ENUM_MM  mm, 
                  double   risk, 
                  int      ordertype=OP_BUY, 
                  int      TPnumber=1, 
                  double   SLPrice=0,
                  int      CommPip=0,
                  bool     capitalprotection=1, 
                  bool     skewedTP=0, 
                  int      TPdistnumber=1){

   double minlot     = MarketInfo(Symbol(), MODE_MINLOT),
          maxlot     = MarketInfo(Symbol(), MODE_MAXLOT),
          leverage   = AccountLeverage(),
          lotsize    = MarketInfo(Symbol(), MODE_LOTSIZE),
          lots       = 0,
          SLComPrice = 0,  //SL Price with Commission offset
          BasePrice  = 0;
   string CurrentSymbol=Symbol();
   string CurrentBasePairForCross=BasePairForCross();
   int    CurrentSymbolType=SymbolType();

          
   switch(ordertype){   //  
                     
      case OP_BUYLIMIT  :  // Same as OP_BUY
      case OP_BUYSTOP   :  // Same as OP_BUY
      case OP_BUY       :  SLComPrice=ND(SLPrice-CommPip*Point); break;
      case OP_SELLLIMIT :  // Same as OP_SELL
      case OP_SELLSTOP  :  // Same as OP_SELL
      case OP_SELL      :  SLComPrice=ND(SLPrice+CommPip*Point); break;
      default           :  Print("Error encountered in the OrderType() routine for",
                                 " calculating the final SL price"); 
                           // The expression did not generate a case value
   }
   
   if (mm==MM_ATR) lots =  0;   // For MM_ATR
   if (mm==MM_PS)  lots =  LotMM_PS(risk,SLComPrice,ordertype) / TPnumber;
   if (mm==MM_FM)  lots =  AccountFreeMargin() * risk / 100 / TPnumber / 1000.0;
   if (mm==MM_Fix) lots =                        risk / TPnumber;

   if (skewedTP){
      lots = lots * TPnumber * (TPnumber - TPdistnumber + 1) / (TPnumber * (TPnumber+1) / 2);
   }

   if (lots < minlot) {
      if (capitalprotection){
      lots = 0;
      Print("The lot size is too low for execution. Please increase your balance or risk level to avoid this message.");
      } else lots = minlot;
   }
   if (lots > maxlot) lots = maxlot;

   switch(CurrentSymbolType) // Determine the equity at risk based on the SymbolType for the financial instrument
      {
      case 1   :  switch(ordertype){   // Currency Pairs with USD as base - e.g. USDJPY
                     
                     case OP_BUYLIMIT  :  // Same as OP_SELL
                     case OP_BUYSTOP   :  // Same as OP_SELL
                     case OP_BUY       :  // Same as OP_SELL
                     case OP_SELLLIMIT :  // Same as OP_SELL
                     case OP_SELLSTOP  :  // Same as OP_SELL
                     case OP_SELL      :  BasePrice = 1; break;
                     default           :  Print("Error encountered in the OrderType() routine for",
                                                " calculating the FreeMarginAtRisk"); 
                                          // The expression did not generate a case value
                  }
                  break;
      case 2   :  switch(ordertype){   // Currency Pairs with USD as counter - e.g. EURUSD
                  
                     case OP_BUYLIMIT  :  // Same as OP_BUY
                     case OP_BUYSTOP   :  // Same as OP_BUY
                     case OP_BUY       :  BasePrice = Ask; break;
                     case OP_SELLLIMIT :  // Same as OP_SELL
                     case OP_SELLSTOP  :  // Same as OP_SELL
                     case OP_SELL      :  BasePrice = Bid; break;
                     default           :  Print("Error encountered in the OrderType() routine for",
                                                " calculating the FreeMarginAtRisk"); 
                                          // The expression did not generate a case value
                  }
                  break;
      case 3   :  switch(ordertype){  
                     // e.g. Symbol() = CHFJPY, the base currency is CHF and the USD is the base to the CHF in the pair USDCHF
                     
                     case OP_BUYLIMIT  :  // Same as OP_BUY
                     case OP_BUYSTOP   :  // Same as OP_BUY
                     case OP_BUY       :  BasePrice = 1/MarketInfo(CurrentBasePairForCross,MODE_ASK); break;
                     case OP_SELLLIMIT :  // Same as OP_SELL
                     case OP_SELLSTOP  :  // Same as OP_SELL
                     case OP_SELL      :  BasePrice = 1/MarketInfo(CurrentBasePairForCross,MODE_BID); break;
                     default           :  Print("Error encountered in the OrderType() routine for",
                                                " calculating the FreeMarginAtRisk"); 
                                          // The expression did not generate a case value
                  }
                  break;
                  
      case 4   :  // e.g. Symbol() = AUDCAD, the base currency is AUD and the USD is the counter to the AUD in the pair AUDUSD
                  // falls thru and is treated the same as SymbolType()==5 for the purpose of these calculations
      case 5   :  switch(ordertype){  
                     // e.g. Symbol() = EURGBP, the base currency is EUR and the USD is the counter to the EUR in the pair EURUSD
                     
                     case OP_BUYLIMIT  :  // Same as OP_BUY
                     case OP_BUYSTOP   :  // Same as OP_BUY
                     case OP_BUY       :  BasePrice = MarketInfo(CurrentBasePairForCross,MODE_BID); break;
                     case OP_SELLLIMIT :  // Same as OP_SELL
                     case OP_SELLSTOP  :  // Same as OP_SELL
                     case OP_SELL      :  BasePrice = MarketInfo(CurrentBasePairForCross,MODE_ASK); break;
                     default           :  Print("Error encountered in the OrderType() routine for",
                                                " calculating the FreeMarginAtRisk"); 
                                          // The expression did not generate a case value
                  }
                  break;
      default     :  Print("Error encountered in the SWITCH routine for calculating the FreeMarginAtRisk"); 
                     // The expression did not generate a case value
      }
      
   if (AccountFreeMargin() < BasePrice * lots * lotsize / leverage) {
      if (capitalprotection){
         Print("We have no money. Lots = ", lots, " , Free Margin = ", AccountFreeMargin());
         Comment("We have no money. Lots = ", lots, " , Free Margin = ", AccountFreeMargin());
         lots = 0;
      } else {
         Print("The lot size was too high; lot size adjusted to the maximum lot size possible.");
         lots = AccountFreeMargin()*leverage/BasePrice/lotsize - MarketInfo(Symbol(),MODE_LOTSTEP);
      }
   } else Comment("");

   lots=NormalizeLotSize(lots);

   return lots;
}

double LotMM_PS(double  RiskPercentage,
                double  StopLossPrice,
                int     CurrentOrderType,
                bool    ReturnNormalizedLots=false,
                bool    verbose=false){
                  
   // LotSize body start
   double   FreeMarginAtRisk=AccountFreeMargin()*RiskPercentage/100,
            CalculatedLotSize=0.,
            minlot     = MarketInfo(Symbol(), MODE_MINLOT),
            maxlot     = MarketInfo(Symbol(), MODE_MAXLOT),
            lotsize    = MarketInfo(Symbol(), MODE_LOTSIZE);
   string   CurrentSymbol=Symbol();
   string   CurrentCounterPairForCross=CounterPairForCross();
   int      CurrentSymbolType=SymbolType();
      
   switch(CurrentSymbolType) // Determine the equity at risk based on the SymbolType for the financial instrument
      {
      case 1   :  switch(CurrentOrderType){   // Currency Pairs with USD as base - e.g. USDJPY
                     
                     case OP_BUYLIMIT  :  // Same as OP_BUY
                     case OP_BUYSTOP   :  // Same as OP_BUY
                     case OP_BUY       :  CalculatedLotSize=(-FreeMarginAtRisk*StopLossPrice)/
                                          (lotsize*(StopLossPrice-Ask)); break;
                     case OP_SELLLIMIT :  // Same as OP_SELL
                     case OP_SELLSTOP  :  // Same as OP_SELL
                     case OP_SELL      :  CalculatedLotSize=(-FreeMarginAtRisk*StopLossPrice)/
                                          (lotsize*(Bid-StopLossPrice)); break;
                     default           :  Print("Error encountered in the OrderType() routine for",
                                                " calculating the FreeMarginAtRisk"); 
                                          // The expression did not generate a case value
                  }
                  break;
      case 2   :  switch(CurrentOrderType){   // Currency Pairs with USD as counter - e.g. EURUSD
                  
                     case OP_BUYLIMIT  :  // Same as OP_BUY
                     case OP_BUYSTOP   :  // Same as OP_BUY
                     case OP_BUY       :  CalculatedLotSize=-FreeMarginAtRisk/
                                          (lotsize*(StopLossPrice-Ask)); break;
                     case OP_SELLLIMIT :  // Same as OP_SELL
                     case OP_SELLSTOP  :  // Same as OP_SELL
                     case OP_SELL      :  CalculatedLotSize=-FreeMarginAtRisk/
                                          (lotsize*(Bid-StopLossPrice)); break;
                     default           :  Print("Error encountered in the OrderType() routine for",
                                                " calculating the FreeMarginAtRisk"); 
                                          // The expression did not generate a case value
                  }
                  break;
      case 3   :  // e.g. Symbol() = CHFJPY, the counter currency is JPY and the USD is the base to the JPY in the pair USDJPY
                  // falls thru and is treated the same as SymbolType()==4 for the purpose of these calculations
      case 4   :  switch(CurrentOrderType){  
                     // e.g. Symbol() = AUDCAD, the counter currency is CAD and the USD is the base to the CAD in the pair USDCAD
                     
                     case OP_BUYLIMIT  :  // Same as OP_BUY
                     case OP_BUYSTOP   :  // Same as OP_BUY
                     case OP_BUY       :  CalculatedLotSize=(-FreeMarginAtRisk*MarketInfo(CurrentCounterPairForCross,MODE_BID))/
                                          (lotsize*(StopLossPrice-Ask)); break;
                     case OP_SELLLIMIT :  // Same as OP_SELL
                     case OP_SELLSTOP  :  // Same as OP_SELL
                     case OP_SELL      :  CalculatedLotSize=(-FreeMarginAtRisk*MarketInfo(CurrentCounterPairForCross,MODE_ASK))/
                                          (lotsize*(Bid-StopLossPrice)); break;
                     default           :  Print("Error encountered in the OrderType() routine for",
                                                " calculating the FreeMarginAtRisk"); 
                                          // The expression did not generate a case value
                  }
                  break;
      case 5   :  switch(CurrentOrderType){  
                     // e.g. Symbol() = EURGBP, the counter currency is GBP and the USD is the counter to the GBP in the pair GBPUSD
                     
                     case OP_BUYLIMIT  :  // Same as OP_BUY
                     case OP_BUYSTOP   :  // Same as OP_BUY
                     case OP_BUY       :  CalculatedLotSize=-FreeMarginAtRisk/(lotsize*
                                          MarketInfo(CurrentCounterPairForCross,MODE_BID)*(StopLossPrice-Ask)); break;
                     case OP_SELLLIMIT :  // Same as OP_SELL
                     case OP_SELLSTOP  :  // Same as OP_SELL
                     case OP_SELL      :  CalculatedLotSize=-FreeMarginAtRisk/(lotsize*
                                          MarketInfo(CurrentCounterPairForCross,MODE_ASK)*(Bid-StopLossPrice)); break;
                     default           :  Print("Error encountered in the OrderType() routine for",
                                                " calculating the FreeMarginAtRisk"); 
                                          // The expression did not generate a case value
                  }
                  break;
      default     :  Print("Error encountered in the SWITCH routine for calculating the FreeMarginAtRisk"); 
                     // The expression did not generate a case value
      }
   
   if(CalculatedLotSize<0) CalculatedLotSize=0;
   
   if(ReturnNormalizedLots==true) CalculatedLotSize=NormalizeLotSize(CalculatedLotSize);
   
   if(verbose==true) Print("The calculated lot size is ",CalculatedLotSize);
   
   return(CalculatedLotSize);
   
}  // LotSize body end

double NormalizeLotSize(double CurrentLotSize,bool verbose=false){
   // NormalizeLotSize body start
   double   CalculatedNormalizeLotSize=0.,
            minlot     = MarketInfo(Symbol(), MODE_MINLOT),
            maxlot     = MarketInfo(Symbol(), MODE_MAXLOT),
            lotstep    = MarketInfo(Symbol(), MODE_LOTSTEP);
   int      LotSizeDigits=0;
   string   CurrentSymbol="";
   
   CurrentSymbol=Symbol();
      
   LotSizeDigits=- (int) MathRound(MathLog(MarketInfo(CurrentSymbol,MODE_LOTSTEP))/MathLog(10.)); 
                   // Number of digits after decimal point for the Lot for the current broker, like Digits for symbol prices
   
   CalculatedNormalizeLotSize=NormalizeDouble(MathFloor((CurrentLotSize-minlot)/lotstep)*lotstep+minlot,LotSizeDigits);
   
   if(verbose==true) Print("The broker-normalized lotsize is ",DoubleToStr(CalculatedNormalizeLotSize,LotSizeDigits));
   
   return(CalculatedNormalizeLotSize);
   
}  // NormalizeLotSize body end

//+---------------------------------------------------------------+
//| Symbol Identification                                         |
//+---------------------------------------------------------------+

int SymbolType(bool verbose=false){
   // SymbolType body start
   int      CalculatedSymbolType=6;
   string   CurrentSymbol=Symbol(),
            SymbolBase=StringSubstr(CurrentSymbol,0,3),
            SymbolCounter=StringSubstr(CurrentSymbol,3,3),
            postfix=StringSubstr(CurrentSymbol,6),
            CalculatedBasePairForCross="",
            CalculatedCounterPairForCross="";
   
   if(verbose==true) Print("Account currency is ", AccountCurrency()," and Current Symbol = ",CurrentSymbol);
   
   if(SymbolBase==AccountCurrency()) CalculatedSymbolType=1;
   if(SymbolCounter==AccountCurrency()) CalculatedSymbolType=2;
   
   if((CalculatedSymbolType==1 || CalculatedSymbolType==2) && verbose==true) 
      Print("Base currency is ",SymbolBase," and the Counter currency is ",SymbolCounter," (this pair is a major)");

   if(CalculatedSymbolType!=1 && CalculatedSymbolType!=2){
      if(verbose==true) 
         Print("Base currency is ",SymbolBase," and the Counter currency is ",SymbolCounter," (this pair is a cross)");

      // Determine if AccountCurrency() is the COUNTER currency or the BASE currency for the COUNTER currency forming Symbol()
      if(MarketInfo(StringConcatenate(AccountCurrency(),SymbolCounter,postfix),MODE_LOTSIZE)>0){
      
         CalculatedSymbolType=4; // SymbolType can also be 3 but this will be determined later when the Base pair is identified
         CalculatedCounterPairForCross=StringConcatenate(AccountCurrency(),SymbolCounter,postfix);
         if(verbose==true) 
            Print(AccountCurrency()," is the Base currency to the Counter currency for this cross, ",
                  "the CounterPair is ",CalculatedCounterPairForCross,
                  ", Bid = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_BID),
                                    (int)MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS)),
                  " and Ask = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_ASK),
                                       (int)MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS)));
      }
      else if(MarketInfo(StringConcatenate(SymbolCounter,AccountCurrency(),postfix),MODE_LOTSIZE)>0){
      
         CalculatedSymbolType=5;
         CalculatedCounterPairForCross=StringConcatenate(SymbolCounter,AccountCurrency(),postfix);
         if(verbose==true) 
            Print(AccountCurrency()," is the Counter currency to the Counter currency for this cross, ",
                  "the CounterPair is ",CalculatedCounterPairForCross,
                  ", Bid = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_BID),
                                    (int)MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS)),
                  " and Ask = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_ASK),
                                       (int)MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS)));
      }
      
      // Determine if AccountCurrency() is the COUNTER currency or the BASE currency for the BASE currency forming Symbol()
      if(MarketInfo(StringConcatenate(AccountCurrency(),SymbolBase,postfix),MODE_LOTSIZE)>0){
         CalculatedSymbolType=3;
         CalculatedBasePairForCross=StringConcatenate(AccountCurrency(),SymbolBase,postfix);
         if(verbose==true) 
            Print(AccountCurrency()," is the Base currency to the Base currency for this cross, ",
                  "the BasePair is ",CalculatedBasePairForCross,
                  ", Bid = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_BID),
                                    (int)MarketInfo(CalculatedBasePairForCross,MODE_DIGITS)),
                  " and Ask = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_ASK),
                                       (int)MarketInfo(CalculatedBasePairForCross,MODE_DIGITS)));
      }
      else if(MarketInfo(StringConcatenate(SymbolBase,AccountCurrency(),postfix),MODE_LOTSIZE)>0){
         CalculatedBasePairForCross=StringConcatenate(SymbolBase,AccountCurrency(),postfix);
         if(verbose==true) 
            Print(AccountCurrency()," is the Counter currency to the Base currency for this cross, ",
                  "the BasePair is ",CalculatedBasePairForCross,
                  ", Bid = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_BID),
                                    (int)MarketInfo(CalculatedBasePairForCross,MODE_DIGITS)),
                  " and Ask = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_ASK),
                                       (int)MarketInfo(CalculatedBasePairForCross,MODE_DIGITS)));
         }
      }
   if(verbose==true) Print("SymbolType() = ",CalculatedSymbolType);
   
   if(CalculatedSymbolType==6) 
      Print("Error occurred while identifying SymbolType(), calculated SymbolType() = ",CalculatedSymbolType);
   
   return(CalculatedSymbolType);

}  // SymbolType body end
   
string CounterPairForCross(bool verbose=false){  
   // CounterPairForCross body start
   string   CurrentSymbol=Symbol(),
            SymbolBase=StringSubstr(CurrentSymbol,0,3),
            SymbolCounter=StringSubstr(CurrentSymbol,3,3),
            postfix=StringSubstr(CurrentSymbol,6),
            CalculatedCounterPairForCross="",
            AcctCurType="";
      
   if(verbose==true) Print("Account currency is ", AccountCurrency()," and Current Symbol = ",CurrentSymbol);
   
   switch(SymbolType()){
      // Determine if AccountCurrency() is the COUNTER currency or the BASE currency for the COUNTER currency forming Symbol()
      
      case 1   :  break;
      case 2   :  break;
      case 3   :  // Same as case 4
      case 4   :  CalculatedCounterPairForCross=StringConcatenate(AccountCurrency(),SymbolCounter,postfix);
                  AcctCurType="Base"; break;
      case 5   :  CalculatedCounterPairForCross=StringConcatenate(SymbolCounter,AccountCurrency(),postfix);
                  AcctCurType="Counter"; break;
      case 6   :  Print("Error occurred while identifying SymbolType(), calculated SymbolType() = 6"); break;
      default  :  Print("Error encountered in the SWITCH routine for identifying CounterPairForCross on financial instrument ",
                        CurrentSymbol); // The expression did not generate a case value
   }
   
   if(verbose==true) 
      Print(AccountCurrency()," is the ",AcctCurType," currency to the Counter currency for this cross, ",
            "the CounterPair is ",CalculatedCounterPairForCross,
            ", Bid = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_BID),
                              (int)MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS)),
            " and Ask = ",DoubleToStr(MarketInfo(CalculatedCounterPairForCross,MODE_ASK),
                                 (int)MarketInfo(CalculatedCounterPairForCross,MODE_DIGITS)));
   
   return(CalculatedCounterPairForCross);
   
}  // CounterPairForCross body end

string BasePairForCross(bool verbose=false){
   // BasePairForCross body start
   string   CurrentSymbol=Symbol(),
            SymbolBase=StringSubstr(CurrentSymbol,0,3),
            SymbolCounter=StringSubstr(CurrentSymbol,3,3),
            postfix=StringSubstr(CurrentSymbol,6),
            CalculatedBasePairForCross="",
            AcctCurType="";
   
   if(verbose==true) Print("Account currency is ", AccountCurrency()," and Current Symbol = ",CurrentSymbol);
   
   switch(SymbolType()){
      // Determine if AccountCurrency() is the COUNTER currency or the BASE currency for the BASE currency forming Symbol()
      
      case 1   :  break;
      case 2   :  break;
      case 3   :  CalculatedBasePairForCross=StringConcatenate(AccountCurrency(),SymbolBase,postfix);
                  AcctCurType="Base"; break;
      case 4   :  // Same as case 5
      case 5   :  CalculatedBasePairForCross=StringConcatenate(SymbolBase,AccountCurrency(),postfix);
                  AcctCurType="Counter"; break;
      case 6   :  Print("Error occurred while identifying SymbolType(), calculated SymbolType() = 6"); break;
      default  :  Print("Error encountered in the SWITCH routine for identifying BasePairForCross on financial instrument ",
                        CurrentSymbol); // The expression did not generate a case value
   }
   
   if(verbose==true) 
      Print(AccountCurrency()," is the ",AcctCurType," currency to the Base currency for this cross, ",
            "the BasePair is ",CalculatedBasePairForCross,
            ", Bid = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_BID),
                              (int)MarketInfo(CalculatedBasePairForCross,MODE_DIGITS)),
            " and Ask = ",DoubleToStr(MarketInfo(CalculatedBasePairForCross,MODE_ASK),
                                 (int)MarketInfo(CalculatedBasePairForCross,MODE_DIGITS)));
   
   return(CalculatedBasePairForCross);
   
}  // BasePairForCross body end
