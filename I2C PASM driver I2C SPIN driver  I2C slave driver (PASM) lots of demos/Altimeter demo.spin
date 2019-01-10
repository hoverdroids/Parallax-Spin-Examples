{{
OBEX LISTING:
  http://obex.parallax.com/object/700

  Includes Spin-based and PASM-based open-drain and push-pull drivers, with methods for reading and writing any number of bytes, words, and longs in big-endian or little-endian format.  All drivers tested with the 24LC256 EEPROM, DS1307 real time clock, MMA7455L 3-axis accelerometer, L3G4200D gyroscope module, MS5607 altimeter module, and BMP085 pressure sensor.  Includes a demo programs for each.

  Also includes a polling routine that displays the device address and name of everything on the I2C bus.

  Also includes a slave object that runs in a PASM cog with a Spin handler, and provides 32 byte-sized registers for a master running on another device to write to and read from.  Tested okay up to 1Mbps (max speed of my PASM push-pull object).  Includes demo for the slave object.

  Newly added multi-master object that can share the bus with other masters, provided of course that the other masters also allow sharing.
}}
{{┌──────────────────────────────────────────┐
  │ MS5607 Altimeter demo                    │
  │ Author: Chris Gadd                       │
  │ Copyright (c) 2014 Chris Gadd            │
  │ See end of file for terms of use.        │
  └──────────────────────────────────────────┘
  Demonstration of reading temperature and pressure from the 29124 altimeter module from Parallax
   Borrows heavily from the 29124_altimeter_demo

  Displays the corrected pressure and temperature

   ┌────────────────┐
   │  #29124    CS •│    During testing, it became apparent that the MS5607 reads hotter the more frequently it's sampled
   │           SDO •│     The Parallax driver runs the sampler in the background, therefore samples more often, and    
   │   ┌─┐     SDA •│     reads slightly warmer: 28.42°C vs. 28.64°C
   │   │ │     SCL •│     both read about the same corrected pressure 1020.39mb vs 1020.33mb
   │   └─┘      PS •│        
   │ Altimeter VIN •│        
   │  Module   GND •│        
   └────────────────┘

}}                                                                                                                                                
CON
  _clkmode = xtal1 + pll16x                                                    
  _xinfreq = 5_000_000

  SCL = 28
  SDA = 29

CON
' MS5607 specific constants
  
  ALT           = $76    ' 7-bit I2C address with CS high or floating (internally pulled up)
' ALT           = $77    ' alternate address with CS low
                                                                  
  RESET         = $1E                                             
  ADC           = $00                                             
  PRES          = $40                                             
  TEMP          = $50                                             
  PROM          = $A0                                             
                                                               
  RES_256       = $00                                             
  RES_512       = $02                                             
  RES_1024      = $04                                             
  RES_2048      = $06                                                   
  RES_4096      = $08                                             
                                                               

VAR
  long                d1,d2                                                     ' uncorrected pressure and temperature
  long                pressure, temperature                                     ' corrected pressure and temperature readings
  long                adc_delay, adc_timer
  word                c1,c2,c3,c4,c5,c6                                         ' calibration coefficients read from PROM
  byte                adc_buffer[3]                                             
  byte                resolution                                                ' contains RES_256 ($00) through RES_4096 ($08)
                                            
OBJ
  I2C : "I2C Spin driver v1.3"
  FDS : "FullDuplexSerial"

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

  I2C.start(SCL,SDA)

  if not \Altimeter_demo                                                        ' The Spin-based I2C drivers abort if there's no response
    FDS.str(string($0D,"Altimeter not responding"))                             '  from the addressed device within 10ms
                                                                                ' An abort trap \ must be used somewhere in the calling code
                                                                                '  or bad things happen if the I2C device fails to respond                  

PUB Altimeter_demo | i

  I2C.Command(ALT,RESET)
  waitcnt(cnt + clkfreq)

  dira[16] := 1
  repeat i from 0 to 5                                                          ' Retrieve calibration coefficients from registers $A2 through $AC
    C1[i] := I2C.read_word(ALT,PROM + (i * 2) + 2)                              ' MS5607 does not auto-advance registers when reading the PROM

  Set_resolution(RES_4096)
  repeat
    Start_conversion(TEMP)
    repeat until d2 := Check_adc                                                
    Start_conversion(PRES)
    repeat until d1 := Check_adc
    calculate_temp_and_pressure
    FDS.tx($00)
    FDS.str(string("Temperature = "))
    decf(temperature,100,2)
    FDS.str(string("°C",$0D))
    FDS.str(string("Pressure = "))
    decf(pressure,100,2)
    FDS.str(string(" mb"))
    waitcnt(cnt + clkfreq / 20)

PUB Set_resolution(resol) | i

  if (i := lookdown(resol: RES_256, RES_512, RES_1024, RES_2048, RES_4096))     ' RES_256 through RES_4096 are set to $00 through $08
    resolution := resol                                                         ' resolution is used for determining which ADC register to query
    adc_delay := clkfreq / lookup(i: 1666, 854, 438, 220, 110) #> 400           ' sets delays of 0.60ms, 1.17ms, 2.28ms, 4.54ms, or 9.04ms

PRI Start_conversion(which) 

  I2C.command(ALT,which | resolution)                                           ' Which = Pres ($40) or Temp ($50) | resolution = $00 through $08
  adc_timer := cnt + adc_delay * 2                                              ' adc_delay = 0.60ms, 1.17ms, 2.28ms, 4.54ms, or 9.04ms
  
PRI Check_adc 
{ Reads the ADC and returns the value if the time delay has expired
  Returns false if the time delay has not expired
}
  if cnt - adc_timer > 0
    I2C.Read_page(ALT,$00,@adc_buffer,3)
    return (adc_buffer[0] << 16 | adc_buffer[1] << 8 | adc_buffer[2])
  else
    return false

PRI DecF(value,divider,places) | i, x
{
  DecF(1234,100,3) displays "12.340"
}

  if value < 0
    || value                                            ' If negative, make positive
    fds.tx("-")                                         ' and output sign
  else
    fds.tx(" ")                                         
  
  i := 1_000_000_000                                    ' Initialize divisor
  x := value / divider

  repeat 10                                             ' Loop for 10 digits
    if x => i                                                                   
      fds.tx(x / i + "0")                               ' If non-zero digit, output digit
      x //= i                                           ' and remove digit from value
      result~~                                          ' flag non-zero found
    elseif result or i == 1
      fds.tx("0")                                       ' If zero digit (or only digit) output it
    i /= 10                                             ' Update divisor

  fds.tx(".")

  i := 1
  repeat places
    i *= 10
    
  x := value * i / divider                             
  x //= i                                               ' limit maximum value
  i /= 10
    
  repeat places
    fds.Tx(x / i + "0")
    x //= i
    i /= 10    
    
DAT '=======================================================================================================================================================
' methods borrowed from the Parallax 29124_altimeter object
 
PRI calculate_temp_and_pressure | dt, offh, offl, sensh, sensl, ph, pl

  dt := d2 - c5 << 8                                                            ' Difference between sampled and reference temperature
  temperature := 2000 + ((dT ** c6) << 9 + (dT * c6) >> 23)                     ' Actual temperature (-40...85°C with 0.01°C resolution)
                                                                                '  2000 = 20.00°C
  offh := c4 ** dt                                                              ' Offset at actual temperature
  offl := (c4 * dt) >> 6 | offh << 26                                           ' OFF = C2 * 2^17+(C4*dT)/2^6
  offh ~>= 6
  _dadd(@offh, c2 >> 15, c2 << 17)

  sensh := c3 ** dt                                                             ' Sensitivity at actual temperature
  sensl := (c3 * dt) >> 7 | sensh << 25                                         ' SENS = C1 * 2^16 + (C3 * dT)/2^7
  sensh ~>= 7
  _dadd(@sensh, c1 >> 16, c1 << 16)

  _umult(@ph, d1, sensl)                                                        ' Temperature compensated pressure (10...1200mbar with 0.01mbar resolution)
  ph += d1 * sensh                                                              '  110002 = 1100.02mbar
  pl := pl >> 21 | ph << 11                                                     ' P = (D1 * SENS / 2^21 - OFF) / 2^15
  ph ~>= 21
  _dsub(@ph, offh, offl)
  pressure := ph << 17 | pl >> 15
  
PRI _dsub(difaddr, subh, subl)

  {{ Subtract the 64-bit value `subh:`subl from the 64-bit value stored at `difaddr.
  }}
  
  _dadd(difaddr, -subh - 1, -subl)

PRI _dadd(sumaddr, addh, addl) | sumh, suml

  {{ Add the 64-bit value `addh:`addl to the 64-bit value stored at `sumaddr.
  }}

  longmove(@sumh, sumaddr, 2)
  sumh += addh
  suml += addl
  if (_ult(suml, addl))
    sumh++
  longmove(sumaddr, @sumh, 2)

PRI _ult(x, y)

  {{ Test for unsigned `x < unsigned `y. Return `true if less than; `false, otherwise. 
  }}

  return x ^ $8000_0000 < y ^ $8000_0000

PRI _umult(productaddr, mplr, mpld) | producth, productl

  {{ Multiply `mplr by `mpld and store the unsigned 64-bit product at `productaddr.
  }}

  producth := (mplr & $7fff_ffff) ** (mpld & $7fff_ffff)
  productl := (mplr & $7fff_ffff) * (mpld & $7fff_ffff)
  if (mplr < 0)
    _dadd(@producth, mpld >> 1, mpld << 31)
  if (mpld < 0)
    _dadd(@producth, mplr << 1 >> 2, mplr << 31)
  longmove(productaddr, @producth, 2)

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
