''This code example is from Propeller Education Kit Labs: Fundamentals, v1.2.
''A .pdf copy of the book is available from www.parallax.com, and also through
''the Propeller Tool software's Help menu (v1.2.6 or newer).
''
{{
TestDualPwmWithProbes.spin
Demonstrates how to use an object that uses counters in another cog to measure (probe) I/O
pin activity caused by the counters in this cog.
}}

CON
   
  _clkmode = xtal1 + pll16x                  ' System clock → 80 MHz
  _xinfreq = 5_000_000

OBJ

  pst   : "Parallax Serial Terminal"
  probe : "MonitorPWM"

PUB TestPwm | tc, tHa, tHb, t, tHprobe, tLprobe, pulseCnt 

  ' Start MonitorServoControlSignal.
  probe.start(8, @tHprobe, @tLprobe, @pulseCnt)


  'Start Parallax Serial Terminal.
  pst.Start(115_200)
  pst.Str(String("Cycle Times", pst#NL, "(12.5 ns clock ticks)", pst#NL))

  pst.Str(String("tH = ", pst#NL))
  pst.Str(String("tL = ", pst#NL))
  pst.Str(String("reps = "))

  ctra[30..26] := ctrb[30..26] := %00100     ' Counters A and B → NCO single-ended
  ctra[5..0] := 4                            ' Set pins for counters to control
  ctrb[5..0] := 6       
  frqa := frqb := 1                          ' Add 1 to phs with each clock tick
                         
  dira[4] := dira[6] := 1                    ' Set I/O pins to output

  tC := clkfreq                              ' Set up cycle time
  tHa := clkfreq/2                           ' Set up high times for both signals
  tHb := clkfreq/5
  t := cnt                                   ' Mark current time.
  
  repeat                                     ' Repeat PWM signal
    phsa := -tHa                             ' Define and start the A pulse
    phsb := -tHb                             ' Define and start the B pulse
    t += tC                                  ' Calculate next cycle repeat

    ' Display probe information
    pst.Str(String(pst#CE, pst#PC, 5, 2))
    pst.Dec(tHprobe)
    pst.Str(String(pst#CE, pst#PC, 5, 3))
    pst.Dec(tLprobe)
    pst.Str(String(pst#CE, pst#PC, 7, 4))
    pst.Dec(pulseCnt)
     
    waitcnt(t)                               ' Wait for next cycle

