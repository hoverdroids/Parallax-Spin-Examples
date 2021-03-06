{{
   ***************************************
   * Scheduled_Base                      *
   ***************************************
   *  See end of file for terms of use.  *               
   ***************************************

   Waits for and accepts incoming current data from
   remotes. Makes adjustments to remote parameters and
   sends new settings for LED and buzzer.
   
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


  CR = 13
     
OBJ
   XB    : "XBee_Object"
   PC    : "XBee_Object" ' Using XBee object on PC side for more versatility 

VAR
   Long Light, DataIn, DL_Addr, State, Freq
   
Pub  Start  
  XB.Delay(2000)
  PC.start(PC_Rx, PC_Tx, 0, PC_Baud) ' Initialize comms for PC
  PC.str(string("Configuring XBee...",CR)) 
  XB.start(XB_Rx, XB_Tx, 0, XB_Baud) ' Initialize comms for XBee
  XB.AT_Init                         ' Configure for fast Command Mode
  XB.AT_Config(string("ATMY 0"))     ' Set address of base (MY)

  PC.str(string(CR,CR,"*** Waiting for Data"))      
  repeat
    
    DataIn := XB.rx                  ' Wait for incoming byte character
    If DataIn == "C"                 ' If C, current update
       DL_Addr := XB.RxDecTime(500)  ' Accept remote address
       PC.str(string(CR,"     Update from remote address :"))
       PC.HEX(DL_Addr,2)
       State := XB.RxDecTime(500)    ' Accept LED state
       PC.str(string(CR,"     LED State:               "))
       PC.DEC(state)
       Freq := XB.RxDecTime(500)     ' Accept frequency
       PC.str(string(CR,"     Frequency:               "))
       PC.DEC(Freq)
       Light := XB.RxDecTime(500)    ' Accept light level
       PC.str(string(CR,"     Light Level:             "))
       PC.DEC(Light)
       PC.str(string(CR,"** Updating Remote **"))
       XB.AT_ConfigVal(string("ATDL"),DL_Addr)  ' Configure DL for remote
       Set_LED                       ' Go send LED update
       Set_Buzzer                    ' Go send Buzzer update
       PC.str(string(CR,CR,"*** Waiting for Data"))      
    else                             
       PC.tx(".")                    ' Non-C data 

Pub Set_LED 
  State += 100                                  ' Increase PWM state by 100
  if State > 1000                               ' limit 0 to 1000
    State := 0
  PC.str(string(CR,"     Setting LED to:          "))
  PC.Dec(State)                                 
  XB.Tx("L")                                    ' Send L + value
  XB.Dec(State)
  XB.CR
  
Pub Set_Buzzer
  Freq += 500                                   ' Increase buzzer freq by 500
  if Freq > 5000                                ' limit freq 0 to 5000
    Freq := 0
  PC.str(string(CR,"     Setting Frequency to:    "))
  PC.Dec(Freq)
  XB.Tx("B")                                    ' Send B + value
  XB.Dec(Freq)
  XB.CR

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
  