{{
OBEX LISTING:
  http://obex.parallax.com/object/700

  Includes Spin-based and PASM-based open-drain and push-pull drivers, with methods for reading and writing any number of bytes, words, and longs in big-endian or little-endian format.  All drivers tested with the 24LC256 EEPROM, DS1307 real time clock, MMA7455L 3-axis accelerometer, L3G4200D gyroscope module, MS5607 altimeter module, and BMP085 pressure sensor.  Includes a demo programs for each.

  Also includes a polling routine that displays the device address and name of everything on the I2C bus.

  Also includes a slave object that runs in a PASM cog with a Spin handler, and provides 32 byte-sized registers for a master running on another device to write to and read from.  Tested okay up to 1Mbps (max speed of my PASM push-pull object).  Includes demo for the slave object.

  Newly added multi-master object that can share the bus with other masters, provided of course that the other masters also allow sharing.
}}
{{┌──────────────────────────────────────────┐
  │ EEPROM demo                              │
  │ Author: Chris Gadd                       │
  │ Copyright (c) 2015 Chris Gadd            │
  │ See end of file for terms of use.        │
  └──────────────────────────────────────────┘

  Demonstrates how to write a byte, write a string of bytes, read a byte, read consecutive bytes, and read a page of bytes using I2C 

     24LC256   3V3          
    ┌───────┐             
  ┌─┤A0  Vcc├─┘   10KΩ      
  ┣─┤A1   WP├─┐ │ │                                                                                                                                         
  ┣─┤A2  SCL├─┼─┼─┻─ 
  ┣─┤Vss SDA├─┼─┻─── 
   └───────┘                                                                                                                                              
                                                                                                                                                            
}}                                                                                                                                                
CON
_clkmode = xtal1 + pll16x                                                      
_xinfreq = 5_000_000

  SCL = 28
  SDA = 29

  EEPROM = $50                                                                  ' 7-bit device ID for EEPROM

VAR
  byte  buffer[512]                  

OBJ
  I2C  : "I2C SPIN driver v1.4od"
  FDS  : "FullDuplexSerial"

PUB Main 
  FDS.start(31,30,0,115_200)
  waitcnt(cnt + clkfreq * 2)
  FDS.tx($00)

  if not ina[SCL]
    FDS.str(string("No pullup detected on SCL",$0D))                            
  if not ina[SDA]                                                               
    FDS.str(string("No pullup detected on SDA",$0D))
  if not ina[SDA] or not ina[SCL]
    FDS.str(string(" Use I2C Spin push_pull driver",$0D,"Halting"))                                                              
    repeat                                                                      

  I2C.init(SCL,SDA)

  if not \EEPROM_demo                                                           ' The Spin-based I2C drivers abort if there's no response
    FDS.str(string($0D,"EEPROM not responding"))                                '  from the addressed device within 10ms
                                                                                ' An abort trap \ must be used somewhere in the calling code
                                                                                '  or bad things happen if the I2C device fails to respond                  

PRI EEPROM_demo | Idx

  FDS.str(string("This demonstration uses single and page writes to store a series of bytes into registers $1000 through $1007 of the EEPROM,",$0D))

  I2C.writeByte(EEPROM,$1000,$01)                                               ' Using single writes to store values in registers
  I2C.writeByte(EEPROM,$1001,$23)                                               '  $1000 through $1002
  I2C.writeByte(EEPROM,$1002,$45)

  I2C.writeBytes(EEPROM,$1003,@Test_data,5)                                     ' Using a page write to store five values in registers
                                                                                '  $1003 through $1007

  FDS.str(string(" then uses single read and repeated reads to retrieve them.",$0D,{
                }" Register $1000 $"))
  FDS.hex(I2C.readByte(EEPROM,$1000),2)                                         ' Single read of register $1000
  idx := $1001
  repeat 7
    FDS.str(string($0D,"          $"))
    FDS.hex(idx++,4)
    FDS.str(string(" $"))
    FDS.hex(I2C.readNext(EEPROM),2)                                             ' Repeated reads of the following bytes 

  FDS.str(string($0D,$0D,"Using a page read to read the first 512 bytes of the EEPROM.",$0D,{
                        }" If loaded into EEPROM, pressing F8 to view the hex code will show the same thing.",$0D))
  I2C.readBytes(EEPROM,$0000,@buffer,512)                                       ' Read 512 bytes starting from address $0000, and store in the buffer
  Idx := 0                                                                      
  repeat 512 / 16                                                               ' Display the 512 bytes of buffer on serial terminal
    FDS.hex(Idx,4)                                                              '  Show the base address location for each row of 16 bytes
    FDS.tx(" ")
    FDS.tx(" ")
    repeat 16
      FDS.hex(buffer[Idx++],2)
      FDS.tx(" ")
    FDS.tx($0D)              
  
  FDS.str(string($0D,"Update a counter stored in EEPROM.  Each reset causes the the number to increment.",$0D," "))
  FDS.hex(Counter,2)                                                            ' Display counter value - loaded automatically from EEPROM on each reset
  I2C.writeByte(EEPROM,@Counter,Counter + 1)                                    ' Increment the counter and store back in to EEPROM

  return true

DAT                     org
Test_data               byte      $67,$89,$AB,$CD,$EF
Counter                 byte      00                                            ' Initializes counter to 0, value gets incremented by the program
                                                                                '  Storing this program in EEPROM and resetting causes the
                                                                                '  incremented value to be used
                        fit

DAT                     
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
