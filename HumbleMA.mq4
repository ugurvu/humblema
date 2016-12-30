//+------------------------------------------------------------------+
//|                                                     HumbleMA.mq4 |
//|                                        Copyright 2016, Humble AI |
//|                                          http://www.humbleai.com |
//+------------------------------------------------------------------+
#property copyright   "2016, Humble AI"
#property link        "http://www.humbleai.com"
#property description "Humble MA"

#property strict

#property indicator_chart_window

#property indicator_buffers 3

#property indicator_color1 DeepPink
#property indicator_color2 DodgerBlue
#property indicator_color3 DodgerBlue

#property indicator_width1 2
#property indicator_width2 1
#property indicator_width3 1

//--- indicator parameters

input int            InpPricePeriod=120;        // Price Period
input int            PriceMode=1;               // 1: Typical, Other: Median
input int            MAType=1;                  // 0: SMA, 1: EMA, 2: Smoothed, 3: LWMA

//--- indicator buffers
double PriceExtLineBuffer[];
double PriceHExtLineBuffer[];
double PriceLExtLineBuffer[];
double ExtLineBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {

   IndicatorShortName("Humble MA");
   
   IndicatorBuffers(4);
   
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, ExtLineBuffer);
   
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, PriceHExtLineBuffer);
   
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, PriceLExtLineBuffer); 
     
   SetIndexBuffer(3, PriceExtLineBuffer);

   return(INIT_SUCCEEDED);
  }
  

void start()
  {
   int i, Counted_bars; 
//--------------------------------------------------------------------
   Counted_bars = IndicatorCounted(); // Number of counted bars
   i=Bars-Counted_bars-1;           // Index of the first uncounted
   
   if (PriceMode == 1) {
      PriceExtLineBuffer[0] = (High[0] + Low[0] + Close[0]) / 3;   // Typical
   } else {
      PriceExtLineBuffer[0] = (High[0] + Low[0]) / 2;              // Median
   }
   
   while(i>=0)                      // Loop for uncounted bars
     {
         double highestp = High[iHighest(NULL, 0, MODE_HIGH, InpPricePeriod, i)];
         double lowestp = Low[iLowest(NULL, 0, MODE_LOW, InpPricePeriod, i)];
         double currentp;
         currentp=(High[i] + Low[i] + Close[i])/3;
         
         PriceExtLineBuffer[i] = MathAbs(currentp - lowestp) * 100 / (MathAbs(highestp - currentp) + MathAbs(currentp - lowestp));
         
         PriceHExtLineBuffer[i] = highestp;
         PriceLExtLineBuffer[i] = lowestp;
      i--;
     }
   
   
   for(i = 0; i <= Bars - Counted_bars - 1; i++) {
     int maperiod;
     if (iHighest(NULL, 0, MODE_HIGH, InpPricePeriod, i) < iLowest(NULL, 0, MODE_LOW, InpPricePeriod, i)) maperiod= iLowest(NULL, 0, MODE_LOW, InpPricePeriod, i)-i;
     else maperiod=iHighest(NULL, 0, MODE_HIGH, InpPricePeriod, i)-i;
     
     ExtLineBuffer[i]=(iMAOnArray(PriceExtLineBuffer, 0, maperiod, 0, MAType, i)*(PriceHExtLineBuffer[i] - PriceLExtLineBuffer[i])/100)+PriceLExtLineBuffer[i];
   }
    
   return;
  }
  
