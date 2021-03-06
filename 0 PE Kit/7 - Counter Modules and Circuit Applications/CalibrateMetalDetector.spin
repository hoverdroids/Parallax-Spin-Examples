''This code example is from Propeller Education Kit Labs: Fundamentals, v1.1.
''A .pdf copy of the book is available from www.parallax.com, and also through
''the Propeller Tool software's Help menu (v1.2.6 or newer).
''
'' CalibrateMetalDetector.spin

CON
   
  _clkmode = xtal1 + pll16x            ' Set up 80 MHz internal clock
  _xinfreq = 5_000_000

  CLS = 16, CR = 13

OBJ                                   
   
  Debug   : "FullDuplexSerialPlus"
  frq     : "SquareWave"


PUB Init | count, f, fstart, fstep, c

  'Start FullDuplexSerialPlus
  Debug.start(31, 30, 0, 57600)
  waitcnt(clkfreq*2 + cnt)
  Debug.tx(CLS)

  'Configure ctra module for 50 MHz square wave
  ctra[30..26] := %00010
  ctra[25..23] := %110            
  ctra[5..0] := 15                    
  frq.Freq(0, 15, 50_000_000)                         
  dira[15]~~
  
  'Configure ctrb module for negative edge counting
  ctrb[30..26] := %01000               
  ctrb[5..0] := 13
  frqb := 1

  c := "S"

  repeat until c == "Q" or c == "q"

    case c
      "S", "s":
        Debug.Str(String("Starting Frequency: "))
        f := Debug.GetDec
        Debug.Str(String("Step size: "))
        fstep := Debug.GetDec
        Debug.tx(String(CR))
         
    case c
      "S", "s", 13, 10, "M", "m":
        repeat 22
          frq.Freq(0, 15, f)   
          count := phsb
          waitcnt(clkfreq/10000 + cnt)                      
          count := phsb - count
          Debug.Str(String(CR, "Freq = "))
          Debug.Dec(f)
          Debug.Str(String("  count = "))
          Debug.Dec(count)
          waitcnt(clkfreq/20 + cnt)
          f += fstep
         
        Debug.str(String(CR,"Enter->more, Q->Quit, S->Start over, R->repeat: "))
        c := Debug.rx
        Debug.tx(CR)

      "R", "r":
        f -= (22 * fstep)
        c := "m"
     
      "Q", "q": quit

  Debug.str(String(10, 13, "Bye!"))                  