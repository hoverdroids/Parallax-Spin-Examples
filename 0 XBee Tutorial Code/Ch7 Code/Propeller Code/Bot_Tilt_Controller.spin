{{
   ***************************************
   * Bot_Tilt_Controller for networked   *
   * bot example.                        *
   * Martin Hebel                        *
   * Version 1.0     Copyright 2009      *
   ***************************************
   *  See end of file for terms of use.  *               
   ***************************************

   Reads the Melexis 2125 accelerometer,
   sends drive information to bot at address 1.
   Accepts range data from bot for Demoboard LED.
    
}}


CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  ' Set pins and Baud rate for XBee comms
  XB_Rx     = 7       ' XBee Dout
  XB_Tx     = 6       ' XBee Din
  XB_Baud   = 9600
   
  MY_Addr  = 0
  DL_Addr  = 1        ' bot address

  ' momentary pushbutton
  PB       = 2

  'Constants used by the Accelerometer Object
  Xout_pin    =  0    'Propeller pin MX2125 X 
  Yout_pin    =  1    'Propeller pin MX2125 Y 
  
VAR

  long  Range, Theta, dataIn, Value, IO,Forward, Turn
  long  Left_Dr, Right_Dr, Pan_Dr, offset, scale
  byte  Stack[100]
    
OBJ

  XB    : "XBee_Object"
  accel : "MXD2125"
  
PUB Start

  ' Configure XBee
  XB.start(XB_Rx, XB_Tx, 0, XB_Baud)   ' Initialize comms for XBee
  XB.AT_Init                           ' Fast AT updates
  XB.AT_ConfigVal(string("ATMY"), MY_Addr)   
  XB.AT_ConfigVal(string("ATDL"), DL_Addr)
  
  offset := 90 * (clkfreq / 200)  ' offset for sensor data conversion
  scale  := clkfreq / 800         ' scale for sensor data conversion
  accel.start(Xout_pin,Yout_pin)  ' start accelerometer

  cognew(acceptData,@Stack)       ' start cog to accept incoming data
     SendControl
     
Pub SendControl
  repeat
    if ina[PB] == 1                    ' if button pressed
          XB.str(string("pppppp"))    ' send handful of p's for pan map
          XB.delay(500)
    else
        ' Read and calulate -90 to 90 degree for forward
        Forward := (accel.x*90-offset)/scale * -1
        
        ' Read and calulate -90 to 90 degree for turn    
        Turn := (accel.y*90-offset)/scale

        ' scale and mix channels for drive, 1500 = stopped
        Left_Dr := 1500 + Forward * 3 + Turn * 3
        Right_Dr := 1500 - Forward * 3 + Turn * 3

        ' send drive data(d) to bot
        XB.tx("d")
        XB.DEC(right_Dr)
        XB.tx(13)
        XB.DEC(left_Dr)
        XB.tx(13)
        
    XB.delay(100)

Pub AcceptData
  '' accepts incoming data from bot to light Demo board LED's
  '' based on PING distance
  
    dira[16..23]~~                     ' set LEDs as outputs
    repeat
      DataIn := XB.Rx                  ' read incoming data
      if DataIn == "u" or DataIn == "m"  ' if update (u)or mapping (m)...
        Range := XB.RxDecTime(100)     ' get range
        if Range < 800                                                    
          ' if less the 0.8 meters (1 LED per 0.1m or 100mm)
          ' Light LEDs by shifting 1's  by scaled range
          outa[16..23] := %11111111 << 8  >> (8 - range/100)
        else                           ' if > 0.8m, turn off LEDs
          outa[16..23]~

      XB.rxFlush

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