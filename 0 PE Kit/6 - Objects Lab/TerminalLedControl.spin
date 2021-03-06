''This code example is from Propeller Education Kit Labs: Fundamentals, v1.1.
''A .pdf copy of the book is available from www.parallax.com, and also through
''the Propeller Tool software's Help menu (v1.2.6 or newer).
''
{{
TerminalLedControl.spin

Enter LED states into Parallax Serial Terminal.  Propeller chip receives the states and
lights the corresponding LEDs.

  LED SCHEMATIC                
 ──────────────────────
       (all)          
       100 Ω  LED     
  P4 ──────────┐ 
                    │ 
  P5 ──────────┫ 
                    │ 
  P6 ──────────┫ 
                    │ 
  P7 ──────────┫ 
                    │ 
  P8 ──────────┫ 
                    │ 
  P9 ──────────┫ 
                     
                   GND
 ──────────────────────
}}

CON
   
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
   

OBJ
   
  Debug : "FullDuplexSerialPlus"
   
   
PUB TerminalLedControl

  ''Set/clear I/O pin output states based binary patterns 
  ''entered into Parallax Serial Terminal.

  Debug.start(31, 30, 0, 57600)
  waitcnt(clkfreq*2 + cnt)
  Debug.tx(Debug#CLS)
  dira[4..9]~~

  repeat

     Debug.Str(String("Enter 6-bit binary pattern: "))
     outa[4..9] := Debug.getBin