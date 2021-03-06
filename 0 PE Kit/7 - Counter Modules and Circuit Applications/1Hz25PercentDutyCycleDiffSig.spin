''This code example is from Propeller Education Kit Labs: Fundamentals, v1.1.
''A .pdf copy of the book is available from www.parallax.com, and also through
''the Propeller Tool software's Help menu (v1.2.6 or newer).
''
''Differential version of 1Hz25PercentDutyCycle.spin

CON
   
  _clkmode = xtal1 + pll16x                       ' clock → 80 MHz
  _xinfreq = 5_000_000

PUB TestPwm | tc, tHa, t

  ctra[30..26] := %00101                     ' Counter A → NCO (differential)
  ctra[5..0] := 4                            ' Select I/O pins
  ctra[14..9] := 5
  frqa := 1                                  ' Add 1 to phs with each clock tick
                         
  dira[4..5]~~                               ' Set both differential pins to output

  ' The rest is the same as 1Hz25PercentDutyCycle.spin

  tC := clkfreq                              ' Set up cycle and high times
  tHa := clkfreq/4
  t := cnt                                   ' Mark counter time
  
  repeat                                     ' Repeat PWM signal
    phsa := -tHa                             ' Set up the pulse
    t += tC                                  ' Calculate next cycle repeat
    waitcnt(t)                               ' Wait for next cycle