{{
   ***************************************
   * Scheduled_Remote                    *
   ***************************************
   *  See end of file for terms of use.  *               
   ***************************************

   Periodically sends values of address, LED state,
   Buzzer frequency and ligth level to base. Accepts returning
   values to modify LED and Buzzer parameters.

   The accepting routine is run in a seperate cog
   too allow accepting new parameters at anytime.
   
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

  LED       = 7
  PhotoT    = 6
  Buzzer    = 4
  
  MY_Addr   = 2    ' ***** Set address of node

  CR = 13          ' Carriage Return
     
OBJ
   XB    : "XBee_Object"
  

VAR
   Long stack[100], State, FreqIn,Light, LastFreq
   
Pub  Start | DataIn 
  XB.start(XB_Rx, XB_Tx, 0, XB_Baud) ' Initialize comms for XBee
  XB.AT_Init                         ' Set for fast Command mode
  XB.AT_ConfigVal(string("ATMY "),MY_Addr) ' Set remote's address
  XB.AT_Config(string("ATDL 0"))
                                     ' Set base address (destination)
  cognew(AcceptData,@stack)
   
  XB.Delay(2000)
   
  repeat
     XB.tx("C")                      ' Send C for current data
     XB.Dec(MY_Addr)                 ' Send remote's address
     XB.CR
     XB.Dec(State)                   ' Send state of LED PWM
     XB.CR
     XB.Dec(FreqIn)                  ' Send Frequency of buzzer
     XB.CR
     Light := RCTime(PhotoT)         ' Send Light level
     XB.Dec(Light)
     XB.CR
     XB.Delay(5000)                  ' Wait 5 seconds before next update
   
Pub AcceptData| DataIn
' Accept incoming settings

  XB.RxFlush                          ' Ensure buffer empty
  repeat
     DataIn := XB.Rx                  ' Accept incoming byte character
     case DataIn
       "L": DataIn := XB.RxDecTime(500) ' If L, accept data for LED
            if DataIn <> -1             ' Ensure not timeout value, -1
              State := DataIn           ' Accept state
              PWM_Set(LED,DataIn)       ' Set LED State
     
   
       "B": DataIn := XB.RxDecTime(500) ' If B, buzzer data
            if DataIn <> -1             ' Ensure not timeout value, -1
              FreqIn := DataIn          ' Accept data for Frequency
              Freqout_Set(Buzzer,DataIn)' Set buzzer Frequency
           

Pub RCTime(pin) | count               ' Perform RC Time         
  dira[pin]~~                         ' Set pin output          
  outa[pin]~~                         ' Set pin high            
  XB.Delay(10)                        ' Allow cap to charge     
  Count := cnt                        ' Get initial count       
  dira[pin]~                          ' Set pin as input        
  repeat                              ' Wait for pin to go low  
  until ina[pin] == 0                                           
  Count := (cnt - Count)              ' Get exit count          
  return Count                        ' Calculate difference    


PRI Freqout_Set(pin, freq) | temp, ch
' Configures cog counter to control frequency
' Adapted from Andy Lindsay's work

  ch := 1                       ' Set Channel of counter
  if Freq == LastFreq        ' If same Freq, do not adjust
    return
   
  LastFreq := Freq
   
  if freq == 0                ' freq = 0 turns off square wave
     waitpeq(0, |< pin, 0)    ' Wait for low signal
     dira[pin]~ 
     if ch==0
       ctra := 0              ' Set CTRA/B to 0
     else                     
       ctrb := 0              ' Set CTRA/B to 0
   
       
  temp := pin                  ' CTRA/B[8..0] := pin
  temp += (%00100 << 26)       ' CTRA/B[30..26] := %00100
  if ch==0 
    ctra := temp               ' Copy temp to CTRA/B
    frqa := calcFrq(freq)      ' Set FRQA/B
    phsa := 0                  ' Clear PHSA/B (start cycle low)
  else
    ctrb := temp               ' Copy temp to CTRA/B
    frqb := calcFrq(freq)      ' Set FRQA/B
    phsb := 0                  ' Clear PHSA/B (start cycle low)
  dira[pin]~~                  ' Make pin output
  result := cnt                ' Return the start time
   

PRI CalcFrq(freq)

' Solve FRQA/B = frequency * (2^32) / clkfreq with binary long division 
' Adapted from Andy Lindsay's work  

  repeat 33                                    
    result <<= 1
    if freq => clkfreq
      freq -= clkfreq
      result++        
    freq <<= 1
    
Pub PWM_Set(Pin, Duty) | Scale, Resolution
' Uses Cog Counter to produce PWM
' Adapted from Andy Linsday's work

  Resolution := 10
  if duty == 0                    ' freq = 0 turns off square wave
     ctra := 0                    ' Set CTRA/B to 0
     dira[pin]~                   ' Make pin input
  else
     Scale := 2_147_483_647 / (1<< (Resolution-1))  ' Calculate scale
      ctra[30..26] := %00110      ' Set ctra to DUTY mode
      ctra[5..0] := pin           ' Set ctra's APIN
      frqa := duty * scale        ' Set frqa register
      dira[pin]~~                 ' set direction

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