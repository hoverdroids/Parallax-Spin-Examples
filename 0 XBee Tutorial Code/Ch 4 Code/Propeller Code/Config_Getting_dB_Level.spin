{{
   ***************************************
   * Config_Getting_dB_Level             *
   ***************************************
   *  See end of file for terms of use.  *               
   ***************************************

   Demostrates receiving multiple decimal
   value with start delimiter


   *******************************************************
   * Martin Hebel, Electronic Systems Technologies, SIUC *
   * Version 1.0                                         *
   *******************************************************
     
}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  ' Set pins and Baud rate for XBee comms  
  XB_Rx     = 0              ' XBee Dout
  XB_Tx     = 1              ' XBee Din
  XB_Baud   = 9600

  ' Carriage return value
  CR = 13
     
OBJ
   XB    : "XBee_Object"

Pub  Start | DataIn, Val1,Val2
XB.start(XB_Rx, XB_Tx, 0, XB_Baud)   ' Initialize comms for XBee
XB.Delay(1000)                       ' One second delay 

' Configure XBee module
XB.Str(String("Configuring XBee...",13))
XB.AT_Init                           ' Configure for fast AT Command mode

XB.AT_Config(string("ATD5 4"))       ' Send AT command turn off Association LED
     
XB.str(string("Awaiting Data..."))   ' Notify base
XB.CR 

Repeat
  DataIn := XB.RxTime(100)         ' Wait for byte with timeout
  If DataIn == "!"                 ' Check if delimiter
    Val1 := XB.RxDecTime(3000)     ' Wait for 1st value with timeout
    Val2 := XB.RxDecTime(3000)     ' Wait for next value with timeout
    If Val2 <> -1                  ' If value not received value is -1
      XB.CR
      XB.Str(string(CR,"Value 1 = ")) ' Display remotely with string
      XB.Dec(Val1)                    ' Decimal value
      XB.Str(string(CR,"Value 2 = ")) ' Display remotely
      XB.Dec(Val2)                    ' Decimal value

      XB.RxFlush                      ' Clear buffer
      XB.AT_Config(string("ATDB"))    ' Request dB Level
      DataIn := XB.RxHexTime(200)     ' Accept returning hex value
      XB.Str(string(13,"dB level = "))' Display remotely
      XB.Dec(-DataIn)                 ' Value as negative decimal
      XB.CR
  Else
    XB.Tx(".")                     ' Send dot to show actively waiting
  
{{

┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}                           