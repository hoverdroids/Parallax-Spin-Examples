''This code example is from Propeller Education Kit Labs: Fundamentals, v1.2.
''A .pdf copy of the book is available from www.parallax.com, and also through
''the Propeller Tool software's Help menu (v1.2.6 or newer).
''
''TestDualDAC.spin
''Menu driver user tests for DualDac.spin 

CON
   
  _clkmode = xtal1 + pll16x                  ' System clock → 80 MHz
  _xinfreq = 5_000_000

OBJ

  pst   : "Parallax Serial Terminal"
  dac   : "DualDAC"

PUB TestPwm | channel, dacPin, resolution, ch[2], menu, choice

  pst.start(115_200)
  pst.Str(@_Menu)

  dac.start

  repeat
  
    pst.Char(">")
    case menu := pst.CharIn
      "C", "c":
         pst.Str(@_Channel)
         channel := pst.DecIn
         pst.Str(@_Pin)
         dacPin := pst.DecIn
         pst.Str(@_Resolution)
         resolution := pst.DecIn
         dac.Config(channel, dacPin, resolution, @ch[channel])
      "S", "s":
         pst.Str(@_Channel)
         channel := pst.DecIn
         pst.Str(@_Value)
         ch[channel] := pst.DecIn
      "U", "u":
         pst.Str(@_Update)
         case choice := pst.CharIn
            "P", "p":
               pst.Str(@_Channel)
               channel := pst.DecIn
               pst.Str(@_Pin)
               dacPin := pst.DecIn
               dac.update(channel, 0, dacPin)
            "B", "b":
               pst.Str(@_Channel)
               channel := pst.DecIn
               pst.Str(@_Resolution)
               resolution := pst.DecIn
               dac.update(channel, 1, resolution)
      "R", "r":
         pst.Str(@_Channel)
         channel := pst.DecIn
         dac.Remove(channel)
    pst.str(String(pst#PC, 1,4, pst#BS, pst#CB))

DAT
_Menu       byte pst#CS, "C = Configure DAC", pst#NL, "S = Set DAC Output", pst#NL
            byte "U = Update DAC Config", pst#NL, "R = Remove DAC", pst#NL, 0
_Channel    byte pst#NL, "Channel (0/1) > ", 0
_Pin        byte "Pin > ", 0
_Resolution byte "Resolution (bits) > ", 0
_Value      byte "Value > ", 0
_Update     byte "Update Choices:", pst#NL, "P = DAC Pin", pst#NL,"B = Bits "
            byte "(resolution)", pst#NL, 0