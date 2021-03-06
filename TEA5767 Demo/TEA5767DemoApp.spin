'' ******************************************************************************
'' * TEA5767 Demo Propeller program                                             *
'' * Chris Sprague June 23, 2016                                                *
'' * Version 1                                                                  *
'' *                                                                            *
'' * Demos:  i2cObject                                                          *
'' * Uses :  Mike Green's "basic_i2c_driver" with a couple of extra bit         *
'' *         James Burrows's "i2CObjectV2_1
'' *                                                                            *
'' ******************************************************************************
''
'' this object provides the PUBLIC functions:
''  -> Start  
''
'' this object provides the PRIVATE functions:
''  -> TEA5767_demo    - 
''  -> i2cScan        - scan the bus. Show results in Parallax Serial Terminal (or equivalent)
''
'' Revision History:
''  -> V2 - re-release                          
''
'' this object uses the following sub OBJECTS:
''  -> basic_i2c_driver
''  -> TEA5767Object
''
''                        4.7K                       3.3V
''                    ┌──────  3.3V      TEA5767──┘ 
''                    │ ┌────  3.3V        │ │  
''                    │ │                      │ │
''   Pin29/SDA ───────┻─┼──────────────────────┻ │
''                      │                        │
''   Pin28/SCL ─────────┻────────────────────────┻
''
'' Example Frequencies
''(Sacramento, CA)
''
'' Instructions (brief):
'' (1) - setup the propeller - see the Parallax Documentation (www.parallax.com/propeller)
'' (2) - Use a 5mhz crystal on propeller X1 and X2
'' (3) - Connect the SDA lines to Propeller Pin28, and SCL lines to Propeller Pin29
''       See diagram above for resistor placements.
''       Note that the DS1307 does not provide enough current to drive from the 5v section
''       OPTIONAL: Connect the DS1307, DS1621, SRF08, MD22, and 24LC256 (EEPROM) devices
''                  - the demo will work if they are not all present!   
''       OPTIONAL: Connect LED's to MCP23016 pins G0.1,2 & 3, GP1.1,2 & 3
'' (4) - OPTIONAL: Update the i2c Address's for the i2c if you are not using their base address's.
'' (5) - Connect a terminal to the programming pins and use hypertrm or similar to see the results!
'' (6) - Run the app!
''     

CON
  _clkmode      = xtal1 + pll16x
  _xinfreq      = 5_000_000
  _stack        = 50
    
  i2cSCL        = 28
'  i2cSDA        = 29 

  TEA5767Addr  = %1100_0000
  
  ' debug - USE onboard pins
  pcDebugRX       = 31
  pcDebugTX       = 30

  ' serial baud rates  
  pcDebugBaud     = 115200    
  
VAR
  long  i2cAddress, i2cSlaveCounter

OBJ
  i2cObject      : "basic_i2c_driver"
  TEA5767Object   : "TEA5767Obj" 

  debug          : "Debug_PC"

pub Start
    ' start the PC debug object
    debug.startx(pcDebugRX,pcDebugTX,pcDebugBaud)
  
    ' setup i2cobject
    i2cObject.Initialize(i2cSCL)

    ' pause 5 seconds
    repeat 10
        debug.putc(".")
        waitcnt((clkfreq/2)+cnt)
    debug.putc(13)
  
    ' i2c state
    debug.strln(string("I2C Demo (v2)!"))

    'demo the i2c scan
    i2cScan
    waitcnt(clkfreq*2 +cnt)

    repeat 

        ' demo the TEA5767 Motor Controller
        if i2cObject.devicePresent(i2cSCL,TEA5767Addr) == true
            debug.strln(string("TEA5767Addr Present"))
            ''TEA5767_Demo
        else
            debug.strln(string("TEA5767Addr Missing"))      
        waitcnt(clkfreq*3+cnt)

PRI TEA5767_Demo
    ' demo the MD23 Motor Controller
    debug.strln(string("TEA5767 Demo..."))
    
PRI i2cScan | value, ackbit
    ' Scan the I2C Bus and debug the LCD
    debug.strln(string("Scanning I2C Bus...."))
     
    ' initialize variables
    i2cSlaveCounter := 0
     
    ' i2c Scan - scans all the address's on the bus
    ' sends the address byte and listens for the device to ACK (hold the SDA low)
    repeat i2cAddress from 0 to 127
     
        value :=  i2cAddress << 1 | 0
        ackbit := i2cObject.devicePresent(i2cSCL,value)
        
        if ackbit==false
            'debug.str(string("NAK"))
        else
            ' show the scan 
            debug.str(string("Scan Addr :  %"))    
            debug.bin(value,8)
            debug.str(string(",  ACK"))                  
         
            ' the device has set the ACK bit 
            i2cSlaveCounter ++
            waitcnt(clkfreq+cnt)
 
            debug.putc(13)
         
        ' slow the scan so we can read it.    
        waitcnt(clkfreq/4 + cnt)

    ' update the counter
    debug.str(string("i2cScan found "))
    debug.dec(i2cSlaveCounter)
    debug.strln(string(" devices!"))
    
        