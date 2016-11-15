//+------------------------------------------------------------------+
//|                                                  MoneyManage.mqh |
//|                                       Copyright 2016, SmartBYtes |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, SmartBYtes"
#property version "1.00"
#property strict

//+---------------------------------------------------------------+
//| Money Management                                              |
//+---------------------------------------------------------------+

// Notes:
// - Current version position size management (MM=2) does not take
//   into account cross pairs (pairs that are not denoted with the
//   base currency used).

double Lots(int MM, double Risk, int TPnumber, int stoplosspip, bool capitalprotection){

   double minlot     = MarketInfo(Symbol(), MODE_MINLOT),
          maxlot     = MarketInfo(Symbol(), MODE_MAXLOT),
          leverage   = AccountLeverage(),
          lotsize    = MarketInfo(Symbol(), MODE_LOTSIZE),
          lots;
   int    LotDigits  = ceil(-log10(MarketInfo(Symbol(),MODE_LOTSTEP)));

   if      (MM==1) lots = NormalizeDouble (AccountFreeMargin() * Risk/(100*TPnumber) / 1000.0, LotDigits);
   else if (MM==2) lots = NormalizeDouble((AccountFreeMargin() * Risk/(100*TPnumber))/stoplosspip,LotDigits);
   else            lots = NormalizeDouble(Risk/TPnumber,LotDigits);

   if (lots < minlot) {
      if (capitalprotection){
      lots = 0;
      Print("The lot size is too low for execution. Please increase your balance or risk level to avoid this message");
      } else if (capitalprotection==false) lots = minlot;
   }
   if (lots > maxlot) lots = maxlot;
   if (AccountFreeMargin() < Ask * lots * lotsize / leverage) {
      Print("We have no money. Lots = ", lots, " , Free Margin = ", AccountFreeMargin());
      Comment("We have no money. Lots = ", lots, " , Free Margin = ", AccountFreeMargin());
   }

   return(lots);
}
