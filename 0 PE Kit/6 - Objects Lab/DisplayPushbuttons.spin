''This code example is from Propeller Education Kit Labs: Fundamentals, v1.1.
''A .pdf copy of the book is available from www.parallax.com, and also through
''the Propeller Tool software's Help menu (v1.2.6 or newer).
''
{{
DisplayPushbuttons.spin
Display pushbutton states with Parallax Serial Terminal.

Pushbuttons                                            
────────────────────────────────────────────────────────── 
     3.3 V               3.3 V               3.3 V         
                                                        
       │                   │                   │           
      ┤Pushbutton        ┤Pushbutton        ┤Pushbutton 
       │                   │                   │           
P21 ──┫            P22 ──┫            P23 ──┫           
       │                   │                   │           
        10 kΩ              10 kΩ              10 kΩ     
       │                   │                   │           
                                                        
      GND                 GND                 GND          
──────────────────────────────────────────────────────────
}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ
  Debug: "FullDuplexSerialPlus"  
   
PUB TerminalPushbuttonDisplay

  ''Read P23 through P21 pushbutton states and display with Parallax Serial Terminal.
 
  Debug.start(31, 30, 0, 57600)
  waitcnt(clkfreq*2 + cnt)
  Debug.tx(Debug#CLS)
  Debug.str(String("Pushbutton States", Debug#CR))
  Debug.str(String("-----------------", Debug#CR))

  repeat
    Debug.tx(Debug#CRSRX)
    Debug.tx(0)
    Debug.Bin(ina[23..21], 3)
    waitcnt(clkfreq/100 + cnt)