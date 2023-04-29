//+------------------------------------------------------------------+
//|                                                 bar breakout.mq5 |
//|                                                     yin zhanpeng |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "yin zhanpeng"
#property version   "2.00"

#include <Trade/Trade.mqh> 
CTrade trade;


int handle_ma_fast;
int handle_ma_slow;


int lastbreakout = 0;

input double lot = 0.01; // Lot Size
input int fastma = 8;    // Fast EMA
input int slowma = 50;   // Slow EMA
input ENUM_MA_METHOD mode = MODE_EMA;


int OnInit()
  {
   handle_ma_fast = iMA(_Symbol,PERIOD_CURRENT,fastma, 0, mode, PRICE_CLOSE);
   handle_ma_slow = iMA(_Symbol,PERIOD_CURRENT,slowma, 0, mode, PRICE_CLOSE);
   
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {

   
   
  }

void OnTick()
  {


   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   bid = NormalizeDouble(bid, _Digits);
   
   double ma_trendfast[],ma_trendslow[];
   CopyBuffer(handle_ma_fast, 0, 0, 1, ma_trendfast);
   CopyBuffer(handle_ma_slow, 0, 0, 1, ma_trendslow);

   int trend_direction = 0;
   
   if (ma_trendfast[0] > ma_trendslow[0] && bid > ma_trendfast[0])
   {
      trend_direction = 1;   // buy
   }
   else if (ma_trendfast[0] < ma_trendslow[0] && bid < ma_trendfast[0])
   {
      trend_direction = -1;  // sell
   }



   double high = iHigh(_Symbol, PERIOD_CURRENT, 1);
   high = NormalizeDouble(high,_Digits);
   double low = iLow(_Symbol, PERIOD_CURRENT, 1);
   low = NormalizeDouble(low,_Digits);

   
   if(trend_direction == 1 && lastbreakout <= 0 && bid > high)
     {
      Print(__FUNCTION__, "> Buy Signal...");
      lastbreakout = 1;
      
      
      trade.Buy(lot, _Symbol,0,low);
      //trade.Sell(lot, _Symbol,0,low);
      
     }
    else if(trend_direction == -1 && lastbreakout >= 0 && bid < low)
     {
      Print(__FUNCTION__, "< Sell Signal...");
      lastbreakout = -1;
            
      trade.Sell(lot, _Symbol,0,high);
      //trade.Buy(lot, _Symbol,0,high);
    
    
     }

   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong posticket = PositionGetTicket(i);
      CPositionInfo pos;
      if(pos.SelectByTicket(posticket))
        {
         if(pos.PositionType() == POSITION_TYPE_BUY)
           {
            if(low > pos.StopLoss())
              {
               trade.PositionModify(pos.Ticket(), low, pos.TakeProfit());
              }
           }else if(pos.PositionType() == POSITION_TYPE_SELL)
                   {
                    if(high < pos.StopLoss())
                     {
                        trade.PositionModify(pos.Ticket(), high, pos.TakeProfit());
                     }
                   }
        }
     }



   
   Comment("\nHigh", high,
           "\nLow", low,
           "\nBid", bid,
           "\nTrend signal",trend_direction
          );
  }

