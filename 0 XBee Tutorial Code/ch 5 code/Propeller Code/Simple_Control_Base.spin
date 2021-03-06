{{
   ***************************************
   * Simple_Control_Base                 *
   ***************************************
   *  See end of file for terms of use.  *               
   ***************************************

   Sends 2 decimal value to control remote buzzer
   and LED. Pressing button will ramp up values,
   releasing button will ramp down values
   
   *******************************************************
   * Martin Hebel, Electronic Systems Technologies, SIUC *
   * Version 1.0                                         *
   *******************************************************
     
}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  ' Set pins and Baud rate for XBee comms  
  XB_Rx     = 0    ' XBee DOUT
  XB_Tx     = 1    ' XBee DIN
  XB_Baud   = 9600 ' XBee Baud Rate

  ' Set pins and baud rate for PC comms 
  PC_Rx     = 31    
  PC_Tx     = 30    
  PC_Baud   = 9600    

  PB        = 7     ' Pushbutton
  
  CR = 13           ' Carriage return
     
OBJ
   XB    : "XBee_Object"

   
Pub  Start | State, Freq 
  XB.start(XB_Rx, XB_Tx, 0, XB_Baud) ' Initialize comms for XBee
  State := 0                         ' Initial state and frequency
  Freq  := 0
  
  repeat
    if ina[PB] == 1                  ' If button pressed,
      Freq := Freq + 100 <# 5000     ' increase freq to 5000 max
      State := State + 10 <# 1020    ' increase state to 1020 max
    else                             ' If released,
      Freq := Freq - 100 #> 0        ' decrease freq to 0 min
      State := State - 10 #> 0       ' decrease state to 0 min

    XB.Tx("!")                       ' Send start delimiter
    XB.Dec(State)                    ' Send decimal value of LED state + CR
    XB.CR
    XB.Dec(Freq)                     ' Send decimal value of Freq + CR
    XB.CR
    XB.Delay(100)                    ' Short delay before repeat
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
  