''This code example is from Propeller Education Kit Labs: Fundamentals, v1.1.
''A .pdf copy of the book is available from www.parallax.com, and also through
''the Propeller Tool software's Help menu (v1.2.6 or newer).
''
{{
TestDualPWM(Exercise 12).spin
Demonstrates using two counter modules to send a dual PWM signal.
The cycle time is the same for both signals, but the high times are independent of 
each other.
}}

CON
   
  _clkmode = xtal1 + pll16x                  ' System clock → 80 MHz
  _xinfreq = 5_000_000

PUB TestPwm | tc, tHa, tHb, t, us            ' <- Add us     

  us := clkfreq/1_000_000                    ' <- Add

  ctra[30..26] := ctrb[30..26] := %00100     ' Counters A and B → NCO single-ended
  ctra[5..0] := 4                            ' Set pins for counters to control
  ctrb[5..0] := 6       
  frqa := frqb := 1                          ' Add 1 to phs with each clock tick
                         
  dira[4] := dira[6] := 1                    ' Set I/O pins to output

  tC := 20_000 * us                          ' <- Change Set up cycle time
  tHa := 700 * us                            ' <- Change Set up high times 
  tHb := 2200 * us                           ' <- Change

  t := cnt                                   ' Mark current time.
  
  repeat tHa from (700 * us) to (2200 * us)  ' <- Change Repeat PWM signal
    phsa := -tHa                             ' Define and start the A pulse
    phsb := -tHb                             ' Define and start the B pulse
    t += tC                                  ' Calculate next cycle repeat
    waitcnt(t)                               ' Wait for next cycle