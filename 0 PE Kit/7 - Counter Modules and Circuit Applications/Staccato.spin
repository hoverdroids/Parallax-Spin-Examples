''This code example is from Propeller Education Kit Labs: Fundamentals, v1.1.
''A .pdf copy of the book is available from www.parallax.com, and also through
''the Propeller Tool software's Help menu (v1.2.6 or newer).
''
''Staccato.spin
''Send 2093 Hz beeps in rapid succession (15 Hz for 1 s).  

CON
   
  _clkmode = xtal1 + pll16x                  ' System clock → 80 MHz
  _xinfreq = 5_000_000

PUB TestFrequency 

  'Configure ctra module 
  ctra[30..26] := %00100                     ' Set ctra for "NCO single-ended"
  ctra[5..0] := 27                           ' Set APIN to P27
  frqa := 112_367                            ' Set frqa for 2093 Hz (C7 note):

  'Ten beeps on/off cycles in 1 second.
  repeat 30
    !dira[27]                                 ' Set P27 to output
    waitcnt(clkfreq/30 + cnt)                 ' Wait for tone to play for 1 s

  'Program ends, which also stops the counter module.