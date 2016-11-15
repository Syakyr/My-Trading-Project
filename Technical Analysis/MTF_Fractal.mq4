//+------------------------------------------------------------------+
//|                                                 MTF_Fractals.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      "http://www.forex-tsd.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red


//---- input parameters
/*************************************************************************
PERIOD_M1   1
PERIOD_M5   5
PERIOD_M15  15
PERIOD_M30  30 
PERIOD_H1   60
PERIOD_H4   240
PERIOD_D1   1440
PERIOD_W1   10080
PERIOD_MN1  43200
You must use the numeric value of the timeframe that you want to use
when you set the TimeFrame' value with the indicator inputs.
---------------------------------------
**************************************************************************/
extern int TimeFrame=60;

double ExtMapBuffer1[];
double ExtMapBuffer2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   
//---- indicator line

   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,119);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,119);
   
//---- name for DataWindow and indicator subwindow label   
   switch(TimeFrame)
   {
      case 1 : string TimeFrameStr="Period_M1"; break;
      case 5 : TimeFrameStr="Period_M5"; break;
      case 15 : TimeFrameStr="Period_M15"; break;
      case 30 : TimeFrameStr="Period_M30"; break;
      case 60 : TimeFrameStr="Period_H1"; break;
      case 240 : TimeFrameStr="Period_H4"; break;
      case 1440 : TimeFrameStr="Period_D1"; break;
      case 10080 : TimeFrameStr="Period_W1"; break;
      case 43200 : TimeFrameStr="Period_MN1"; break;
      default : TimeFrameStr="Current Timeframe";
   } 
   IndicatorShortName("Fractals "+TimeFrameStr);  
  }
//----
   return(0);
 
//+------------------------------------------------------------------+
//| MTF Fractals                                                     |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,shift,limit,y=0,counted_bars=IndicatorCounted();
    
// Plot defined timeframe on to current timeframe   
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame); 
   
   limit=Bars-counted_bars+TimeFrame/Period();
   for(i=0,y=0;i<limit;i++)
   {
   if (Time[i]<TimeArray[y]) y++; 
   
 /***********************************************************   
   Add your main indicator loop below.  You can reference an existing
      indicator with its iName  or iCustom.
   Rule 1:  Add extern inputs above for all neccesary values   
   Rule 2:  Use 'TimeFrame' for the indicator timeframe
   Rule 3:  Use 'y' for the indicator's shift value
 **********************************************************/  
     
   ExtMapBuffer1[i]=iFractals(NULL,TimeFrame,1,y);
   ExtMapBuffer2[i]=iFractals(NULL,TimeFrame,2,y);
   
   
   }  
     
//
   
  
  
   return(0);
  }
//+------------------------------------------------------------------+