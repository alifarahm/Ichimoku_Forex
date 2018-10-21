//+------------------------------------------------------------------+
#define SIGNAL_NONE 0
#define SIGNAL_BUY   1
#define SIGNAL_SELL  2
#define SIGNAL_CLOSEBUY 3
#define SIGNAL_CLOSESELL 4

extern int MagicNumber = 12345;
extern bool SignalMail = False;
extern double Lots = 2.0;
extern int Slippage = 1;
extern bool UseStopLoss = True;
extern int StopLoss = 20;
extern bool UseTakeProfit = True;
extern int TakeProfit = 40;
extern bool UseTrailingStop = True;
extern int TrailingStop =80;

extern int sma_short = 10;
extern int sma_long = 40;

input int kumoThreshold=300;//minimum size of kumo to open an order
input int failSafe=0;//0 is off, >0 sets the break even n pips above the entry price
input double failSafeCloserMultiplier=.1;//the amount of lots that are closed if failsafe is on
extern double orderStopLossRisk=.02;//stop loss %risk of account balance entered in decimal format
//---end micker's mod

// Money management

extern bool MM=true;     // If true - ATR-based position sizing
extern int ATR_Period=14;
extern double ATR_Multiplier=1;
extern double Risk=2; // Risk tolerance in percentage points
extern double FixedBalance=0; // If greater than 0, position size calculator will use it instead of actual account balance.
extern double MoneyRisk=0; // Risk tolerance in base currency
extern bool UseMoneyInsteadOfPercentage=false;
extern bool UseEquityInsteadOfBalance=false;
extern int LotDigits=2; // How many digits after dot supported in lot size. For example, 2 for 0.01, 1 for 0.1, 3 for 0.001, etc.

// Miscellaneous


// Common// Global variable
int Magic=2130512104;    // Order magic number
string OrderCommentary="Ichimoku-Chinkou-Hyo";
int Tenkan = 9; // Tenkan line period. The fast "moving average".
int Kijun = 26; // Kijun line period. The slow "moving average".
int Senkou= 52; // Senkou period. Used for Kumo (Cloud) spans.
int LastBars=0;
int BuyStrategy =0;
int SellStrategy = 0;
int TradeStrategy=0;
bool HaveLongPosition;
bool HaveShortPosition;


                 // Entry signals

double RSI = 0;




int P = 1;
int Order = SIGNAL_NONE;
int STR;
int Total, Ticket, Ticket2;
double StopLossLevel, TakeProfitLevel, StopLevel;
double sma10_1, sma10_2, sma40_1, sma40_2;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int init() {
   
   if(Digits == 5 || Digits == 3 || Digits == 1)P = 10;else P = 1; // To account for 5 digit brokers

   return(0);
}
//+------------------------------------------------------------------+
//| Expert initialization function - END                             |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() {
   return(0);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function - END                           |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert start function                                            |
//+------------------------------------------------------------------+
int start() {
bool ChinkouPriceBull = false;
bool ChinkouPriceBear = false;
bool KumoBullConfirmation = false;
bool KumoBearConfirmation = false;
bool KumoChinkouBullConfirmation = false;
bool KumoChinkouBearConfirmation = false;
bool TenkenTrendBull = false;
bool TenkenTrendBear = false;
bool KijunTrendBull = false;
bool KijunTrendBear = false;
bool TenkenCrossBull = false;
bool TenkenCrossBear = false;
bool KijunCrossBull = false;
bool KijunCrossBear = false;
bool TenkenCrossKingunBull = false;
bool TenkenCrossKingunBear = false;
bool TenkenKijunDiff = false;
bool TenkenKigunStateBull = false;
bool TenkenKigunStateBear = false;
bool ChinkouCloseBull = false;
bool ChinkouCloseBear = false;
bool TenkanStateBear = false;
bool TenkanStateBull = false;
bool KijunStateBear = false;
bool KijunStateBull = false;
bool KumoConfirmation = false;
bool KijunZeroTrend = false;
bool CloseDiff=False;
bool KijenCloseBear = False;
bool KijenCloseBull = False;
bool KumoBullCross = False;
bool KumoBull = False;
bool KumoBearCross = False;
bool KumoBear = False;
bool St3= False;
bool St4= False;
bool TenkenTrendZero=False;
bool  KijunTuch= False;
bool St5= False;
bool St6=False;




 double ChinkouSpanLatest=iIchimoku(NULL,0,Tenkan,Kijun,Senkou,MODE_CHINKOUSPAN,Kijun+1); // Latest closed bar with Chinkou.
   double ChinkouSpanPreLatest=iIchimoku(NULL,0,Tenkan,Kijun,Senkou,MODE_CHINKOUSPAN,Kijun+2); // Bar older than latest closed bar with Chinkou.
   double RSI =iRSI(NULL,0,14,PRICE_CLOSE,0);

                                                                                               // Bullish entry condition
   if((ChinkouSpanLatest>Close[Kijun+1]) && (ChinkouSpanPreLatest<=Close[Kijun+2]))
     {
      ChinkouPriceBull = true;
      ChinkouPriceBear = false;
     }
// Bearish entry condition
   else if((ChinkouSpanLatest<Close[Kijun+1]) && (ChinkouSpanPreLatest>=Close[Kijun+2]))
     {
      ChinkouPriceBull = false;
      ChinkouPriceBear = true;
     }
   else if(ChinkouSpanLatest==Close[Kijun+1]) // Voiding entry conditions if cross is ongoing.
     {
      ChinkouPriceBull = false;
      ChinkouPriceBear = false;
     }
     
   if (ChinkouSpanLatest>Close[Kijun+1])ChinkouCloseBull=true;
   else ChinkouCloseBear=false;
//+------------------------------------------------------------------+
//|Micker's Mods indicator setups                                    |                 
//+------------------------------------------------------------------+
   double tenkanSen= iIchimoku(NULL,PERIOD_CURRENT,Tenkan,Kijun,Senkou,MODE_TENKANSEN,0);
   double kijunSen = iIchimoku(NULL,PERIOD_CURRENT,Tenkan,Kijun,Senkou,MODE_KIJUNSEN,0);
   double tenkanSenHist= iIchimoku(NULL,PERIOD_CURRENT,Tenkan,Kijun,Senkou,MODE_TENKANSEN,1);
   double kijunSenHist = iIchimoku(NULL,PERIOD_CURRENT,Tenkan,Kijun,Senkou,MODE_KIJUNSEN,1);
   double tenkanSen2= iIchimoku(NULL,PERIOD_CURRENT,Tenkan,Kijun,Senkou,MODE_TENKANSEN,2);
   double kijunSen2 = iIchimoku(NULL,PERIOD_CURRENT,Tenkan,Kijun,Senkou,MODE_KIJUNSEN,2);
   
   
// Tenken/Price Cross
                                                                                               // Bullish entry condition
   if((Close[0]>tenkanSen) && (tenkanSenHist>=Close[1]))
     {
      TenkenCrossBull = True;
      TenkenCrossBear = False;
     }
   else if ((Close[0]<tenkanSen) && (tenkanSenHist<=Close[1]))
      {
      TenkenCrossBull = False;
      TenkenCrossBear = True;
      }
// Kijunsen/Price Cross

   else if((Close[0]>kijunSen) && (kijunSenHist>=Close[1]))
     {
       KijunCrossBull = True;
       KijunCrossBear = False;
     }
     
    else if((Close[0]<kijunSen) && (kijunSenHist<=Close[1]))
     {
       KijunCrossBull = False;
       KijunCrossBear = True;
     }
     
    
     
     if (tenkanSen > tenkanSenHist)
      {
      TenkenTrendBull = True;
      TenkenTrendBear = False;
      }
     else if (tenkanSen == tenkanSenHist)
      {
      TenkenTrendZero = True;
      }
    else if (tenkanSen < tenkanSenHist)
      {
      TenkenTrendBull = False;
      TenkenTrendBear = True;
      }
   if (kijunSen > kijunSenHist)
      {
      KijunTrendBull = True;
      KijunTrendBear = False;
      }
   else if (kijunSen = kijunSenHist)
      {
      KijunZeroTrend = True;
      }
   else if (kijunSen < kijunSenHist)
      {
      KijunTrendBull = False;
      KijunTrendBear = True;
      }
      
   if((tenkanSen>(kijunSen)) && (tenkanSenHist<=kijunSenHist))
     {
      TenkenCrossKingunBull = True;
      TenkenCrossKingunBear = False;
     }
    else if ((tenkanSen<(kijunSen)) && (tenkanSenHist>=kijunSenHist))
     {
      TenkenCrossKingunBull = False;
      TenkenCrossKingunBear = True;
     }
   
   if ((-0.015<=(((tenkanSen-kijunSen)/kijunSen)*100))&& ((((tenkanSen-kijunSen)/kijunSen)*100) <= 0.015))TenkenKijunDiff=True; //&& ((((tenkanSen-kijunSen)/kijunSen)*100) > -0.015)
   else TenkenKijunDiff=False;
   
   if ((-0.1<=(((Close[0]-kijunSen)/kijunSen)*100))&& ((((Close[0]-kijunSen)/kijunSen)*100) <= 0.1))CloseDiff=True; //&& ((((tenkanSen-kijunSen)/kijunSen)*100) > -0.015)
   else TenkenKijunDiff=False;
   
   if (tenkanSen>=kijunSen) {
   TenkenKigunStateBull=True;
   TenkenKigunStateBear=False;
   }
   
   else {
   TenkenKigunStateBear=True;
   TenkenKigunStateBull=False;
   }
   
   if (Close[0]>tenkanSen) TenkanStateBull=true;
   else TenkanStateBear=true;
   
   if (Close[0]>kijunSen) KijunStateBull=True;
   else KijunStateBear=true;
   
   if (Close[0] == kijunSen) KijunTuch=True;
   else KijunTuch= False;
   
   if (Close[0]<kijunSen && Close[1]<kijunSenHist ) KijenCloseBear = True;
   else KijenCloseBear = False;
   if (Close[0]>kijunSen && Close[1]>kijunSenHist )  KijenCloseBull = True;
   else KijenCloseBull = False;
   
   // Kumo confirmation. When cross is happening current price (latest close) should be above/below both Senkou Spans, or price should close above/below both Senkou Spans after a cross.
   double SenkouSpanALatestByPrice = iIchimoku(NULL, 0, Tenkan, Kijun, Senkou, MODE_SENKOUSPANA, 1); // Senkou Span A at time of latest closed price bar.
   double SenkouSpanBLatestByPrice = iIchimoku(NULL, 0, Tenkan, Kijun, Senkou, MODE_SENKOUSPANB, 1); // Senkou Span B at time of latest closed price bar.
   double SenkouSpanA2 = iIchimoku(NULL, 0, Tenkan, Kijun, Senkou, MODE_SENKOUSPANA, 2); // Senkou Span A at time of latest closed price bar.
   double SenkouSpanB2 = iIchimoku(NULL, 0, Tenkan, Kijun, Senkou, MODE_SENKOUSPANB, 2); // Senkou Span B at time of latest closed price bar.
   if((Close[1]>SenkouSpanALatestByPrice) && (Close[1]>SenkouSpanBLatestByPrice)) KumoBullConfirmation=True;
   else KumoBullConfirmation=false;
   if((Close[1]<SenkouSpanALatestByPrice) && (Close[1]<SenkouSpanBLatestByPrice)) KumoBearConfirmation=True;
   else KumoBearConfirmation=false;
   if ((KumoBullConfirmation) || (KumoBearConfirmation))KumoConfirmation=true;
   
   
   double SenkouSpanA = iIchimoku(NULL, 0, Tenkan, Kijun, Senkou, MODE_SENKOUSPANA, 0); // Senkou Span A at time of latest closed price bar.
   double SenkouSpanB = iIchimoku(NULL, 0, Tenkan, Kijun, Senkou, MODE_SENKOUSPANB, 0); // Senkou Span B at time of latest closed price bar.
   
   if (SenkouSpanA>SenkouSpanB) {KumoBull = True; KumoBear=False;}
   else if (SenkouSpanA<SenkouSpanB) {KumoBear = True; KumoBull = False;}
   
   if(((Close[1]<SenkouSpanALatestByPrice) && (KumoBull) && (Close[0]>SenkouSpanA) && (Close[2]<SenkouSpanA2) )|| ((TenkanStateBull)&&(Close[1]<SenkouSpanBLatestByPrice) && (KumoBear) && (Close[0]>SenkouSpanB) && (Close[2]<SenkouSpanB2))) KumoBullCross=True;
   else KumoBullCross=false;
   
   
   if(((TenkanStateBear)&&(Close[1]>SenkouSpanBLatestByPrice) && (Close[0]<SenkouSpanB) &&(KumoBear)&& (Close[2]>SenkouSpanB2))||((TenkanStateBear)&&(Close[1]>SenkouSpanBLatestByPrice) && (Close[0]<SenkouSpanB) &&(KumoBull)&& (Close[2]>SenkouSpanB2))) KumoBearCross=True;
   else KumoBearCross=false;
   
   if ((TenkenKigunStateBull) && ((tenkanSen-kijunSen>0.004)) && (KijunZeroTrend) && (TenkenCrossBear)&&(KumoConfirmation)&&(Close[1]>tenkanSenHist)) St3= True;
   else St3=False;
   
   if ((TenkenKigunStateBear) && ((kijunSen-tenkanSen>0.004)) && (KijunZeroTrend) && (TenkenCrossBull)&&(KumoConfirmation)&&((TenkenTrendBull)||(TenkenTrendZero))) St4= True;
   else St4=False;
   
   if ((Close[1]<tenkanSenHist) && (Close[1]< kijunSenHist) && (Close[0]>tenkanSen) && (Close[0]>kijunSen)&&(Close[2]<tenkanSen2) && (Close[2]< kijunSen2)&&(KumoConfirmation)) St5 = True;
   else St5=False;
   
   if ((Close[1]>tenkanSenHist) && (Close[1]> kijunSenHist) && (Close[0]<tenkanSen) && (Close[0]<kijunSen)&&(Close[2]>tenkanSen2) && (Close[2]> kijunSen2)&&(KumoConfirmation)) St6 = True;
   else St6=False;
   
   

   Total = OrdersTotal();
   Order = SIGNAL_NONE;

   //+------------------------------------------------------------------+
   //| Variable Setup                                                   |
   //+------------------------------------------------------------------+

   sma10_1 = iMA(NULL, 0, sma_short, 0, MODE_SMA, PRICE_CLOSE, 1); // c
   sma10_2 = iMA(NULL, 0, sma_short, 0, MODE_SMA, PRICE_CLOSE, 2); // b
   sma40_1 = iMA(NULL, 0, sma_long, 0, MODE_SMA, PRICE_CLOSE, 1); // d
   sma40_2 = iMA(NULL, 0, sma_long, 0, MODE_SMA, PRICE_CLOSE, 2); // a
   
   
   StopLevel = (MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD)) / P;// Defining minimum StopLevel

   if (StopLoss < StopLevel) StopLoss = StopLevel;
   if (TakeProfit < StopLevel) TakeProfit = StopLevel;

   //+------------------------------------------------------------------+
   //| Variable Setup - END                                             |
   //+------------------------------------------------------------------+

   //Check position
   bool IsTrade = False;

   for (int i = 0; i < Total; i ++) {
      Ticket2 = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderType() <= OP_SELL &&  OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         IsTrade = True;
         if(OrderType() == OP_BUY) {
            //Close

            //+------------------------------------------------------------------+
            //| Signal Begin(Exit Buy)                                           |
            //+------------------------------------------------------------------+

            /* BELINDA EXIT RULES:
               Exit the long trade when SMA(10) crosses SMA(40) from top
               Exit the short trade when SMA(10) crosses SMA(40) from bottom
               30 pips hard stop (30pips from initial entry price)
               Trailing stop of 30 pips   TenkenCrossKingunBear   TenkenTrendBear
            */
            if (STR==1 && KijunCrossBear) Order = SIGNAL_CLOSEBUY; 
            else if (STR==2 && KijunCrossBear) Order = SIGNAL_CLOSEBUY;
            else if ((STR==3) && (KijunCrossBear)) Order = SIGNAL_CLOSEBUY;
            else if ((STR==4) && (KijunCrossBear)) Order = SIGNAL_CLOSEBUY;
            //if(KijunCrossBear) Order = SIGNAL_CLOSEBUY; // Rule to EXIT a Long trade
           

            //+------------------------------------------------------------------+
            //| Signal End(Exit Buy)                                             |
            //+------------------------------------------------------------------+
           
            
            if (Order == SIGNAL_CLOSEBUY) {
               Ticket2 = OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, MediumSeaGreen);
               if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + " Close Buy");
               IsTrade = False;
               continue;
            }
            //Trailing stop
            if(UseTrailingStop && TrailingStop > 0) {                 
               if(Bid - OrderOpenPrice() > P * Point * TrailingStop) {
                  if(OrderStopLoss() < Bid - P * Point * TrailingStop) {
                     Ticket2 = OrderModify(OrderTicket(), OrderOpenPrice(), Bid - P * Point * TrailingStop, OrderTakeProfit(), 0, MediumSeaGreen);
                     continue;
                  }
               }
            }
         } else {
            //Close

            //+------------------------------------------------------------------+
            //| Signal Begin(Exit Sell)                                          |
            //+------------------------------------------------------------------+
           // TenkenCrossKingunBull
           // if ((KijunCrossBull)) Order = SIGNAL_CLOSESELL; // Rule to EXIT a Short trade
            
            if ((STR==11) && KijenCloseBull){ Order = SIGNAL_CLOSESELL; Print("STR=11");}
            else if ((STR==12) && ((TenkenTrendBull)||(Close[1]>kijunSen && Close[0]<kijunSen))) {Order = SIGNAL_CLOSESELL;Print("STR=12");}  ///||((Close[0]>SenkouSpanA)&&(Close[0]>SenkouSpanB))&& Close[0]>tenkanSen)  && Close[1]>tenkanSenHist)&&(Close[0]>tenkanSen)
            else if ((STR==13) && (Close[0]<kijunSen)){ Order = SIGNAL_CLOSESELL; Print("STR=13");}
            else if ((STR==14) && ((KijenCloseBull)||((Close[1]>kijunSenHist)&&(Close[0]>kijunSen)))) {Order = SIGNAL_CLOSESELL; Print("STR=14");}
            
              //if (KijunCrossBull) Order = SIGNAL_CLOSESELL; // Rule to EXIT a Short trade
            //+------------------------------------------------------------------+
            //| Signal End(Exit Sell)                                            |
            //+------------------------------------------------------------------+

            if (Order == SIGNAL_CLOSESELL) {
               Ticket2 = OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, DarkOrange);
               if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + " Close Sell");
               IsTrade = False;
               continue;
            }
            //Trailing stop
            if(UseTrailingStop && TrailingStop > 0) {                 
               if((OrderOpenPrice() - Ask) > (P * Point * TrailingStop)) {
                 if((OrderStopLoss() > (Ask + P * Point * TrailingStop)) || (OrderStopLoss() == 0)) {
                     Ticket2 = OrderModify(OrderTicket(), OrderOpenPrice(), Ask + P * Point * TrailingStop, OrderTakeProfit(), 0, DarkOrange);
                     continue;
                  }
               }
            }
         }
      }
   }

   //+------------------------------------------------------------------+
   //| Signal Begin(Entries)                                            |
   //+------------------------------------------------------------------+

  
   

    if ((( TenkenCrossKingunBull)&&(TenkenTrendBull || TenkenTrendZero) ))  {Order = SIGNAL_BUY; STR=1;UseStopLoss = False ;StopLoss = 20; UseTakeProfit = False;TakeProfit = 40;} //  (tenkensen Cross Kijunsen)
    else if (KumoBullCross && STR!=1) {Order = SIGNAL_BUY; STR=2;}                                                     ///  (Close Cross Kumo)
    else if (St4 && STR!=1 && STR!=2) {Order = SIGNAL_BUY;STR=3;}                                                                ////  (Close between Kijunsen and Tenkensen)
    else if (St5 && STR!=1 && STR!=2 && STR!=3) {Order = SIGNAL_BUY;STR=4;}                                                                ///// (Close Cross tenkensen and kijunsen)
  
 
   if (( TenkenCrossKingunBear)&&(TenkenTrendBear)) {Order = SIGNAL_SELL;STR=11;UseStopLoss = False ;StopLoss = 20; UseTakeProfit = False;TakeProfit = 40;} //  (tenkensen Cross Kijunsen)
   else if (KumoBearCross && STR!=11) {Order = SIGNAL_SELL;STR=12;}                               /// (Close Cross Kumo)
   else if (St3 && STR!=11 && STR!=12) {Order = SIGNAL_SELL;STR=13;}                                         ////  (Close between Kijunsen and Tenkensen)
   else if (St6 && STR!=11 && STR!=12 && STR!=13) {Order = SIGNAL_SELL; STR=14;}                                        ///// (Close Cross tenkensen and kijunsen)
  // Rule to ENTER a Short trade
   
   
   
   //+------------------------------------------------------------------+
   //| Signal End                                                       |
   //+------------------------------------------------------------------+

   //Buy
   if (Order == SIGNAL_BUY) {
      if(!IsTrade) {
         //Check free margin
         if (AccountFreeMargin() < (1000 * Lots)) {
            Print("We have no money. Free Margin = ", AccountFreeMargin());
            return(0);
         }

         if (UseStopLoss) StopLossLevel = Ask - StopLoss * Point * P; else StopLossLevel = 0.0;
         if (UseTakeProfit) TakeProfitLevel = Ask + TakeProfit * Point * P; else TakeProfitLevel = 0.0;

         Ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, StopLossLevel, TakeProfitLevel, "Buy(#" + MagicNumber + ")", MagicNumber, 0, DodgerBlue);
         if(Ticket > 0) {
            if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) {
				Print("BUY order opened : ", OrderOpenPrice());
                if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + " Open Buy");
			} else {
				Print("Error opening BUY order : ", GetLastError());
			}
         }
         return(0);
      }
   }

   //Sell
   if (Order == SIGNAL_SELL) {
      if(!IsTrade) {
         //Check free margin
         if (AccountFreeMargin() < (1000 * Lots)) {
            Print("We have no money. Free Margin = ", AccountFreeMargin());
            return(0);
         }

         if (UseStopLoss) StopLossLevel = Bid + StopLoss * Point * P; else StopLossLevel = 0.0;
         if (UseTakeProfit) TakeProfitLevel = Bid - TakeProfit * Point * P; else TakeProfitLevel = 0.0;

         Ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, StopLossLevel, TakeProfitLevel, "Sell(#" + MagicNumber + ")", MagicNumber, 0, DeepPink);
         if(Ticket > 0) {
            if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) {
				Print("SELL order opened : ", OrderOpenPrice());
                if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + " Open Sell");
			} else {
				Print("Error opening SELL order : ", GetLastError());
			}
         }
         return(0);
      }
   }

   return(0);
}

//+------------------------------------------------------------------+
