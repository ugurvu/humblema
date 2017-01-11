//+------------------------------------------------------------------+
//|                                                     HumbleMA.mq4 |
//|                                        Copyright 2016, Humble AI |
//|                                          http://www.humbleai.com |
//+------------------------------------------------------------------+
#property copyright   "2016, Humble AI"
#property link        "http://www.humbleai.com"
#property description "Humble MA"

#property indicator_chart_window

#property indicator_buffers 1

#property indicator_color1 DeepPink

#property indicator_width1 2

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

int OnInit(void)
  {

   IndicatorShortName("Humble MA");
   
   IndicatorBuffers(5);
   
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, ExtLineBuffer);

   SetIndexBuffer(1, PriceHExtLineBuffer);

   SetIndexBuffer(2, PriceLExtLineBuffer); 
     
   SetIndexBuffer(3, PriceExtLineBuffer);
   
   SetIndexBuffer(4, MAPeriodBuffer);

   return(INIT_SUCCEEDED);
  }
  

void start()
  {
   int i, Counted_bars; 
//--------------------------------------------------------------------
   Counted_bars = IndicatorCounted(); // Number of counted bars
   i=Bars-Counted_bars-1;             // Index of the first uncounted
   int HighIndex, LowIndex;           // Prev HL positions
   
   switch(PriceMode) 
     {   
      case 0 : PriceExtLineBuffer[0] = Close[0];      break;
      case 1 : PriceExtLineBuffer[0] = High[0];    break;
      case 2 : PriceExtLineBuffer[0] = Low[0];  break;
      case 3 : PriceExtLineBuffer[0] = (High[0] + Low[0] + Close[0]) / 3;   break;
      case 4 : PriceExtLineBuffer[0] = (High[0] + Low[0]) / 2;   break;
      default: PriceExtLineBuffer[0] = Close[0]; 
     }      

   while(i>=0)                      // Loop for uncounted bars
     {
      HighIndex = iHighest(NULL, 0, MODE_HIGH, InpPricePeriod, i);
      LowIndex = iLowest(NULL, 0, MODE_LOW, InpPricePeriod, i);
      
      double highestp = High[HighIndex];
      double lowestp = Low[LowIndex];
      
      double currentp;

      switch(PriceMode) 
        {   
         case 0 : currentp = Close[i];      break;
         case 1 : currentp = High[i];    break;
         case 2 : currentp = Low[i];  break;
         case 3 : currentp = (High[i] + Low[i] + Close[i]) / 3;   break;
         case 4 : currentp = (High[i] + Low[i]) / 2;   break;
         default: currentp = Close[i]; 
        }      
      
      
      PriceExtLineBuffer[i] = MathAbs(currentp - lowestp) * 100 / (MathAbs(highestp - currentp) + MathAbs(currentp - lowestp));
      
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
