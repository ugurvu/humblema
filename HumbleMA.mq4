//+------------------------------------------------------------------+
//|                                                     HumbleMA.mq4 |
//|                                        Copyright 2016, Humble AI |
//|                                          http://www.humbleai.com |
//+------------------------------------------------------------------+
#property copyright   "2016, Humble AI"
#property link        "http://www.humbleai.com"
#property description "Humble MA"

#property indicator_chart_window

#property indicator_buffers 2

#property indicator_color1 DeepPink
#property indicator_color2 DeepPink

#property indicator_width1 2
#property indicator_width2 1

//--- indicator parameters

input int            InpPricePeriod = 1440;        // Price Period
input int            PriceMode = 3;                // 0: Close, 1: High, 2: Low, 3: Typical, 4: Median
input int            MAType = 1;                   // 0: SMA, 1: EMA, 2: Smoothed, 3: LWMA

//--- indicator buffers
double PriceExtLineBuffer[];
double PriceHExtLineBuffer[];
double PriceLExtLineBuffer[];
double ExtLineBuffer[];
double MAPeriodBuffer[];
double ChikouBuffer[];
int OnInit(void)
  {

   IndicatorShortName("Humble MA");
   
   IndicatorBuffers(6);
   
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, ExtLineBuffer);
   
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, ChikouBuffer);
   SetIndexShift(1,-InpPricePeriod);
   
   SetIndexBuffer(2, PriceHExtLineBuffer);

   SetIndexBuffer(3, PriceLExtLineBuffer);  
   
   SetIndexBuffer(4, MAPeriodBuffer);
   
   SetIndexBuffer(5, PriceExtLineBuffer);

   return(INIT_SUCCEEDED);
  }
  

void start()
  {
   int i, Counted_bars; 
//--------------------------------------------------------------------
   Counted_bars = IndicatorCounted(); // Number of counted bars
   i=Bars-Counted_bars-1;             // Index of the first uncounted
   int HighIndex, LowIndex;           // Prev HL positions
  /* 
   switch(PriceMode) 
     {   
      case 0 : PriceExtLineBuffer[0] = Close[0];      break;
      case 1 : PriceExtLineBuffer[0] = High[0];    break;
      case 2 : PriceExtLineBuffer[0] = Low[0];  break;
      case 3 : PriceExtLineBuffer[0] = (High[0] + Low[0] + Close[0]) / 3;   break;
      case 4 : PriceExtLineBuffer[0] = (High[0] + Low[0]) / 2;   break;
      default: PriceExtLineBuffer[0] = Close[0]; 
     }      
*/
   while(i>=0)                      // Loop for uncounted bars
     {
      HighIndex = iHighest(NULL, 0, MODE_HIGH, InpPricePeriod, i);
      LowIndex = iLowest(NULL, 0, MODE_LOW, InpPricePeriod, i);
      
      double highestp = High[HighIndex];
      double lowestp = Low[LowIndex];

      switch(PriceMode) 
        {   
         case 0 : ChikouBuffer[i] = Close[i];      break;
         case 1 : ChikouBuffer[i] = High[i];    break;
         case 2 : ChikouBuffer[i] = Low[i];  break;
         case 3 : ChikouBuffer[i] = (High[i] + Low[i] + Close[i]) / 3;   break;
         case 4 : ChikouBuffer[i] = (High[i] + Low[i]) / 2;   break;
         default: ChikouBuffer[i] = Close[i]; 
        }      
      
      PriceExtLineBuffer[i] = MathAbs(ChikouBuffer[i] - lowestp) * 100 / (MathAbs(highestp - ChikouBuffer[i]) + MathAbs(ChikouBuffer[i] - lowestp));
      
      PriceHExtLineBuffer[i] = highestp;
      PriceLExtLineBuffer[i] = lowestp;
      
      if (HighIndex < LowIndex) 
         MAPeriodBuffer[i]= iLowest(NULL, 0, MODE_LOW, InpPricePeriod, i)-i;
      else
         MAPeriodBuffer[i]=iHighest(NULL, 0, MODE_HIGH, InpPricePeriod, i)-i;
     
      i--;
     }
   
   
   for(i = 0; i <= Bars - Counted_bars - 1; i++) ExtLineBuffer[i]=(iMAOnArray(PriceExtLineBuffer, 0, MathRound(MAPeriodBuffer[i]), 0, MAType, i)*(PriceHExtLineBuffer[i] - PriceLExtLineBuffer[i])/100)+PriceLExtLineBuffer[i];
    
   return;
  }
