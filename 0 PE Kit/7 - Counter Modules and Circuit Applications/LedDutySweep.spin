''This code example is from Propeller Education Kit Labs: Fundamentals, v1.1.
''A .pdf copy of the book is available from www.parallax.com, and also through
''the Propeller Tool software's Help menu (v1.2.6 or newer).
''
''LedDutySweep.spin
''Cycle P4 LED from off, gradually brighter, full brightness.


CON

  scale = 16_777_216                         ' 2³²÷ 256
  

PUB TestDuty | pin, duty, mode

  'Configure counter module.

  ctra[30..26] := %00110                     ' Set ctra to DUTY mode
  ctra[5..0] := 4                            ' Set ctra's APIN
  frqa := duty * scale                       ' Set frqa register

  'Use counter to take LED from off to gradually brighter, repeating at 2 Hz.

  dira[4]~~                                  ' Set P5 to output

  repeat                                     ' Repeat indefinitely
    repeat duty from 0 to 255                ' Sweep duty from 0 to 255
      frqa := duty * scale                   ' Update frqa register
      waitcnt(clkfreq/128 + cnt)             ' Delay for 1/128th s
      