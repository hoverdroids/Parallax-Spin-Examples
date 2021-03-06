''This code example is from Propeller Education Kit Labs: Fundamentals, v1.1.
''A .pdf copy of the book is available from www.parallax.com, and also through
''the Propeller Tool software's Help menu (v1.2.6 or newer).
''
''SquareWaveTest.spin
''Send 2093 Hz square wave to P27 for 1 s with counter module.

CON
   
  _clkmode = xtal1 + pll16x            ' Set up clkfreq = 80 MHz.
  _xinfreq = 5_000_000

PUB TestFrequency 

  'Configure ctra module 
  ctra[30..26] := %00100               ' Set ctra for "NCO single-ended"
  ctra[5..0] := 27                     ' Set APIN to P27
  frqa := 112_367                      ' Set frqa for 2093 Hz (C7 note) using:
                                       ' FRQA/B = frequency × (232 ÷ clkfreq) 
  'Broadcast the signal for 1 s
  dira[27]~~                           ' Set P27 to output
  waitcnt(clkfreq + cnt)               ' Wait for tone to play for 1 s