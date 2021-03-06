''This code example is from Propeller Education Kit Labs: Fundamentals, v1.1.
''A .pdf copy of the book is available from www.parallax.com, and also through
''the Propeller Tool software's Help menu (v1.2.6 or newer).
''
''TestDualDAC.spin
''Menu driver user tests for DualDac.spin 

CON
   
  _clkmode = xtal1 + pll16x                  ' System clock → 80 MHz
  _xinfreq = 5_000_000

  ' Parallax Serial Terminal constants
  CLS = 16, CR = 13, CLREOL = 11, CRSRXY = 2, BKSPC = 8, CLRDN = 12

OBJ

  debug : "FullDuplexSerialPlus"
  dac   : "DualDAC"

PUB TestPwm | channel, dacPin, resolution, ch[2], menu, choice

  debug.start(31, 30, 0, 57600)
  waitcnt(clkfreq * 2 + cnt)
  debug.str(@_Menu)

  dac.start

  repeat
  
    debug.tx(">")
    case menu := debug.rx
      "C", "c":
         debug.str(@_Channel)
         channel := debug.getdec
         debug.str(@_Pin)
         dacPin := debug.getdec
         debug.str(@_Resolution)
         resolution := debug.getdec
         dac.Config(channel, dacPin, resolution, @ch[channel])
      "S", "s":
         debug.str(@_Channel)
         channel := debug.getdec
         debug.str(@_Value)
         ch[channel] := debug.getdec
      "U", "u":
         debug.str(@_Update)
         case choice := debug.rx
            "P", "p":
               debug.str(@_Channel)
               channel := debug.getdec
               debug.str(@_Pin)
               dacPin := debug.getdec
               dac.update(channel, 0, dacPin)
            "B", "b":
               debug.str(@_Channel)
               channel := debug.getdec
               debug.str(@_Resolution)
               resolution := debug.getdec
               dac.update(channel, 1, resolution)
      "R", "r":
         debug.str(@_Channel)
         channel := debug.getdec
         dac.Remove(channel)
    debug.str(String(CRSRXY, 1,4, BKSPC, CLRDN))

DAT
_Menu       byte CLS, "C = Configure DAC", CR, "S = Set DAC Output", CR
            byte "U = Update DAC Config", CR, "R = Remove DAC", CR, 0
_Channel    byte CR, "Channel (0/1) > ", 0
_Pin        byte "Pin > ", 0
_Resolution byte "Resolution (bits) > ", 0
_Value      byte "Value > ", 0
_Update     byte "Update Choices:", CR, "P = DAC Pin", CR,"B = Bits (resolution)" 
            byte CR, 0