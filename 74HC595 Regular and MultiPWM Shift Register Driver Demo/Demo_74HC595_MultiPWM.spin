{{
OBEX LISTING:
  http://obex.parallax.com/object/102

  Easily control several 74HC595 shift registers in series. Now includes a variation which leaves out the PWM feature and instead supports up to 100 chips! Still also includes the multi-PWM driver, which allows you to set PWM frequency and duty cycle for any or all of 32 outputs. The PWM driver remembers whether you've set an output to PWM or a steady high or low value, and manages the PWM outputs for you automatically. Also includes the version 1.0 Simple_74HC595 object for those who just want to understand how to shift data out to the 74HC595 chip.

  If you downloaded the version 2.0 or 2.1 driver, you should download and replace it with the new version 2.2 driver, which has some bugs fixed; see the release notes at the top of the 74HC595_MultiPWM.spin file for detailed information.
}}
CON
{{
        Demo for 74HC595 MultiPWM Driver v2.0 March 2009
        See 74HC595_MultiPWM.spin for more info
        
        Copyright Dennis Ferron 2009
        Contact:  dennis.ferron@gmail.com
        See end of file for terms of use

}}



  _clkmode = xtal1 + pll16x                             ' use crystal x 16
  _xinfreq = 5_000_000                                  ' 5 MHz cyrstal (sys clock = 80 MHz)


  ' Set this to the pins you have connected to the 74HC595's
  SR_CLOCK = 21
  SR_LATCH = 22
  SR_DATA  = 23

OBJ
  shift :       "74HC595_MultiPWM"
  ser   :       "Simple_Serial"
  cv    :       "Simple_Numbers"
  
PUB demo | i, on_t, off_t, on_t_r, off_t_r, f, d

  ' Required:  Initialize the object.
  shift.Start(SR_CLOCK, SR_LATCH, SR_DATA)

  ' Debugging:  Initialize serial object
  ser.init(31, 30, 19200)

  ' Example: Output all 0's
  shift.Out(0)

  ' Ex.: Set lower 8 channels to 20% PWM at 1 Hz 
  repeat i from 0 to 7
    shift.SetPWM(i, 1, 20)

  ' Ex.: Set upper 8 channels to 80% PWM at 1 Hz
  repeat i from 24 to 31
    shift.SetPWM(i, 1, 80)

  ' Example: Turn on bit 0
  shift.High(1)

  ' Example: Turn off bit 0
  shift.Low(0)

  ' Example: Set bit 1 low
  shift.SetBit(1, 0)

  ' Example: Set bit 1 high
  shift.SetBit(1, 1)

  ' Display current values.
  repeat
    waitcnt(clkfreq/100 + cnt)  
    ser.str(cv.bin(shift.What, 32))
    ser.tx(13)
      
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
