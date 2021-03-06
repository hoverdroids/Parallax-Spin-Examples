{{
   ***************************************
   * Serial_Pass_Through                 *
   ***************************************
   *  See end of file for terms of use.  *               
   ***************************************

   Provides serial pass through for XBee (or other devices)
   from the PC to the device via the Propeller. Baud rate
   may differ between units though FullDuplexSerial can
   buffer only 16 bytes.
                                                          
   *******************************************************
   * Martin Hebel, Electronic Systems Technologies, SIUC *
   * Version 1.0                                         *
   *******************************************************
     
}}                    

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  ' Set pins and Baud rate for XBee comms  
  XB_Rx     = 0                 ' XBee DOUT
  XB_Tx     = 1                 ' XBee Din     
  XB_Baud   = 9600

  ' Set pins and baud rate for PC comms 
  PC_Rx     = 31  
  PC_Tx     = 30
  PC_Baud   = 9600      
   
Var
  long stack[50]                ' stack space for second cog
                                                                       
OBJ
  PC    : "FullDuplexSerial"  
  XB    : "FullDuplexSerial"

Pub  Start 
  
  PC.start(PC_Rx, PC_Tx, 0, PC_Baud) ' Initialize comms for PC  
  XB.start(XB_Rx, XB_Tx, 0, XB_Baud) ' Initialize comms for XBee  
  cognew(XB_to_PC,@stack)       ' Start cog for XBee--> PC comms

  PC.rxFlush                    ' Empty buffer for data from PC
  repeat                   
    XB.tx(PC.rx)                ' Accept data from PC and send to XBee
       
Pub XB_to_PC

  XB.rxFlush                    ' Empty buffer for data from XB
  repeat                 
    PC.tx(XB.rx)                ' Accept data from XBee and send to PC   

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