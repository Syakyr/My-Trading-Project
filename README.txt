//+------------------------------------------------------------------+
//|                                        The Road to the Champions |
//|                                                   Copyright 2016 |
//|                                                         Hitlaris |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Abstract                                                         |
//+------------------------------------------------------------------+

There are many trading strategies that are shared in the Internet. Of
which, none has been as comprehensive as having four aspects towards 
trading. I have taken the task to automate as much as possible with 
regards to this philosophy of trading to see how much I have learnt 
since March 2016 in the arts and science of algorithmic trading, and 
how far I can build a robust structure for a more comfortable trading 
experience, as well as more time for experience more things that life 
has to offer.

These four aspects are essential for a low-risk, high-reward trading 
system, and they are: 
   - Fundamental Analysis
   - Technical Analysis
   - Sentimental Analysis
   - Risk Management

The fundamental aspect covers the economic indicators as well as the 
monetary policy minutes of the major central banks. The technical as-
pect covers the entry and exit of trades, using mean reversion (MA, 
SS&DD, S&R), momentum (RSI, Stochastics, MACD, Fractals), Fibonacci 
(Elliot wave, retracement, Harmonic) and price action (candlestick 
patterns) techniques. The sentimental aspect covers volatility (VIX), 
market movers' sentiments (COT), correlation (CADOIL, AUDXAU, NZDMilk)
and risk sentiments (risk on AUD/NZD, risk off JPY). And the most im-
portant aspect, risk management, covers the calculations of the lot-
size together with the optimal Kelly size, possible with the use of 
ATR Multiplier and (Anti)-Martingale strategy.

//+------------------------------------------------------------------+
//| To dos                                                           |
//+------------------------------------------------------------------+

1. Use fundamentals and sntiments to build directional bias, and cal-
   culate the errors of significance that shows that the bias is like-
   ly is true
                                   ||
                                  \  /
                                   \/

                            "Playing Field"

                                   ||
                                  \  /
                                   \/

                        Conditions for "winning"

   //+------------------+
   //| Questions to Ask |
   //+------------------+
   - How to calculate errors of significance?

2. Use economic indicator's past data to optimise type of distribution
   used, plot against correlation of close prices - overlay with sen-
   timent data in #1 above.
                                   ||
                                  \  /
                                   \/

                          "Buffs and Debuffs"

   //+------------------+
   //| Questions to Ask |
   //+------------------+
   - What kind of distribution to use?
   - Uniform or mixed distribution types for each indicator?
   - How to weight the more recent indicator value?
   - Arithmetic or geometric values/correlations?

3. Consolidate technical signals from Investing.com and ascertain in 
   the usefulness of determining directional bias

   //+------------------+
   //| Questions to Ask |
   //+------------------+
   - What is the "winning" rate in using the signals as a scoring 
     sheet?
   - What is the error of significance that the signals ar in diffe-
     rent market conditions?

4. Check the usefulness of the correlation of different pairs calcu-
   lated in myFXbook

   //+------------------+
   //| Questions to Ask |
   //+------------------+
   - How about correlation in the geometrical sense?