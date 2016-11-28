//+------------------------------------------------------------------+
//|                                          MadPoundProfitsV1.5.mq4 |
//|                                       Copyright 2016, SmartBYtes |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, SmartBYtes"
#property version   "1.5"
#property strict
#include <SmartBYtesStdV2.mqh>

bool     SwitchA[24],
         SwitchB[24],
         SwitchC[24],
         SwitchD[24],
         SwitchE[24];
int      res=0,
         newLAP[24],
         Rcount[24],
         SLPip[48],
         TimeNo[24],
         TPpip[48],
         BrkOutPip[24],
         BrkOutPipR[24],
         LAP[24],
         AnalysisMin[24],
         HourEnd[24];
         
double   EPPriceB[24],
         EPPriceS[24],
         initlots[24],
         ChanFactor[24],
         Rev[24];

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+

extern string  MoneyManagement   = "Money and Risk Management Settings"; //----------------------------
extern ENUM_MM MM                = MM_PS;    //MM
extern double  Risk              = 2;        //Risk Level
extern int     Commission        = 10;       //Commission (in points)
extern bool    CaplProt          = true;     //Capital Protection Switch
extern double  Rfact             = 100;      //Revenge Factor
extern int     SpreadThreshold   = 300;      //Spread Threshold
extern bool    GetMail           = true;     //Get Mail Alert

extern string  MainHeader        = "General Price and Time Settings"; //----------------------------
extern int     TPPip             = 50;       //TP points
extern int     RPip              = 50;       //Revenge Pips

extern string  Header0100        = "0100 Price and Time Settings"; //----------------------------
extern int     LAP0100           = 12000;      //Break Structure %
extern int     BrkOutPip0100     = 50;       //Break Out Pip
extern int     BrkOutPipR0100    = 50;       //Break Out Revenge Pip
extern double  ChanFactor0100    = 61.8;     //SL Channel Factor
extern int     AnalysisMin0100   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd0100       = 23;       //End of Open Trades

extern string  Header0200        = "0200 Price and Time Settings"; //----------------------------
extern int     LAP0200           = 12000;      //Break Structure %
extern int     BrkOutPip0200     = 50;       //Break Out Pip
extern int     BrkOutPipR0200    = 50;       //Break Out Revenge Pip
extern double  ChanFactor0200    = 61.8;     //SL Channel Factor
extern int     AnalysisMin0200   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd0200       = 23;       //End of Open Trades

extern string  Header0300        = "0300 Price and Time Settings"; //----------------------------
extern int     LAP0300           = 12000;      //Break Structure %
extern int     BrkOutPip0300     = 50;       //Break Out Pip
extern int     BrkOutPipR0300    = 50;       //Break Out Revenge Pip
extern double  ChanFactor0300    = 61.8;     //SL Channel Factor
extern int     AnalysisMin0300   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd0300       = 23;       //End of Open Trades

extern string  Header0400        = "0400 Price and Time Settings"; //----------------------------
extern int     LAP0400           = 12000;      //Break Structure %
extern int     BrkOutPip0400     = 50;       //Break Out Pip
extern int     BrkOutPipR0400    = 50;       //Break Out Revenge Pip
extern double  ChanFactor0400    = 61.8;     //SL Channel Factor
extern int     AnalysisMin0400   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd0400       = 23;       //End of Open Trades

extern string  Header0500        = "0500 Price and Time Settings"; //----------------------------
extern int     LAP0500           = 12000;      //Break Structure %
extern int     BrkOutPip0500     = 50;       //Break Out Pip
extern int     BrkOutPipR0500    = 50;       //Break Out Revenge Pip
extern double  ChanFactor0500    = 61.8;     //SL Channel Factor
extern int     AnalysisMin0500   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd0500       = 23;       //End of Open Trades

extern string  Header0600        = "0600 Price and Time Settings"; //----------------------------
extern int     LAP0600           = 12000;      //Break Structure %
extern int     BrkOutPip0600     = 50;       //Break Out Pip
extern int     BrkOutPipR0600    = 50;       //Break Out Revenge Pip
extern double  ChanFactor0600    = 61.8;     //SL Channel Factor
extern int     AnalysisMin0600   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd0600       = 23;       //End of Open Trades

extern string  Header0700        = "0700 Price and Time Settings"; //----------------------------
extern int     LAP0700           = 12000;      //Break Structure %
extern int     BrkOutPip0700     = 50;       //Break Out Pip
extern int     BrkOutPipR0700    = 50;       //Break Out Revenge Pip
extern double  ChanFactor0700    = 61.8;     //SL Channel Factor
extern int     AnalysisMin0700   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd0700       = 23;       //End of Open Trades

extern string  Header0800        = "0800 Price and Time Settings"; //----------------------------
extern int     LAP0800           = 12000;      //Break Structure %
extern int     BrkOutPip0800     = 50;       //Break Out Pip
extern int     BrkOutPipR0800    = 50;       //Break Out Revenge Pip
extern double  ChanFactor0800    = 61.8;     //SL Channel Factor
extern int     AnalysisMin0800   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd0800       = 23;       //End of Open Trades

extern string  Header0900        = "0900 Price and Time Settings"; //----------------------------
extern int     LAP0900           = 12000;      //Break Structure %
extern int     BrkOutPip0900     = 50;       //Break Out Pip
extern int     BrkOutPipR0900    = 50;       //Break Out Revenge Pip
extern double  ChanFactor0900    = 61.8;     //SL Channel Factor
extern int     AnalysisMin0900   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd0900       = 23;       //End of Open Trades

extern string  Header1000        = "1000 Price and Time Settings"; //----------------------------
extern int     LAP1000           = 12000;      //Break Structure %
extern int     BrkOutPip1000     = 50;       //Break Out Pip
extern int     BrkOutPipR1000    = 50;       //Break Out Revenge Pip
extern double  ChanFactor1000    = 61.8;     //SL Channel Factor
extern int     AnalysisMin1000   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd1000       = 23;       //End of Open Trades

extern string  Header1100        = "1100 Price and Time Settings"; //----------------------------
extern int     LAP1100           = 12000;      //Break Structure %
extern int     BrkOutPip1100     = 50;       //Break Out Pip
extern int     BrkOutPipR1100    = 50;       //Break Out Revenge Pip
extern double  ChanFactor1100    = 61.8;     //SL Channel Factor
extern int     AnalysisMin1100   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd1100       = 23;       //End of Open Trades

extern string  Header1200        = "1200 Price and Time Settings"; //----------------------------
extern int     LAP1200           = 12000;      //Break Structure %
extern int     BrkOutPip1200     = 50;       //Break Out Pip
extern int     BrkOutPipR1200    = 50;       //Break Out Revenge Pip
extern double  ChanFactor1200    = 61.8;     //SL Channel Factor
extern int     AnalysisMin1200   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd1200       = 23;       //End of Open Trades

extern string  Header1300        = "1300 Price and Time Settings"; //----------------------------
extern int     LAP1300           = 12000;      //Break Structure %
extern int     BrkOutPip1300     = 50;       //Break Out Pip
extern int     BrkOutPipR1300    = 50;       //Break Out Revenge Pip
extern double  ChanFactor1300    = 61.8;     //SL Channel Factor
extern int     AnalysisMin1300   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd1300       = 23;       //End of Open Trades

extern string  Header1400        = "1400 Price and Time Settings"; //----------------------------
extern int     LAP1400           = 12000;      //Break Structure %
extern int     BrkOutPip1400     = 50;       //Break Out Pip
extern int     BrkOutPipR1400    = 50;       //Break Out Revenge Pip
extern double  ChanFactor1400    = 61.8;     //SL Channel Factor
extern int     AnalysisMin1400   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd1400       = 23;       //End of Open Trades

extern string  Header1500        = "1500 Price and Time Settings"; //----------------------------
extern int     LAP1500           = 12000;      //Break Structure %
extern int     BrkOutPip1500     = 50;       //Break Out Pip
extern int     BrkOutPipR1500    = 50;       //Break Out Revenge Pip
extern double  ChanFactor1500    = 61.8;     //SL Channel Factor
extern int     AnalysisMin1500   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd1500       = 23;       //End of Open Trades

extern string  Header1600        = "1600 Price and Time Settings"; //----------------------------
extern int     LAP1600           = 12000;      //Break Structure %
extern int     BrkOutPip1600     = 50;       //Break Out Pip
extern int     BrkOutPipR1600    = 50;       //Break Out Revenge Pip
extern double  ChanFactor1600    = 61.8;     //SL Channel Factor
extern int     AnalysisMin1600   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd1600       = 23;       //End of Open Trades

extern string  Header1700        = "1700 Price and Time Settings"; //----------------------------
extern int     LAP1700           = 12000;      //Break Structure %
extern int     BrkOutPip1700     = 50;       //Break Out Pip
extern int     BrkOutPipR1700    = 50;       //Break Out Revenge Pip
extern double  ChanFactor1700    = 61.8;     //SL Channel Factor
extern int     AnalysisMin1700   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd1700       = 23;       //End of Open Trades

extern string  Header1800        = "1800 Price and Time Settings"; //----------------------------
extern int     LAP1800           = 12000;      //Break Structure %
extern int     BrkOutPip1800     = 50;       //Break Out Pip
extern int     BrkOutPipR1800    = 50;       //Break Out Revenge Pip
extern double  ChanFactor1800    = 61.8;     //SL Channel Factor
extern int     AnalysisMin1800   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd1800       = 23;       //End of Open Trades

extern string  Header1900        = "1900 Price and Time Settings"; //----------------------------
extern int     LAP1900           = 12000;      //Break Structure %
extern int     BrkOutPip1900     = 50;       //Break Out Pip
extern int     BrkOutPipR1900    = 50;       //Break Out Revenge Pip
extern double  ChanFactor1900    = 61.8;     //SL Channel Factor
extern int     AnalysisMin1900   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd1900       = 23;       //End of Open Trades

extern string  Header2000        = "2000 Price and Time Settings"; //----------------------------
extern int     LAP2000           = 12000;      //Break Structure %
extern int     BrkOutPip2000     = 50;       //Break Out Pip
extern int     BrkOutPipR2000    = 50;       //Break Out Revenge Pip
extern double  ChanFactor2000    = 61.8;     //SL Channel Factor
extern int     AnalysisMin2000   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd2000       = 23;       //End of Open Trades

extern string  Header2100        = "2100 Price and Time Settings"; //----------------------------
extern int     LAP2100           = 12000;      //Break Structure %
extern int     BrkOutPip2100     = 50;       //Break Out Pip
extern int     BrkOutPipR2100    = 50;       //Break Out Revenge Pip
extern double  ChanFactor2100    = 61.8;     //SL Channel Factor
extern int     AnalysisMin2100   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd2100       = 23;       //End of Open Trades

extern string  Header2200        = "2200 Price and Time Settings"; //----------------------------
extern int     LAP2200           = 12000;      //Break Structure %
extern int     BrkOutPip2200     = 50;       //Break Out Pip
extern int     BrkOutPipR2200    = 50;       //Break Out Revenge Pip
extern double  ChanFactor2200    = 61.8;     //SL Channel Factor
extern int     AnalysisMin2200   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd2200       = 23;       //End of Open Trades

extern string  Header2300        = "2300 Price and Time Settings"; //----------------------------
extern int     LAP2300           = 12000;      //Break Structure %
extern int     BrkOutPip2300     = 50;       //Break Out Pip
extern int     BrkOutPipR2300    = 50;       //Break Out Revenge Pip
extern double  ChanFactor2300    = 61.8;     //SL Channel Factor
extern int     AnalysisMin2300   = 480;      //Analysis Duration (Minutes)
extern int     HourEnd2300       = 23;       //End of Open Trades

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {      
//---
   
   //Break Out Pip Initialisation
   BrkOutPip[1]   = BrkOutPip0100;
   BrkOutPip[2]   = BrkOutPip0200;
   BrkOutPip[3]   = BrkOutPip0300;
   BrkOutPip[4]   = BrkOutPip0400;
   BrkOutPip[5]   = BrkOutPip0500;
   BrkOutPip[6]   = BrkOutPip0600;
   BrkOutPip[7]   = BrkOutPip0700;
   BrkOutPip[8]   = BrkOutPip0800;   
   BrkOutPip[9]   = BrkOutPip0900;
   BrkOutPip[10]  = BrkOutPip1000;
   BrkOutPip[11]  = BrkOutPip1100;
   BrkOutPip[12]  = BrkOutPip1200;
   BrkOutPip[13]  = BrkOutPip1300;
   BrkOutPip[14]  = BrkOutPip1400;
   BrkOutPip[15]  = BrkOutPip1500;
   BrkOutPip[16]  = BrkOutPip1600;
   BrkOutPip[17]  = BrkOutPip1700;
   BrkOutPip[18]  = BrkOutPip1800;
   BrkOutPip[19]  = BrkOutPip1900;
   BrkOutPip[20]  = BrkOutPip2000;
   BrkOutPip[21]  = BrkOutPip2100;
   BrkOutPip[22]  = BrkOutPip2200;
   BrkOutPip[23]  = BrkOutPip2300;

   //Break Out Revenge Pip Initialisation
   BrkOutPipR[1]   = BrkOutPipR0100;
   BrkOutPipR[2]   = BrkOutPipR0200;
   BrkOutPipR[3]   = BrkOutPipR0300;
   BrkOutPipR[4]   = BrkOutPipR0400;
   BrkOutPipR[5]   = BrkOutPipR0500;
   BrkOutPipR[6]   = BrkOutPipR0600;
   BrkOutPipR[7]   = BrkOutPipR0700;
   BrkOutPipR[8]   = BrkOutPipR0800;   
   BrkOutPipR[9]   = BrkOutPipR0900;
   BrkOutPipR[10]  = BrkOutPipR1000;
   BrkOutPipR[11]  = BrkOutPipR1100;
   BrkOutPipR[12]  = BrkOutPipR1200;
   BrkOutPipR[13]  = BrkOutPipR1300;
   BrkOutPipR[14]  = BrkOutPipR1400;
   BrkOutPipR[15]  = BrkOutPipR1500;
   BrkOutPipR[16]  = BrkOutPipR1600;
   BrkOutPipR[17]  = BrkOutPipR1700;
   BrkOutPipR[18]  = BrkOutPipR1800;
   BrkOutPipR[19]  = BrkOutPipR1900;
   BrkOutPipR[20]  = BrkOutPipR2000;
   BrkOutPipR[21]  = BrkOutPipR2100;
   BrkOutPipR[22]  = BrkOutPipR2200;
   BrkOutPipR[23]  = BrkOutPipR2300;
   
   //Limit Allowance Structure initialisation
   LAP[1]   = LAP0100;
   LAP[2]   = LAP0200;
   LAP[3]   = LAP0300;
   LAP[4]   = LAP0400;
   LAP[5]   = LAP0500;
   LAP[6]   = LAP0600;
   LAP[7]   = LAP0700;
   LAP[8]   = LAP0800;
   LAP[9]   = LAP0900;
   LAP[10]  = LAP1000;
   LAP[11]  = LAP1100;
   LAP[12]  = LAP1200;
   LAP[13]  = LAP1300;
   LAP[14]  = LAP1400;
   LAP[15]  = LAP1500;
   LAP[16]  = LAP1600;
   LAP[17]  = LAP1700;
   LAP[18]  = LAP1800;
   LAP[19]  = LAP1900;
   LAP[20]  = LAP2000;
   LAP[21]  = LAP2100;
   LAP[22]  = LAP2200;
   LAP[23]  = LAP2300;

   //Channel Factor initialisation
   ChanFactor[1]  = ChanFactor0100;
   ChanFactor[2]  = ChanFactor0200;
   ChanFactor[3]  = ChanFactor0300;
   ChanFactor[4]  = ChanFactor0400;
   ChanFactor[5]  = ChanFactor0500;
   ChanFactor[6]  = ChanFactor0600;
   ChanFactor[7]  = ChanFactor0700;
   ChanFactor[8]  = ChanFactor0800;
   ChanFactor[9]  = ChanFactor0900;
   ChanFactor[10] = ChanFactor1000;
   ChanFactor[11] = ChanFactor1100;
   ChanFactor[12] = ChanFactor1200;
   ChanFactor[13] = ChanFactor1300;
   ChanFactor[14] = ChanFactor1400;
   ChanFactor[15] = ChanFactor1500;
   ChanFactor[16] = ChanFactor1600;
   ChanFactor[17] = ChanFactor1700;
   ChanFactor[18] = ChanFactor1800;
   ChanFactor[19] = ChanFactor1900;
   ChanFactor[20] = ChanFactor2000;
   ChanFactor[21] = ChanFactor2100;
   ChanFactor[22] = ChanFactor2200;
   ChanFactor[23] = ChanFactor2300;

   //Analysis Min initialisation
   AnalysisMin[1]  = AnalysisMin0100;
   AnalysisMin[2]  = AnalysisMin0200;
   AnalysisMin[3]  = AnalysisMin0300;
   AnalysisMin[4]  = AnalysisMin0400;
   AnalysisMin[5]  = AnalysisMin0500;
   AnalysisMin[6]  = AnalysisMin0600;
   AnalysisMin[7]  = AnalysisMin0700;
   AnalysisMin[8]  = AnalysisMin0800;
   AnalysisMin[9]  = AnalysisMin0900;
   AnalysisMin[10] = AnalysisMin1000;
   AnalysisMin[11] = AnalysisMin1100;
   AnalysisMin[12] = AnalysisMin1200;
   AnalysisMin[13] = AnalysisMin1300;
   AnalysisMin[14] = AnalysisMin1400;
   AnalysisMin[15] = AnalysisMin1500;
   AnalysisMin[16] = AnalysisMin1600;
   AnalysisMin[17] = AnalysisMin1700;
   AnalysisMin[18] = AnalysisMin1800;
   AnalysisMin[19] = AnalysisMin1900;
   AnalysisMin[20] = AnalysisMin2000;
   AnalysisMin[21] = AnalysisMin2100;
   AnalysisMin[22] = AnalysisMin2200;
   AnalysisMin[23] = AnalysisMin2300;
   
   //Hour End initialisation
   HourEnd[1]  = HourEnd0100;
   HourEnd[2]  = HourEnd0200;
   HourEnd[3]  = HourEnd0300;
   HourEnd[4]  = HourEnd0400;
   HourEnd[5]  = HourEnd0500;
   HourEnd[6]  = HourEnd0600;
   HourEnd[7]  = HourEnd0700;
   HourEnd[8]  = HourEnd0800;
   HourEnd[9]  = HourEnd0900;
   HourEnd[10] = HourEnd1000;
   HourEnd[11] = HourEnd1100;
   HourEnd[12] = HourEnd1200;
   HourEnd[13] = HourEnd1300;
   HourEnd[14] = HourEnd1400;
   HourEnd[15] = HourEnd1500;
   HourEnd[16] = HourEnd1600;
   HourEnd[17] = HourEnd1700;
   HourEnd[18] = HourEnd1800;
   HourEnd[19] = HourEnd1900;
   HourEnd[20] = HourEnd2000;
   HourEnd[21] = HourEnd2100;
   HourEnd[22] = HourEnd2200;
   HourEnd[23] = HourEnd2300;
   
   for (int a=24;a<47;a++){
      TPpip[a]=RPip;
   }

   for (int s=1;s<24;s++){
      GetChannelPrice(s);
      DoneTrades(s);
      SwitchC[s]=true;
      TPpip[s]=TPPip;
   }
   
   string initheader  = "Initialisation of PoundingProfitsFX Mad Beta Version 1.5 on " + (string)TimeCurrent(),
          initmessage = "PoundingProfitsFX Mad has been initialised with:\n"+
                        "- Risk Level: " + (string) Risk + "\n" +
                        "- Risk Management Type: " + MMstring(MM) + "\n" +
                        "- Account Name: " + AccountName() + "\n" +
                        "- Account Number: " + (string)AccountNumber() + "\n" +
                        "- Account Server: " + AccountServer() + "\n" +
                        "- Current Balance: " + (string)AccountBalance() + "\n\n",
          chanprcmsg  = "",
          extramsg    = "";
   for (int w=1;w<24;w++){
      chanprcmsg += "- Top Channel Price for " + (string)(w) +": " + (string)EPPriceB[w] + "\n" +
                    "- Bottom Channel Price for " + (string)(w) +": " + (string)EPPriceS[w] + "\n" +
                    "- Channel Size: " + (string)(int)(fabs(EPPriceB[w]-EPPriceS[w])/Point) + " points\n\n";
      if (SwitchA[w]==false) chanprcmsg += "The channel has been breached, so there is no trade this session.\n\n";
   }

   if(GetMail) {
      bool sendmailchk = SendMail(initheader,initmessage+chanprcmsg);
      if (sendmailchk) extramsg = "Should you require more information, please check your email.";
      else extramsg = "There seems to be an error sending an email. Please check your email alert settings."; 
   } else {
      extramsg = "Extra information is only shown through email. Please apply for email alerts should you need information " +
                 "for buy and sell channel prices, as well as channel size.";
   }
   MessageBox(initmessage + extramsg,initheader);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
//---

   int OrdTot = OrdersTotal();
   for (int i=OrdTot-1; i>=0; i--) {
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      for (int j=1;j<=46;j++){
         if (OrderType() == OP_BUY  && OrderMagicNumber() == MagicNo+j &&
            // All exit conditions (Buy)
            ((OrderOpenPrice() - SLPip[j]*Point - Bid) >=0 ||
             (Bid - OrderOpenPrice() - TPpip[j]*Point) >=0 )){
            //
            if (!OrderClose(OrderTicket(),OrderLots(),Bid,30,clrWhiteSmoke)) 
               Print("OrderClose error :",GetLastError());
            if ((OrderOpenPrice() - SLPip[j]*Point - Bid) >=0 && OrderMagicNumber() < MagicNo+24){
               SLPip[j]=(int)((OrderOpenPrice()-OrderClosePrice())/Point);
               SwitchB[j]=true;
               Rcount[j]++;
               Rev[j]=Bid;
            }
            if (GetMail) CloseReport("Buy",Bid,OrderProfit()+OrderCommission(),j);
         } else
         if (OrderType() == OP_SELL && OrderMagicNumber() == MagicNo+j &&
            // All exit conditions (Sell)
            ((Ask - OrderOpenPrice() - SLPip[j]*Point) >=0 ||
             (OrderOpenPrice() - TPpip[j]*Point - Ask) >=0 )){
            //
            if (!OrderClose(OrderTicket(),OrderLots(),Ask,30,clrWhiteSmoke)) 
               Print("OrderClose error :",GetLastError());
            if (Ask - OrderOpenPrice() - SLPip[j]*Point >=0 && OrderMagicNumber() < MagicNo+24){
               SLPip[j]=(int)((OrderClosePrice()-OrderOpenPrice())/Point);
               SwitchB[j]=true;
               Rcount[j]++;
               Rev[j]=Ask;
            }
            if (GetMail) CloseReport("Sell",Ask,OrderProfit()+OrderCommission(),j);
         }
      }
   }
   
   for (int d=1;d<18;d++){
      if (Hour() == d && SwitchC[d]){
                  
         GetChannelPrice(d);
         
         SwitchA[d]=true;
         SwitchC[d]=false;
         SwitchE[d]=false;
      }

      if (Hour() == d && SwitchD[d]) {
         Print("The Buy and Sell Channel Prices are ",(string)EPPriceB[d]," and ",(string)EPPriceS[d]," for channel ",d,".");
         Print("The channel pip size is ",(string)(int)(fabs(EPPriceB[d]-EPPriceS[d])/Point)," points.");
         if (GetMail) ChannelUpdate(d);
         SwitchD[d]=false;
      } else if (Hour() == d-1){
         SwitchC[d]=true;
         SwitchD[d]=true;
      }
      
      if (Bid - EPPriceB[d] >=0 || EPPriceS[d] - Ask >=0) SwitchE[d]=true;
      
      // Sets trades after analysis
      if (TradeTime(d,HourEnd[d]) && SwitchA[d] && SwitchE[d]){
         
         if (AllowBuy(d)){
            if (/*(Ask - EPPriceB[d])/Point <= 10 &&*/ SpreadThreshold >= MarketInfo(Symbol(),MODE_SPREAD) &&
                OrdersTotal() == 0){
               initlots[d]=CalcLots(MM,Risk,OP_BUY,1,Bid-SLPip[d]*Point,Commission,CaplProt);
               res=OrderSend(Symbol(),OP_BUY,initlots[d],Ask,30,
                   0,0,"MPP Buy ("+(string)(d)+")",MagicNo+d,0,clrWhiteSmoke);
               if (GetMail) OpenReport("Buy",Ask,d);
            }
            Rcount[d] = SwitchA[d] = false;
            Print("Order Number is ",res,", and channel number is ",d);
            res=(-1);
         } else 
         if (AllowSell(d)){
            if (/*(EPPriceS[d] - Bid)/Point <= 10 &&*/ SpreadThreshold >= MarketInfo(Symbol(),MODE_SPREAD) &&
                OrdersTotal() == 0){
               initlots[d]=CalcLots(MM,Risk,OP_SELL,1,Ask+SLPip[d]*Point,Commission,CaplProt);
               res=OrderSend(Symbol(),OP_SELL,initlots[d],Bid,30,
                   0,0,"MPP Sell ("+(string)(d)+")",MagicNo+d,0,clrWhiteSmoke);
               if (GetMail) OpenReport("Sell",Bid,d);
            }
            Rcount[d] = SwitchA[d] = false;
            Print("Order Number is ",res,", and channel number is ",d);
            res=(-1);
         }
      }
      
      
      
      // Revenge Trading after SL is hit
      if (SwitchB[d]){
         double Rlotsize = CalcLots(MM_Fix,initlots[d]*SLPip[d]*Rfact/100/RPip,0,1,0,0,false);
         if (Rcount[d]>=1){
            if (AllowRBuy(d)){
               res=OrderSend(Symbol(),OP_BUY,Rlotsize,Ask,30,0,0,"MPP Buy Revenge ("+(string)(d)+")",MagicNo+d+23,0,clrWhiteSmoke);
               SwitchB[d]=0;
               if (GetMail) OpenReport("Buy Revenge",Ask,d);
            }
            if (AllowRSell(d)){
               res=OrderSend(Symbol(),OP_SELL,Rlotsize,Bid,30,0,0,"MPP Sell Revenge ("+(string)(d)+")",MagicNo+d+23,0,clrWhiteSmoke);
               SwitchB[d]=0;
               if (GetMail) OpenReport("Sell Revenge",Bid,d);
            }
         }
      }
   }
   
   if (SpreadThreshold < MarketInfo(Symbol(),MODE_SPREAD)) 
      Print("The spread now is ",(string)MarketInfo(Symbol(),MODE_SPREAD)," points.");
}

//+------------------------------------------------------------------+


void GetChannelPrice(int r){    //To get pipsize of the Limit Allowance, SL, and the channel prices
   // Initialise the SL target numbers
   // // Calculate the bar number that corresponds to HourStart and MinuteStart to set an anchoring point
   EPPriceB[r]=0;
   EPPriceS[r]=10000;
   for (int DayBarNo = 0; DayBarNo <= 1440; DayBarNo++){
      if (TimeHour  (iTime(Symbol(),PERIOD_M1,DayBarNo)) == r   &&
          TimeMinute(iTime(Symbol(),PERIOD_M1,DayBarNo)) == 0){ 
         TimeNo[r] = DayBarNo;
         break;
      }
   }
   // // Calculate the highest and lowest price within the analysed bars
   for (int i = TimeNo[r]+1; i <= (TimeNo[r] + AnalysisMin[r]); i++){
      if (EPPriceB[r]<=iHigh(Symbol(),PERIOD_M1,i)) EPPriceB[r] =iHigh(Symbol(),PERIOD_M1,i);
      if (EPPriceS[r]>=iLow (Symbol(),PERIOD_M1,i)) EPPriceS[r] =iLow (Symbol(),PERIOD_M1,i);
   }
   
   newLAP[r]= (int)(fabs(EPPriceB[r]-EPPriceS[r])/Point * LAP[r]/100);
   
   EPPriceB[r] = ND(EPPriceB[r]+newLAP[r]*Point);
   EPPriceS[r] = ND(EPPriceS[r]-newLAP[r]*Point);
   
   SLPip[r]    = (int)(BrkOutPip[r]  * 2 * ChanFactor[r] / 100);
   SLPip[r+23] = (int)(BrkOutPipR[r] * 2 * ChanFactor[r] / 100);
   
}

void DoneTrades(int q){
   int count=0;
   for (int j = 0; j <= TimeNo[q]+1; j++){
      if ( EPPriceB[q] > EPPriceS[q] ){
         if ( EPPriceB[q] <= iHigh(Symbol(),PERIOD_M1,j) ) count++;
         if ( EPPriceS[q] >= iLow (Symbol(),PERIOD_M1,j) ) count++;
      }
   }
   if (count>0)  SwitchA[q]=false;
   if (count==0) SwitchA[q]=true;
   Print(TimeNo[q]+1," ",SwitchA[q]);
}

bool TradeTime (int hourstart, int hourend){
   bool result=0;
   hourstart=hourstart%24;
   hourend=hourend%24;
        if (hourstart < hourend) result = Hour() >= hourstart && Hour() < hourend; 
   else if (hourstart > hourend) result = Hour() <= hourstart || Hour() > hourend ;
   
   return result;
}

bool AllowBuy(int a){
   bool BuyStop         = (Ask - (EPPriceB[a] + BrkOutPip[a]*Point))/Point >=0,
        BuyLimit        = (Ask - (EPPriceS[a] + BrkOutPip[a]*Point))/Point >=0;
   return (BuyStop || BuyLimit);
}

bool AllowRBuy(int a){
   bool BuyStop         = (Ask - (Rev[a] + BrkOutPipR[a]*Point))/Point >=0;
   return (BuyStop);
}

bool AllowSell(int a){
   bool SellLimit       = ((EPPriceB[a] - BrkOutPip[a]*Point) - Bid)/Point >=0,
        SellStop        = ((EPPriceS[a] - BrkOutPip[a]*Point) - Bid)/Point >=0;
   return (SellStop || SellLimit);
}

bool AllowRSell(int a){
   bool SellStop        = ((Rev[a] - BrkOutPipR[a]*Point) - Bid)/Point >=0;
   return (SellStop);
}
//+------------------------------------------------------------------+
//| Send Mail Reports                                                |
//+------------------------------------------------------------------+

void ChannelUpdate(int arraynumber){
   SendMail("Channel Update on " + (string)TimeCurrent()+ " for " + (string)(arraynumber),
            "The new channel values are:\n" +
            "- Top Channel Price: " + (string)EPPriceB[arraynumber] + "\n" +
            "- Bottom Channel Price: " + (string)EPPriceS[arraynumber] + "\n" +
            "- Channel Size: " + (string)(int)(fabs(EPPriceB[arraynumber]-EPPriceS[arraynumber])/Point) + " points"); 
}

void OpenReport(string ordertype,double openprice, int arraynumber){
   SendMail("Open Report on " + (string)TimeCurrent()+ " for " + (string)(arraynumber) + " channel",
            "A " + ordertype + " order has been opened at " + (string)openprice + " for account number " +
            (string)AccountNumber() + " at " + AccountServer() + ".");
}

void CloseReport(string ordertype,double closeprice,double ProfComm,int arraynumber){
   string profitloss = "profit";
   if (ProfComm < 0) profitloss="loss";
   
   string report = "A " + ordertype + " order has been closed at " + (string)closeprice + " for account number " +
                   (string)AccountNumber() + " at " + AccountServer() + ".\n" +
                   "A " + profitloss + " of " + (string)ProfComm + " " + 
                   AccountCurrency() + " has been made.\n" + 
                   "Current Balance is now " + (string)AccountBalance() + " " + AccountCurrency() + ".\n";
                   
   if (ProfComm < 0) report+= "\n\nA revenge trade report should be sent soon.";
   
   SendMail("Close Report on " + (string)TimeCurrent()+ " for " + (string)(arraynumber) + " channel",
            report);
}