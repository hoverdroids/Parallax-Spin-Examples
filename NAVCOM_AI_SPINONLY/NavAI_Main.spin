{{
OBEX LISTING:
  http://obex.parallax.com/object/419

  Full featured autopilot for boats, planes and rovers. Tested over 3 years. You can see the videos under Spiritplumber on youtube. This version does not contain the graphical console, but text i/o is possible and fairly easy to do.

  Other versions are maintained here http://robots-everywhere.com/portfolio/navcom_ai/ and may be downloaded there. If you intend to use this commercially, please see licensing information on that page.

  A note: It is possible to build functional drone bombers or similar with this. You the downloader are explicitly denied permission to do so. If you want to build autonomous weapons do your own homework, or better yet, go get your head examined.

  Videos of the drones in action!

  http://www.youtube.com/watch?v=5wJHj3hOcuI
  http://www.youtube.com/watch?v=diAZD68Y3Cw
  http://www.youtube.com/watch?v=AIbPvxf3hrk
  http://www.youtube.com/watch?v=en5TCSHZDyY
  http://www.youtube.com/watch?v=Dd1R-WeGWkU
  http://www.youtube.com/watch?v=9m6H5se6-nE
}}
CON
        ' NAVCOM AI prototype 2 pin assignment


        NoPinTX                 = -1
        NoPinRX                 = -1

        SDCard0                 = 00       
        SDCard1                 = 01       
        SDCard2                 = 02       
        SDCard3                 = 03       

        Servo1Out               = 07
        Servo2Out               = 06
        Servo3Out               = 05
        Servo4Out               = 04

        BattPinRX               = 08
        
        com0PinRx               = 09
        com0PinTx               = 10

        ADPinRx                 = 11  ' companion A/D
        Sensor1RX               = 12
        Sensor2RX               = 13
        Sensor3RX               = 14

        VectorHRX               = 15
        HeadingPinRx            = 15 ' for now: fix later

        SPI1                    = 16
        SPI2                    = 17

        Com1PinRX                  = 20
        Com1PinTX                  = 21
        Com2PinRX                  = 18
        Com2PinTX                  = 19
        Com3PinRX                  = 24
        Com3PinTX                  = 25
        Com4PinRX                  = 22
        Com4PinTX                  = 23

        GPS1PinTx               = 26
        GPS1PinRx               = 27

        i2iCLKPin               = 28
        i2cSDAPin               = 29

        ProgPinTx               = 30
        ProgPinRx               = 31

        MuxPinRx                = -1
        MuxPinAlert             = -1


CON
                                                                                                                              
        _clkmode                = xtal1 + pll16x
        _xinfreq                = 5_000_000
        _stack                  = 10 ' mah? set this to MainStack instead?                                                                                       

'        interprounds            = 10 ' How many interpolation rounds to have per second
        NaN             =       $7FFF_FFFF ' used to mean invalid value in floating point
        INVALIDANGLE    =       400.0 ' i.e. more than 360
        INVALIDCOORD    =       2147483647 ' invalid coordinate obviously (as in, more than 180degs)
                                 
dat

' THIS MUST BE HERE IN FRONT FOR ABSOLUTE ADDRESSING TO WORK!!!!!

' this can double as a copyright notice if it's output before anything else is initialized.
SensorDatum  '     0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35  36  37  38  39  40  41  42  43  44  45  46  47  48  49  50  51  52  53  54  55  56  57  58  59  60  61  62  63  64  65  66  67  68  69  70  71  72  73  74  75  76  77  78  79  80  81  82  83  84  85  86  87  88  89  90  91  92  93  94  95  96  97  98  99    
SensorData   byte  0 ,":",":",":"," ","N","A","V","C","O","M"," ","A","I"," ","b","y"," ","m","k","b","@","l","i","b","e","r","o",".","i","t",13 ,10 ,":",":",":"," ","R","S","V"," ","b","y"," ","w","w","w",".","e","t","r","a","c","e","n","g","i","n","e","e","r","i","n","g",".","c","o","m",13 ,10 ,":",":",":"," ","S","o","m","e"," ","r","i","g","h","t","s"," ","r","e","s","e","r","v","e","d",".",13 ,10 , 0 , 0 , 0
SensorData2  byte  0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
SensorData3  byte  0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
SensorData4  byte  0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,"R","A","<","3","M","K","B","<","3","C","K",13 ,10 , 0
VAR
      

        long    PrevRadio
        long    PrevGPSStatus         ' Hold previous value of radio for each update cycle; must be a long for compatibility
        
        byte    AIType            ' 0 none, 1 etracboat, 2 powerboat, 3 plane, 4 car, 5~255 generic
        byte    AIType_last       ' 0 none, 1 etracboat, 2 powerboat, 3 plane, 4 car, 5~255 generic

        byte    AIState     
        byte    AIState_next
        byte    AIState_last

        
        'long    comstrptr
        long    commandptr
        long    aitime
        long    turncount
        byte    flag_routeon     ' is route on?
        byte    curwplogged ' have we already logged this waypoint, if it's off?  
        byte    flag_routeupdated ' Rute updated during this cycle

con     NumWaypoints = i2c#MaxStructs+1'1000         ' Number of stored waypoints, obviously :)
        NumCoefficients = 12      ' How many coefficients can an equation hold? (probably should be same as RPN stack)
        NumTokens = NumCoefficients*2            ' How many tokens can an equation hold? (1 token = 1 constant or variable or operation)
        CmdStrLength = 35 '37        ' How long is the command string? (a little less than 1 screen width I think)
        ExpStrLength = CmdStrLength - 2'40         ' How long is the command string? (a little less than 1 screen width I think)

VAR

        byte commandstring[CmdStrLength] ' String holding the currently received commandline (buffered AI-side to make sure no characters are lost in tx)
        byte executestring[CmdStrLength] ' String holding another, preservable commandline

        
        byte ExtraEquation1[ExpStrLength]
        byte ExtraToken1[NumTokens]
        long ExtraCoeff1[NumCoefficients]

        byte ExtraEquation2[ExpStrLength]
        byte ExtraToken2[NumTokens]
        long ExtraCoeff2[NumCoefficients]

        byte TrackEquation[ExpStrLength]
        byte TrackToken1[NumTokens]
        long TrackCoeff1[NumCoefficients]

        byte ServoToken1[NumTokens]        ' and processed into tokens
        byte ServoToken2[NumTokens]
        byte ServoToken3[NumTokens]
        byte ServoToken4[NumTokens]
                                                                                                                                
        byte ServoEquation1[ExpStrLength]   ' that gets turned into an expression if needed
        byte ServoEquation2[ExpStrLength]
        byte ServoEquation3[ExpStrLength]
        byte ServoEquation4[ExpStrLength]

        long ServoCoeff1[NumCoefficients] ' and constant lists
        long ServoCoeff2[NumCoefficients]
        long ServoCoeff3[NumCoefficients]
        long ServoCoeff4[NumCoefficients]

        long itpf ' 1 / time ticks
        

' these can be addressed sequentially too, we're just writing them down explicitly
        long ServoAmplitude[4]

        long ServoValI[4]

        long ServoValF[4]

        long sensortime
        
        long line
        long xmit_tele
        long linecnt




       
var     
        byte    SensorDataLast[26*4]'l#LastVar + 4]   ' Global nav/sensor data array, see list of constants below -- call SensorData address + constant. DEVNOTE_MKB: Specified in bytes because this way we don't have to use a long for a value if we can get away with less

        byte    SensorDataDelta[26*4]'l#LastVar + 4]   ' Global nav/sensor data array, see list of constants below -- call SensorData address + constant. DEVNOTE_MKB: Specified in bytes because this way we don't have to use a long for a value if we can get away with less

        'byte    gpsstring[64] 
        'byte    telestring[64]

var                                ' for use with remote control
        long    DirectControlForward
        long    DirectControlRight
        byte    DirectControlOther
        byte    DirectControlStatus
        long    DirectControlTimer

var     long    MainStack[l#MainStackSize] ' see above


'con     DirectControlTimeout = 5.5 ' seconds; this should really be a variable... eventually

{
var
long routestart
long routeend
long interpolationrounds
long interpolationroundsF
long intr_temp
long curwayp
long wayp_temp
long go2tracking
long go2t_temp
byte initbyte
byte InterpLimit
}
dat    ' These are variables that start off initialized, since they are globals it's cheaper to have them as DATs.


'psstring               byte "$GPGGA,204120.00,3752.26281,N,12230.09348,W,2,04,2.2,-18.8,M,-27.9,M,5.2,0211*62"
gpsstring               byte "_______________________________________________________________________________________",0
telestring              byte "!!!_____________________________________________________________",0
routestart              long -1
routeend                long -1
interpolationroundsF    long 35.0
interpolationrounds     long 35
intr_temp               long 35
lastwayp                long 1                  
curwayp                 long 0                  
wayp_temp               long 0
'InterpLimit             byte InterpLimitH
echo                    byte 0
secho                   word 0
gecho                   byte 0
ParseParameterEchoBack  byte 1

ServoAdd long 1500
ServoMul long 500.0

'ServoTrimI              long (ServoSwingI / 5)'20

'       Y:=lookupz(X++: "A","B","E","F","G","I","J","K","L","M","Q","R","V","W","Z",0)
 
dat
{
' linked as per the usual table
extravaroffset  long l#AlphaOffset+l#AA, l#AlphaOffset+l#BB, l#AlphaOffset+l#CC, l#AlphaOffset+l#DD, l#AlphaOffset+l#EE, l#AlphaOffset+l#FF, l#AlphaOffset+l#GG
extravaroffset1 long l#AlphaOffset+l#HH, l#AlphaOffset+l#II, l#AlphaOffset+l#JJ, l#AlphaOffset+l#KK, l#AlphaOffset+l#LL, l#AlphaOffset+l#MM, l#AlphaOffset+l#NN
extravaroffset2 long l#AlphaOffset+l#OO, l#AlphaOffset+l#PP, l#AlphaOffset+l#QQ, l#AlphaOffset+l#RR, l#AlphaOffset+l#SS, l#AlphaOffset+l#TT, l#AlphaOffset+l#UU
extravaroffset3 long l#AlphaOffset+l#VV, l#AlphaOffset+l#WW, l#XX, l#YY, l#ZZ
}
' some arent linked in the etrac boat
extravaroffset  long l#AA, l#BB, l#AlphaOffset+l#CC, l#DD, l#EE, l#FF, l#GG
extravaroffset1 long l#AlphaOffset+l#HH, l#II, l#JJ, l#KK, l#LL, l#MM, l#AlphaOffset+l#NN
extravaroffset2 long l#AlphaOffset+l#OO, l#AlphaOffset+l#PP, l#QQ, l#RR, l#AlphaOffset+l#SS, l#AlphaOffset+l#TT, l#AlphaOffset+l#UU
extravaroffset3 long l#VV, l#AlphaOffset+l#WW, l#XX, l#YY, l#ZZ
dat
SensorType    byte  "__________",0
TelemetryType byte  "hbsdnIJxyza",0,"    ",0
'TelemetryType byte "hbs dtn    IJKL ",0
                    
con
' for display, see below                  
         goX =  $0A              
         goY =  $0B                       
         home = $01
         cr  =  $0D
        
CON     ' make them into variables and specify per-servo?

        ServoSwingF = 500.0
        ServoCenterI = 1500
        TurnHysteresis = 10.0 '5.0
        
CON     SensorBaud = -9600 ' be sure that this matches the baudrate on the Picaxes! ALL the Picaxes must have the same baudrate! Negative means invert the signal.
        COMBaud = 38400
             ' be sure that this matches the baudrate on the com0!
        COMMask = %0000    ' %0000 is noninverted and %0011 is inverted. The com0 does NOT use inversion!!!!
        GPSBaud = -9600    ' be sure that this matches the baudrate on the GPS! NMEA is 4800. Negative means invert the signal.
con InterpLimitH = 50
    InterpLimitL = 05

CON ' parameter parsing options
        INUM = false     ' return an integer
        FNUM = true      ' return a float                                             
        EXPR = 2         ' return a float, but evaluate expression (slower)            -

        ' Interpolation rate limit
        LESSTHAN = -1
        MORETHAN = 1
        EQUALS   = 0

        SERVO1 = 0
        SERVO2 = 1
        SERVO3 = 2
        SERVO4 = 3

        AITYPE_NONE = 0 ':     AItype~ ' no ops for basic nav
        AITYPE_BOAT = 1':     aifunction_etracboat

OBJ
        ' IF YOU CHANGE THESE YOU NEED TO ALSO CHANGE THE MAIN MEMORY MAP OFFSET IN THE LIBRARY.

        com0    : "FullDuplexSerialExt"         ' used for the COM subsystem; occupies 1 cog
        gps     : "GPRMCGPSParser_SD"          ' handles 1 gps in TXT mode; occupies 1 cog
        servo   : "Servo32"                  ' Generates servo pulses; occupies 1 cog
        sensor  : "SerialSensorParserOld"       ' handles 4 sensors; ; occupies 1 cog
        fto     : "FtoF"                     ' stripped version of FloatString basically; does not occupy cogs
        eqr     : "equationparser_RPN"       ' basically a HP calculator emulator, used for modifiable servo equations; does not occupy cogs
        m       : "DynamicMathLib (2)"           ' big dynamic math library; occupies 1 to X cogs depending how many we have left. This gets called by just about everything.
        l       : "NavAI_Lib" ' small library w/ memory map in it
        stak    : "stack_length_debug" ' remove once we know how big the stack must be
        i2c     : "EEPROM_I2C_Driver"   ' use for data logging, etc.

        
PUB start  
  stak.Init(@MainStack,l#MainStackSize)  ' main stack init
  coginit(0, AILoop, @MainStack)         ' reboot self. Why? To use a specified stack so we know exactly how much memory we have left.
pub AILoop

' general init
ExecuteCommand(string("@KC",13))
com0.crlf
eqr.slow
fto.init
com0.str(constant(l#SensorDataAddress)+1)
bytefill(l#SensorDataAddress, 0.0, l#EndOfBuffer)
long[constant(l#SensorDataAddress  + l#HeadTre)] := 99.98 ' below this speed in m/s, use compass only instead of gps+compass
long[constant(l#SensorDataAddress  + l#COGTre)] := 99.99 'above this speed, trim compass to COG so we can use it better in the future
long[constant(l#SensorDataAddress  + l#CompassMultiplier)]:= 1.0          ' used to do heading/bearing calculations
long[constant(l#SensorDataAddress  + l#NROTDeadZone)]:= 1.2               ' used to do gyro corrections
long[constant(l#SensorDataAddress  + l#CompassTrim)]~                     ' trim compass out by this much
long[constant(l#SensorDataAddress  + l#GPSTimeReceive)]~
long[constant(l#SensorDataAddress  + l#ArrivalDistance)] := 2.5           ' in meters
long[constant(l#SensorDataAddress  + l#DirectControlTimeout)] := 6.0      ' in seconds
long[constant(l#SensorDataAddress  + l#AltitudeMultiplier)] := l#feettometers
long[constant(l#SensorDataAddress  + l#BatteryMultiplier)] := 0.015467924242424242424242424242424' calibrated april 28 2008



longfill(@ServoAmplitude[0], 1.0, 4)
xmit_tele~
com0.str(@inidstr)
i2c.Initialize(i2c#BootPin)
i2c.Start(i2c#BootPin)
i2c.WriteWaypoint(0,0,0)
com0.str(@eeprstr)
byte[@eep2str] := ":" ' allows reuse of eeprom string


' Initial equations must be defined here
ExecuteCommand(string("@E1 0",13)) ' gyro
    'use these two if the V-tail mixer is not in
    ExecuteCommand(string("@E2 Y X -",13))
    ExecuteCommand(string("@E3 Y X +",13))

    'use these two if the V-tail mixer is in
    'ExecuteCommand(string("@E2 Y",13))
    'ExecuteCommand(string("@E3 X",13))

ExecuteCommand(string("@E4 0",13)) ' spare channel

ExecuteCommand(string("@ET P",13))
ExecuteCommand(string("@EX U",13))
ExecuteCommand(string("@EY U",13))


ExecuteCommand(string("@KV",13))
ExecuteCommand(string("@KG7",13))

com0.str(string("!!!l63",13,10)) ' beep!
ExecuteCommand(string("@KS",13))

'com0.str(@gpsstring)
gecho~~ ' display GPS output since we don't know if it's valid, or even connected: allows operator to catch issues




{
' ai1 init conditions for etrac boat: shouldn't be here logically, but it makes startup a lot faster
     X~
     Y := "A"
     repeat
        'turnlocal := (X-"A")*4
        'long[l#SensorDataAddress + turnlocal]~ 
        'extravaroffset[turnlocal] := turnlocal
        byte[@zerome] := Y & $FF
        Y:=lookupz(X++: "A","B","E","F","G","I","J","K","L","M","Q","R","V","W","Z",0)
        ExecuteCommand(@zerovar)
     while Y
     X~
     Y~
}
' end ai1 init conditions for etrac boat




' notify that init is over
inibstr[0]:="1"
com0.str(@inidstr)
com0.str(@ininstr)
inibstr[0]~











' pre-loop waiting for a valid GPS signal
repeat

 ' if not com0.txsize
  ParseCommandString'(comstrptr)   
  UpdateServos
  if long[constant(l#SensorDataAddress  + l#GPSTimeReceive)]
      xmit_tele := 1
      XmitTelemetry
      long[constant(l#SensorDataAddress  + l#GPSTimeReceive)]~
until long[constant(l#SensorDataAddress  + l#gpsstatus)] == 1.0 'long[constant(l#SensorDataAddress  + l#GPSTimeReceive)] ' do we want to disable aux functions? possibly... keep for now

' sync with GPS
long[(@SensorData + l#GPSTimeReceive)]~
repeat until long[(@SensorData + l#GPSTimeReceive)] 

i2c.WriteWaypoint(0,long[constant(l#SensorDataAddress  + l#lat)],long[constant(l#SensorDataAddress  + l#lon)])  ' "go home" waypoint

com0.str(string("!!!l32",13,10)) ' beep!
gecho~ ' stop displaying GPS output since we know it's valid
com0.str(@sen1str)
com0.str(@sensortype)
com0.crlf      

long[constant(l#SensorDataAddress  + l#Optime)] := 1.0













































' say we're good to go

'com0.str(@gogostr)
'com0.crlf
ExecuteCommand(string("@AI1",13))

' actual main NAV-COM loop
repeat
            
  MainAIFunction(true) ' option: give AI function its own core?
  ParseCommandString
  linecnt++'= 1

  if (long[constant(l#SensorDataAddress  + l#gpsstatus)] <> PrevGPSStatus)  ' notify change in gps status
     PrevGPSStatus := long[constant(l#SensorDataAddress  + l#gpsstatus)]
     com0.str(@satstr)
     if long[constant(l#SensorDataAddress  + l#gpsstatus)]
        com0.str(string("OK",13,10))
     else
        com0.str(string("lost",13,10))
{
  if (long[constant(l#SensorDataAddress  + l#Radio)] <> PrevRadio) ' notify change in radio status
       PrevRadio := long[constant(l#SensorDataAddress  + l#Radio)]
       com0.str(string(":::RC: "))
       com0.tx(PrevRadio)
       com0.str(@crlfstr)
}
  if (linecnt > 20_000) ' safety: reset gps
    linecnt~
    intr_temp -= 2
    if (intr_temp < InterpLimitL)
        intr_temp := InterpLimitL
    
    interpolationrounds := intr_temp
    interpolationroundsF := m.ffloat(interpolationrounds)
    itpf := m.fdiv(1.0, interpolationroundsF) ' do it here for less overhead elsewhere

    com0.str(string(":::GPS error",13,10))
    ExecuteCommand(string("@KG3",13))



  
pub  MainAIFunction(DoTelemetry) | cc, turntemp

    m.allowfast

    if((aitime == long[constant(l#SensorDataAddress  + l#GPSTime)]))
        itpf := m.fdiv(1.0, interpolationroundsF) ' do it here for less overhead elsewhere
        return false


    if (DirectControlStatus)
       DirectControlTimer := m.fadd(DirectControlTimer, itpf)
       if m.fcmpi(DirectControlTimer, MORETHAN , long[constant(l#SensorDataAddress  + l#DirectControlTimeout)])
         byte[@dir2str] := "F"
         byte[@dir3str] := "F"
         com0.str(@direstr)
         byte[@dir3str] := " "
         DirectControlTimer~ ':= 0.0
         DirectControlStatus~' := 0

         

    if (long[constant(l#SensorDataAddress  + l#GPSTimeReceive)] == 0.0)
    
       
       case secho
         0,1: xmit_tele := xmit_tele                                                                                            
         2: xmit_tele |= (SechoCondition(50))
         3: xmit_tele |= (SechoCondition(33) or SechoCondition(66))
         4: xmit_tele |= (SechoCondition(25) or SechoCondition(50) or SechoCondition(75))
         5: xmit_tele |= (SechoCondition(20) or SechoCondition(40) or SechoCondition(60) or SechoCondition(80))
         other: xmit_tele := not xmit_tele ' send tele every other nav frame -- scary!
                secho-- 

       long[constant(l#SensorDataAddress  + l#Optime)] := m.fadd(long[constant(l#SensorDataAddress  + l#Optime)], itpf)'m.fdiv(1.0, interpolationroundsF))

    else ' do this only if we just got a "real" gps tick
       
       i2c.PreloadWaypoint(wayp_temp) 
       interpolationrounds := intr_temp ' These need a solid GPS fix to work right!
       interpolationroundsF := m.ffloat(interpolationrounds) ' These need a solid GPS fix to work right!
       UpdateRoute

       ' prevents jittering between +180 and -180
       ' does it make sense to do these in the interpolator instead?
       turntemp := m.FMathTurnAmount(long[constant(l#SensorDataAddress  + l#Heading)], long[constant(l#SensorDataAddress  + l#_tracking)])
       if not ( (m.fcmpi(turntemp, MORETHAN, constant(180.0 - TurnHysteresis)) and m.fcmpi(long[constant(l#SensorDataAddress  + l#_tUrnamount)], LESSTHAN, constant(-180.0 + TurnHysteresis))) or ((m.fcmpi(turntemp, LESSTHAN, constant(-180.0 + TurnHysteresis)) and m.fcmpi(long[constant(l#SensorDataAddress  + l#_tUrnamount)], MORETHAN, constant(180.0 - TurnHysteresis)))))
              long[constant(l#SensorDataAddress  + l#_tUrnamount)] := turntemp
       long[constant(l#SensorDataAddress  + l#trnGPS)] := long[constant(l#SensorDataAddress  + l#_tUrnamount)] ' this must go below eventually -- keep here for now for testing    

       
       ' autoreset sensors if no activity
       if (sensortime == long[constant(l#SensorDataAddress + l#UpdCycle)]) ' ie it hasn't moved in a while
           executecommand(string("@KS",13))
           sensortime--
       
       sensortime := long[constant(l#SensorDataAddress  + l#UpdCycle)]
       xmit_tele := 1

       long[constant(l#SensorDataAddress  + l#Optime)] := m.ffloat(m.fround(long[constant(l#SensorDataAddress  + l#Optime)]))

       
    long[constant(l#SensorDataAddress  + l#RawGPSTracking)] := long[constant(l#SensorDataAddress  + l#GPSTracking)] ' turn this way to defined waypoint

    turntemp := m.FMathTurnAmount(long[constant(l#SensorDataAddress  + l#Heading)], long[constant(l#SensorDataAddress  + l#_tracking)])
    if not ( (m.fcmpi(turntemp, MORETHAN, constant(180.0 - TurnHysteresis)) and m.fcmpi(long[constant(l#SensorDataAddress  + l#_tUrnamount)], LESSTHAN, constant(-180.0 + TurnHysteresis))) or ((m.fcmpi(turntemp, LESSTHAN, constant(-180.0 + TurnHysteresis)) and m.fcmpi(long[constant(l#SensorDataAddress  + l#_tUrnamount)], MORETHAN, constant(180.0 - TurnHysteresis)))))
         long[constant(l#SensorDataAddress  + l#_tUrnamount)] := turntemp

    ' copy real vars into letter vars
    cc~
    repeat
       long[@SensorData + (cc*4)] := long[@SensorData + extravaroffset[cc]] ' takes care of extra var offset -- bit of a hack though
       cc++
    until cc == 27


    ' parse equations - these get parsed BEFORE an AI function so we can use them in there.
    eqr.fast
    long[constant(l#SensorDataAddress  + l#ImpatientEquation)] := eqr.ExpressionParser(@SensorData, @SensorDataDelta, @ExtraToken1, @ExtraCoeff1)
    long[constant(l#SensorDataAddress  + l#ZanyEquation)] := eqr.ExpressionParser(@SensorData, @SensorDataDelta, @ExtraToken2, @ExtraCoeff2)
    long[constant(l#SensorDataAddress  + l#_tracking)] := eqr.ExpressionParser(@SensorData, @SensorDataDelta, @TrackToken1, @TrackCoeff1)
    eqr.slow



     if AIState <> AIState_next 

       aistxxx := 32
       com0.str(@ais1str)
       com0.str(fto.dec(AIState))
       com0.str(@isnostr)
       com0.str(fto.dec(AIstate_next))
       aistxxx~
       com0.crlf
       AIState_last := AIState ' only updates upon change
       AIState := AIstate_next

     turncount++
     if AItype <> AItype_last  ' may be used in AI function
        turncount~
        
    
     case AItype
'      AITYPE_NONE:        AItype~ ' no ops for basic nav
      AITYPE_BOAT:        aifunction_etracboat
'      AITYPE_BOATCHEAT:   aifunction_pwrboat
'      AITYPE_PLANE:       aifunction_plane
'      AITYPE_CAR:         aifunction_car
'      AITYPE_PLANE_INIT:  aifunction_plane_INIT ' we need an extra INIT class for all the others?
'      AITYPE_PLANE_SIM:   aifunction_plane_SIM ' Why do we have 3 functions for the plane?
      
      other:              AItype~ 'aifunction_generic

     AItype_last := AItype

    ' Save old servo values
    longmove(@SensorData + l#OldSer1Val, @ServoValF, 4)

    ' parse equations - these get parsed AFTER an AI function to make use of it.
    eqr.fast
    ServoValF[SERVO1] := eqr.ExpressionParser(@SensorData, @SensorDataDelta, @ServoToken1, @ServoCoeff1)         
    ServoValF[SERVO2] := eqr.ExpressionParser(@SensorData, @SensorDataDelta, @ServoToken2, @ServoCoeff2)
    ServoValF[SERVO3] := eqr.ExpressionParser(@SensorData, @SensorDataDelta, @ServoToken3, @ServoCoeff3)
    ServoValF[SERVO4] := eqr.ExpressionParser(@SensorData, @SensorDataDelta, @ServoToken4, @ServoCoeff4)
    eqr.slow

    ' Actually update the servos
    UpdateServos

    'lastwayp := long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)] ' not quite used yet
    
    long[(@SensorData + l#GPSTimeReceive)]~                       ' housekeeping to make sure we only run this when needed
    aitime := long[constant(l#SensorDataAddress  + l#GPSTime)]    ' housekeeping to make sure we only run this when needed
    linecnt~  ' GPS is happy, so reset lines
    
    if (DoTelemetry)
        XmitTelemetry
    return true

pri UpdateServos | cc 

  repeat cc from 0 to 3 
     ServoValI[cc] := ServoAdd+m.fround(m.fmul(ServoMul,m.fmul(ServoAmplitude[cc],ServoValF[cc])))

  SERVO.Set(Servo1Out, ServoValI[SERVO1])'ServoCenter[SERVO1] + ServoValI[SERVO1])   
  SERVO.Set(Servo2Out, ServoValI[SERVO2])'ServoCenter[SERVO2] + ServoValI[SERVO2])
  SERVO.Set(Servo3Out, ServoValI[SERVO3])'ServoCenter[SERVO3] + ServoValI[SERVO3])
  SERVO.Set(Servo4Out, ServoValI[SERVO4])'ServoCenter[SERVO4] + ServoValI[SERVO4])
  
pri SechoCondition(num)
      if (aitime // 100 < num)
        if (long[(@SensorData + l#GPSTime)] // 100 => num)
           'com0.str(string("m",13,10))
           return 1
      return 0

pri XmitTelemetry | stroffset, tempvar

      if xmit_tele
         

       if (gecho)
         secho~ ' we can only do one telemetry or the other people... 
         if (gecho <> 255)
             gecho--

         'repeat 3        ' allow use for standard GPS tracking, too!
         ' com0.tx(":")   ' allow use for standard GPS tracking, too!
         
         com0.str(@gpsstring)
         xmit_tele~
        
       elseif (secho)
         gecho~ ' we can only do one telemetry or the other people... 
        
        ' we need a dynamic tele string here. srsly. 

         bytefill(@telestring," ",63)
         bytefill(@telestring,"!",3)
         byte[@telestring + 63]~
         stroffset := 3
         stroffset := TeleXmit(stroffset,l#Heading,"h")
'         bytemove(@telestring+stroffset, fto.FloatToFormat(m.fmul(m.FCircleAngle(long[@SensorData + l#Heading]), 10.0), 5, 0), 6)
'         telestring[stroffset] := "h"
'         stroffset += 5 


         ' this needs a case statement and an actual parser for the telemetry string, I think...

         stroffset := TeleXmit(stroffset,l#_Tracking,"b")
         stroffset := TeleXmit(stroffset,l#cur_Speed,"s")
         stroffset := TeleXmit(stroffset,l#Alt,"a")
         stroffset := TeleXmit(stroffset,l#WindDir,"w")
         stroffset := TeleXmit(stroffset,l#Distance,"d")
         stroffset := TeleXmit(stroffset,l#GPSTracking,"t")
{
         stroffset := TeleXmit(stroffset,l#SonarL,"x") ' must be made dynamic!
         stroffset := TeleXmit(stroffset,l#SonarR,"y")  ' must be made dynamic!
         stroffset := TeleXmit(stroffset,l#Compass,"z")       ' must be made dynamic!
}

         stroffset := TeleXmit(stroffset,l#XX,"x") 'SonarL,"x") ' must be made dynamic!
         stroffset := TeleXmit(stroffset,l#YY,"y") 'SonarL,"x") ' must be made dynamic!
         stroffset := TeleXmit(stroffset,l#ZZ,"z") 'SonarL,"x") ' must be made dynamic!

{
         stroffset := TeleXmit(stroffset,((extravaroffset0])),"x") 'SonarL,"x") ' must be made dynamic!
         stroffset := TeleXmit(stroffset,((extravaroffset1])),"y") 'SonarL,"x") ' must be made dynamic!
         stroffset := TeleXmit(stroffset,((extravaroffset2])),"z") 'SonarL,"x") ' must be made dynamic!
}
         stroffset := TeleXmit(stroffset,l#lat,"I")
         stroffset := TeleXmit(stroffset,l#lon,"J")

        ' special case, only 2 digits for the navpoint
         if (fto.Contains(@TelemetryType,"n") > -1)' > 0)
            telestring[stroffset++] := "n"
            telestring[stroffset++] := (long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]  / 100) + "0"
            telestring[stroffset++] := ((long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)] / 10) // 10) + "0"
            telestring[stroffset++] := ((long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]) // 10) + "0"

            


         bytemove(@telestring+stroffset, @crlfstr, 5)
'         telestring[stroffset++] := 32
'         telestring[stroffset++] := 32
'         telestring[stroffset++] := 13
'         telestring[stroffset++] := 10
'         telestring[stroffset]~  

         com0.str(@telestring)
         xmit_tele~
           


pri TeleXmit(stringoffset, whattosend, letter)
    if fto.upcase(letter) == letter  ' it's binary
         if (fto.Contains(@TelemetryType, letter) > -1)
            telestring[stringoffset] := (letter & $FF)
            bytemove(@telestring+stringoffset+1,fto.EncodeLong(long[@SensorData + whattosend]), 5) ', INUM),5) 
            return stringoffset + 6
         else
            return stringoffset
    else ' it's ascii
         if (fto.Contains(@TelemetryType, letter) > -1)
            'fto.fast
'            bytemove(@telestring+stringoffset, fto.FloatToFormat(m.fmul((long[@SensorData + whattosend]), 10.0), 5, 0), 6)
            bytemove(@telestring+stringoffset, fto.FloatToFormat(m.fmul(m.FCircleAngle(long[@SensorData + whattosend]), 10.0), 5, 0), 6)
            telestring[stringoffset] := (letter & $FF)
            'fto.init
            return stringoffset + 5 
         else
            return stringoffset
            {
pri TeleBinary(stringoffset, whattosend, letter)
         if (fto.Contains(@TelemetryType, letter))
           telestring[stringoffset] := (letter & $FF)
           bytemove(@telestring+stringoffset+1,fto.EncodeLong(long[@SensorData + whattosend]), 5) ', INUM),5) 
           return stringoffset + 6
         else
            return stringoffset
            }
         
         
PRI arrived(multiplier)
return m.fcmpi(long[constant(l#SensorDataAddress  + l#Distance)], LESSTHAN, m.fmul(long[constant(l#SensorDataAddress  + l#ArrivalDistance)],multiplier))

PRI UpdateRoute | tempvar, arewethereyet

   if not (long[constant(l#SensorDataAddress  + l#lat)] and long[constant(l#SensorDataAddress  + l#lon)])
     return false
   arewethereyet := arrived(1.0)


' Changes waypoint depending on route. DEVNOTE_MKB: See a note above for what to do when the com0 has to xmit something!
    tempvar := 1
    if (flag_routeon)
'                             flag_routeon := fto.Upcase(executestring[2]) - "A" ' so 1 for B, 14 for O and 15 for P

      if arewethereyet and long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)] == routeend
         case  flag_routeon
           1:
               com0.str(@rttpstr)'string(":::Route finished!",13,10))
               com0.str(@rtt1str)
               com0.crlf'string(":::Route finished!",13,10))
               flag_routeon~  ' end route
           14:
               i2c.LogWaypoint(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)])
               com0.str(@wlogstr)
               com0.str(fto.dec(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]))

               com0.str(@rttpstr)'string(":::Route finished!",13,10))
               com0.str(@rtt14st)
               com0.crlf'string(":::Route finished!",13,10))
               i2c.PreloadWaypoint(routestart) ' circular route: try to go back to start
               wayp_temp := routestart
               com0.str(@routstr)'string(":::Route circling around!",13,10))
               return
           15:
               i2c.LogWaypoint(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)])
               com0.str(@wlogstr)
               com0.str(fto.dec(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]))

               com0.str(@rttpstr)'string(":::Route finished!",13,10))
               com0.str(@rtt15st)
               com0.crlf'string(":::Route finished!",13,10))
               tempvar := routestart
               routestart := routeend
               routeend := tempvar
               if (routestart > routeend)
                  wayp_temp--
               else
                  wayp_temp++ 
               com0.str(string(":::Route ping-ponging!",13,10))
               return
           other:
               flag_routeon := 1
      if ((routestart <> routeend) and (long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)] <> routeend) and (routeend <> -1) and (routestart <> -1) and arewethereyet)
       if (routestart > routeend)
          tempvar := -1
       repeat
           i2c.LogWaypoint(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)])
           com0.str(@wlogstr)
           com0.str(fto.dec(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]))
           i2c.PreloadWaypoint(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)] + tempvar)
           wayp_temp := long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]
           com0.str(string(". Selecting next waypoint: "))
           com0.str(fto.dec(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]))
           com0.crlf
           flag_routeupdated~~ ' used by the AI function: do NOT reset until the AI function acknowledges it
       until (!arewethereyet or (long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)] == routeend) or (i2c.GetWaypointLat(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]) <> INVALIDCOORD) or (i2c.GetWaypointLon(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]) <> INVALIDCOORD))


       return true
       
    else
      if arewethereyet
        if not curwplogged
         i2c.LogWaypoint(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)])
         com0.str(@wlogstr)
         com0.str(fto.dec(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]))
         com0.crlf
         curwplogged~~
      else
          curwplogged~
    return false  




PRI ParseCommandString | char_in 'ComStringAddr, char_in

'' primitive command parser
'' commands are always shaped thus:
'' <atsign> <letter> <letter> <integer> <comma> <integer> <cr> <lf>
'' first letter is what command list it belongs to, second letter is what it is, then argument(s).

' DEVNOTE_MKB: PLEASE read this and tell me if it makes sense! I suck at interfaces!

 '

  'ComStringAddr := @commandstring


 ' if we use the same buffer for command & rxcheck, can we just parse it and flush it after execution/copy?
 
    ' now parse
  byte[@commandstring + CmdStrLength]~ ' := 0
  repeat
     char_in := com0.rxcheck
   case char_in

      -1: return false

      10: if byte[@commandstring + commandptr] <> 13 and commandptr > 2 ' intercept CRLFs
            byte[@commandstring + commandptr]~
            ExecuteCommand(@commandstring)       
            commandptr~~' := -1 ' rolls over to zero later
            bytefill(@commandstring, 0, CmdStrLength)


      ' new jog comamnd
      "0".."9": if commandptr < 2
                                                commandptr~~
                                                bytefill(@commandstring,0,CmdStrLength)
                                                DirectControlTimer~
                                                DirectControlStatus++
                                                if (DirectControlStatus == 6)
                                                   DirectControlStatus := 1
                                                   byte[@dir2str] := "K" ' echo an acknowledgement every once in a while
                                                   com0.str(@direstr)
                                                   
                                                char_in -= "0" ' for use with lookup table below
                                                                                         '0   1   2   3   4   5   6   7   8   9
                                                DirectControlForward := lookupz (char_in: 1, -2, -2, -2,  0,  0,  0,  2,  2,  2)
                                                DirectControlRight   := lookupz (char_in: 0,  1,  0, -1,  1,  0, -1,  1,  0, -1)
                else
                                                byte[@commandstring + commandptr++] := (char_in)

      other:

        if (echo)        
            com0.tx(char_in)'com0.str(fto.dec(char_in))

       byte[@commandstring + commandptr] := char_in & $FF
       
       if (byte[@commandstring + commandptr] == 08)    ' backspace case -- needs to clean up cmdline
           repeat 2
              byte[@commandstring + commandptr--] := " "      ' backspace

       if ((commandptr == constant(CmdStrLength-1)) or (byte[@commandstring + commandptr] == 13) or (byte[@commandstring + commandptr] == 0))
         byte[@commandstring + commandptr]~
         ExecuteCommand(@commandstring)
         commandptr~~' := -1 ' rolls over to zero later
         bytefill(@commandstring, 0, CmdStrLength)
         
       ++commandptr ' := commandptr + 1

       
pri ExecuteCommand(CommandStringAddr) : offset | tempvar, cmderr, tempvar2, tempvar3, tempvar4, tempvar5

         'l.serialxmit(30,9600,CommandStringAddr)
         offset~
         cmderr~
         bytemove(@executestring, CommandStringAddr, strsize(CommandStringAddr)+1)
          
         if (executestring[0] == "@")

           repeat 3
              com0.tx(":")

          case fto.Upcase(executestring[1])

             "@": 
                  repeat until executestring[++offset] <> "@"   ' prevents blowing the stack through recursion 
                  return ExecuteCommand(CommandStringAddr + --offset)   

             "!": 
                  tempvar := long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]
                  if (++wayp_temp < -1)
                     i2c.PreloadWaypoint(tempvar)'curwayp := tempvar
                  if (wayp_temp > constant(NumWaypoints-1))
                     i2c.PreloadWaypoint(1)'curwayp := 1
                  CallUpdateWaypoint(@stoqstr,true)

          ' Engages HP calculator emulator ;) prints result on com0
             "?":
                  executestring[0] := " "
                  executestring[1] := " "
                  com0.str(string("Result = "))
                  com0.str(fto.FloatToFormat(eqr.ExpressionParserRPN(@executestring, @SensorData, @SensorDataDelta, false),11,3))

          ' Syntax as above: usage @E1 @E2 @E3 @E4 -- sets an equation for this or that servo. CAREFUL WITH THIS! NO ERROR CHECKING!
          ' @EX will put an equation in the "temp" slot, @E1 @E2 @E3 @E4 saves it in the appropriate place.
             "E":', "e":
               tempvar := fto.upcase(executestring[2])

               bytefill(@executestring, " ",3) ' prefills exe[0][1][2] to make sure they don't get in the way of the parser later
               
               executestring[constant(CmdStrLength - 1)]~' := 0

               case (tempvar)

                 ' print stuff
                "P":
                     preqstr[11] := executestring[3]
                     com0.str(@preqstr)
                     case(fto.upcase(executestring[3]))
                        "1"     :tempvar := (@ServoEquation1+1)
                        "2"     :tempvar := (@ServoEquation2+1)
                        "3"     :tempvar := (@ServoEquation3+1)
                        "4"     :tempvar := (@ServoEquation4+1)
                        "T"     :tempvar := (@TrackEquation+1)
                        "X"     :tempvar := (@ExtraEquation1+1)
                        "Y"     :tempvar := (@ExtraEquation2+1)
                        "B"     :fto.FloatToFormat(long[constant(l#SensorDataAddress  + l#Battery)],8,3)
                                 tempvar := (fto.last)
                        "G"     :tempvar := (@gpsstring)
                        "S"     :tempvar := (@telestring)
                        "E"     :tempvar := (sensor.debug)  ' last received sensor string
                        "V","M","Q","P"     :tempvar := (@crlfstr) ' multiline output
                        other   :tempvar := (string("N/A"))
                     com0.str(tempvar~)

                     case(fto.upcase(executestring[3]))
                      "Q":
                     'if fto.upcase(executestring[3]) == "Q"   ' servo outputs in microseconds
                        repeat 4
                          com0.str(fto.dec(ServoValI[tempvar++]))
                          com0.tx("|")
                        com0.crlf
                        

'                     if fto.upcase(executestring[3]) == "M"    ' print current stack usage
                      "M":
                       com0.str(string("M:"))
                       com0.str(fto.dec(stak.GetLength))
                       com0.str(string("  G:"))
                       com0.str(fto.dec(gps.GetStackLength))
                       com0.str(string("  S:"))
                       com0.str(fto.dec(sensor.GetStackLength))
                       com0.crlf
                       
                     'if fto.upcase(executestring[3]) == "V"    ' print current variable status for all variables A to Z
                      "V":
                       tempvar := "A"
                       repeat 26
                          repeat 3
                             com0.tx(":")
                          com0.tx(tempvar)
                          com0.str(@isn2str)
                          com0.str(fto.FloatToFormat(long[constant(l#SensorDataAddress  + l#AA)+((tempvar-"A")*4)],8,3))
                          tempvar++
                          com0.crlf
                       com0.crlf

                      "P":
                       tempvar~
                       repeat 31
                        com0.tx(ina[tempvar++]+"0")
                       com0.crlf 

                 ' parse/tokenize equations for future use
                
                "1":      CopyEquation(@ServoEquation1, @ServoToken1, @ServoCoeff1, tempvar)      
                "2":      CopyEquation(@ServoEquation2, @ServoToken2, @ServoCoeff2, tempvar)      
                "3":      CopyEquation(@ServoEquation3, @ServoToken3, @ServoCoeff3, tempvar)      
                "4":      CopyEquation(@ServoEquation4, @ServoToken4, @ServoCoeff4, tempvar)      

                "T":      CopyEquation(@TrackEquation,  @TrackToken1, @TrackCoeff1,  tempvar)
                "X":      CopyEquation(@ExtraEquation1,  @ExtraToken1, @ExtraCoeff1,  tempvar)
                "Y":      CopyEquation(@ExtraEquation2,  @ExtraToken2, @ExtraCoeff2,  tempvar)


                other: cmderr~~        



          ''WS command: @WXX or @WX sets active waypoint. Also, if that waypoint is
          ''not defined, set it to current. This allo easy basic navigation.
           
             "W":'waypoint
              tempvar := fto.Upcase(executestring[2])
              case tempvar
               "P","S": ' pick waypoint  - S set waypoint to current position
                 com0.tx("S")
                 'com0.str(@sel2str)
                 wayp_temp := ParseExecutestring(INUM, @atwxstr, long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)], 0, constant(NumWaypoints-1), 4, 0)
                 com0.str(@dashstr)
                 CallUpdateWaypoint(@stocstr, (tempvar == "S") )

                 
               "C":' enter waypoint coordinates by hand for current waypoint
                 com0.tx("W")
                 com0.str(@waypstr)
                 tempvar := ParseExecutestring(INUM, @latstr, i2c.GetWaypointLat(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]), -99999999, 99999999, 12, 4)
                 com0.crlf
                 com0.str(string(":::"))
                 tempvar2 := ParseExecutestring(INUM, @lonstr, i2c.GetWaypointLon(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]), -99999999, 99999999, 12, 4)
                 i2c.WriteWaypoint(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)], tempvar, tempvar2) 


               "W":' same as C but also reads waypoint number and returns short output; used by the console when doing KML -> waypoint series
                 tempvar3 := ParseParameterEchoBack~
                 wayp_temp := ParseExecuteString(INUM, 0 , long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)], 0, constant(NumWaypoints-1), 4, 0)
                 tempvar := ParseExecuteString(INUM, @latstr, i2c.GetWaypointLat(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]), -99999999, 99999999, 12, 4)
                 tempvar2 := ParseExecuteString(INUM, @lonstr, i2c.GetWaypointLon(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]), -99999999, 99999999, 12, 4)
                 i2c.WriteWaypoint(wayp_temp, tempvar, tempvar2)
                 com0.str(string("Read WP "))
                 com0.str(fto.dec(wayp_temp))
                 ParseParameterEchoBack := tempvar3
                   

               "I": ' same as C but using float degrees
                 if (fto.ParseNextInt(@executestring, @tempvar2) and fto.ParseNextInt(@executestring, @tempvar3) and fto.ParseNextInt(@executestring, @tempvar4) and fto.ParseNextInt(@executestring, @tempvar5)) 

                      com0.str(@waypstr)
                      com0.str(@latstr)
                      com0.str(@was_str)
                      com0.str(fto.indecdegrees(i2c.GetWaypointLat(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)] )))
                      com0.str(@isnostr)
                      tempvar2 *= constant(60*10_000)
                      tempvar := 1
                      repeat
                        tempvar *= 10
                      until tempvar > tempvar3
                      case tempvar
                           1 : tempvar2 += (tempvar3 * 60 * 1000)
                          10 : tempvar2 += (tempvar3 * 60 * 100)
                         100 : tempvar2 += (tempvar3 * 60 * 10)
                        1000 : tempvar2 += (tempvar3 * 60)
                       10000 : tempvar2 += (tempvar3 * 6)
                       other : tempvar2 += (tempvar3 * 3 / 5)
                      com0.str(fto.indecdegrees(tempvar2))  
                      
                      com0.str(string(13,10,":::"))
                      com0.str(@waypstr)
                      com0.str(@latstr)
                      com0.str(@was_str)
                      com0.str(fto.indecdegrees(i2c.GetWaypointLon(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)] )))
                      com0.str(@isnostr)
                      tempvar2 *= constant(60*10_000)
                      tempvar := 1
                      repeat
                        tempvar *= 10
                      until tempvar > tempvar3
                      case tempvar
                           1 : tempvar2 += (tempvar3 * 60 * 1000)
                          10 : tempvar2 += (tempvar3 * 60 * 100)
                         100 : tempvar2 += (tempvar3 * 60 * 10)
                        1000 : tempvar2 += (tempvar3 * 60)
                       10000 : tempvar2 += (tempvar3 * 6)
                       other : tempvar2 += (tempvar3 * 3 / 5)
                      com0.str(fto.indecdegrees(tempvar2))  
                      

               "V": if not (fto.ParseNextInt(@executestring, @tempvar2))' tell if waypoint X has been visited (logged) or not
                         tempvar2 := curwayp
                    tempvar3 := long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]
                    com0.str(string("WP "))
                    com0.str(fto.dec(tempvar2))
                    com0.str(string(" has "))
                    if not (i2c.waypointvisited(tempvar2))
                        com0.str(string("not "))
                    com0.str(string("been visited"))
                    i2c.preloadwaypoint(tempvar3)    
                    

               
               "L","E","G": ' waypoint list in various formats
                 tempvar2 := long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]
                 tempvar3~ ' tempvar is the letter
                 tempvar4~
                 tempvar5 := curwayp
                 com0.str(@wlisstr)
                 com0.crlf'string(":::Waypoint List :",13,10))
                 if tempvar == "G"
                    com0.tx("<")
                    com0.str(@kml_str)
                 repeat
                  wayp_temp := tempvar5
                  i2c.PreloadWaypoint(tempvar2)
                  MainAIFunction((tempvar <> "G") and tempvar4)
                  tempvar4 := i2c.GetWaypointLat(tempvar3) <> INVALIDCOORD
                  if (tempvar4)

                    case tempvar
                     "L":  ' List waypoints with decimal degrees
                       com0.str(string("::: "))
                       com0.str(fto.dec(tempvar3))
                       com0.str(string(" -> "))
                       if (i2c.waypointvisited(tempvar3))
                         com0.str(fto.indecdegrees(i2c.GetWaypointData(tempvar3,i2c#ReachedLat)))'GPS)]))                                                   
                         com0.tx(" ")
                         com0.str(fto.indecdegrees(i2c.GetWaypointData(tempvar3,i2c#ReachedLon)))'GPS)]))
                         com0.tx(" ")
                         com0.str(fto.FloatToFormat(i2c.GetWaypointData(tempvar3,i2c#ReachedAlt),8,2))'GPS)]))
                       else
                         com0.str(fto.indecdegrees(i2c.GetWaypointLat(tempvar3)))'GPS)]))                                                   
                         com0.tx(" ")
                         com0.str(fto.indecdegrees(i2c.GetWaypointLon(tempvar3)))'GPS)]))
                         com0.tx(" ")
                         com0.tx("?")
                         
                     "G":  ' List waypoints with decimal degrees and XML tags (to turn a log file into a KML)
                       if (i2c.waypointvisited(tempvar3))
                         com0.str(fto.indecdegrees(i2c.GetWaypointData(tempvar3,i2c#ReachedLon)))'GPS)]))                                                   
                         com0.str(@spacstr)
                         com0.str(fto.indecdegrees(i2c.GetWaypointData(tempvar3,i2c#ReachedLat)))'GPS)]))
                         com0.str(@spacstr)
                         com0.str(fto.FloatToFormat(i2c.GetWaypointData(tempvar3,i2c#ReachedAlt),8,2))'GPS)]))
                         com0.tx(" ")
                       else
                         com0.str(fto.indecdegrees(i2c.GetWaypointLon(tempvar3)))'GPS)]))                                                   
                         com0.str(@spacstr)
                         com0.str(fto.indecdegrees(i2c.GetWaypointLat(tempvar3)))'GPS)]))
                         com0.str(string(",-800000.0"))
                         
                     "E":  ' List waypoints with internal format
                       com0.str(string("::: "))
                       com0.str(fto.dec(tempvar3))
                       com0.str(string(" -> "))
                       if (i2c.waypointvisited(tempvar3))
                         com0.str(fto.dec(i2c.GetWaypointData(tempvar3,i2c#ReachedLat)))'GPS)]))                                                   
                         com0.tx(" ")
                         com0.str(fto.dec(i2c.GetWaypointData(tempvar3,i2c#ReachedLon)))'GPS)]))
                         com0.tx(" ")
                         com0.str(fto.FloatToFormat(i2c.GetWaypointData(tempvar3,i2c#ReachedAlt),8,2))'GPS)]))
                       else
                         com0.str(fto.dec(i2c.GetWaypointLat(tempvar3)))'GPS)]))                                                   
                         com0.tx(" ")
                         com0.str(fto.dec(i2c.GetWaypointLon(tempvar3)))'GPS)]))
                         com0.tx(" ")
                         com0.tx("?")
                         
                    com0.crlf
                    com0.txwait    
                    linecnt++'= 1
                 until (tempvar3++ == constant(NumWaypoints-1))
                 
                 i2c.PreloadWaypoint(tempvar2) ' as a restore action

                 ' close xml tag
                 if tempvar == "G"
                    com0.tx("<")
                    com0.str(@kml1str)
                 byte[@wli2str] := " "
                 com0.str(@wlisstr)
                 byte[@wli2str]~

               "M","D":', waypoint display in milliminutes

                fto.ParseNextInt(@executestring,@tempvar)'ParseExecutestring(INUM, @latstr, 0, -99999999, 99999999, 12, 4)

                if tempvar == 0 or IsTerminator(executestring[3]) or IsTerminator(executestring[4])
                 com0.str(string("Coords to here -> @W"))
                 if fto.upcase(executestring[2]) == "M"
                   com0.tx("C")
                   com0.tx(" ")
                   com0.str(fto.dec(long[constant(l#SensorDataAddress  + l#lat)]))'GPS)]))                                                   
                   com0.tx(" ")
                   com0.str(fto.dec(long[constant(l#SensorDataAddress  + l#lon)]))'GPS)]))
                 else  
                   com0.tx("I")
                   com0.tx(" ")
                   com0.str(fto.indecdegrees(long[constant(l#SensorDataAddress  + l#lat)]))'GPS)]))                                                   
                   com0.tx(" ")
                   com0.str(fto.indecdegrees(long[constant(l#SensorDataAddress  + l#lon)]))'GPS)]))
                 
                else
                 tempvar2 := long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)] 
                 com0.str(string("Coords for WP "))
                 com0.str(fto.dec(tempvar))
                 com0.str(string(" -> "))
                 if (i2c.GetWaypointLat(tempvar) == INVALIDCOORD)
                  com0.str(string("INVALID"))
                 else
                  if fto.upcase(executestring[2]) == "M"
                    com0.str(fto.dec(i2c.GetWaypointLat(tempvar)))'GPS)]))                                                   
                    com0.tx(" ")
                    com0.str(fto.dec(i2c.GetWaypointLon(tempvar)))'GPS)]))
                  else
                    com0.str(fto.indecdegrees(i2c.GetWaypointLat(tempvar)))'GPS)]))                                                   
                    com0.tx(" ")
                    com0.str(fto.indecdegrees(i2c.GetWaypointLon(tempvar)))'GPS)]))
                 i2c.PreloadWaypoint(tempvar2)

               other: cmderr~~
               
           '' variable-assign command: assigns a variable to a memory map address
             "V":',"v":
                extvstr[9] := fto.Upcase(executestring[2])
                'tempvar := fto.Upcase(executestring[2])
                'extvstr := tempvar
              case extvstr[9]
                 "A".."Z": tempvar := extvstr[9]-"A"
                           if (executestring[3] == "~")
                             com0.str(@extvstr)
                             com0.str(string(" delinked")) 
                             extravaroffset[tempvar] := tempvar * 4
                           else
                             extravaroffset[tempvar] := ParseExecutestring(INUM, @extvstr, extravaroffset[tempvar], 0, l#LastVar, 6, 0) & $FF_FF_FF_FC

             "X": ' transmit on serial port
                  case fto.Upcase(executestring[2])
                     '"0":  l.serialxmit(Com0PinTx, COMBaud,    @executestring+3)
                     "1":  l.serialxmit(Com1PinTx, -SensorBaud, @executestring+3)
                           l.serialxmit(Com1PinTX, -SensorBaud, @crlfstr)
                     "2":  l.serialxmit(Com2PinTx, -SensorBaud, @executestring+3)
                           l.serialxmit(Com2PinTx, -SensorBaud, @crlfstr)
                     "3":  l.serialxmit(Com3PinTx, -SensorBaud, @executestring+3)
                           l.serialxmit(Com3PinTx, -SensorBaud, @crlfstr)
                     "4":  l.serialxmit(Com4PinTx, -SensorBaud, @executestring+3)
                           l.serialxmit(Com4PinTx, -SensorBaud, @crlfstr)
                     "G":  l.serialxmit(GPS1PinTx, GPSBaud,     @executestring+3)
                           l.serialxmit(GPS1PinTx, GPSBaud,     @crlfstr)
                     "P","D":  l.serialxmit(ProgPinTx, 9600,   @executestring+3)
                               l.serialxmit(ProgPinTx, 9600, @crlfstr)
                     other: executestring[2] := "_"
                  byte[@xmi2str] := executestring[2]
                  com0.str(@xmitstr)             
                  com0.str(@executestring+3)
                  com0.crlf
                 
          '' telemetry config
             "T":',"t":

              com0.str(string("Telemetry: "))
              case fto.Upcase(executestring[2])

 
               

                  'l.serialxmit(30,9600,executestring+3)

               
               "S":',"s":
                'com0.str(string("Serial "))      ' Code used to have video telemetry output: removed b/c of no use on autonomous vehicle
                case fto.Upcase(executestring[3])

                 "N":',"n":
                      com0.str(string("NAV o"))
                      if (executestring[4] < " " and secho) ' keep toggle
                        secho~
                        repeat 2
                          com0.tx("f")
                      else
                        com0.tx("n")
                        secho := 1
                        if (executestring[5] > constant("0"-1) and executestring[5] < constant("6"))
                            executestring[4] := executestring[5]
                        if (executestring[4] > constant("0"-1) and executestring[4] < constant("6"))
                            secho := executestring[4] - "0"
                            com0.tx("*")
                            com0.tx(executestring[4])
                        if (executestring[5] == "X")
                            secho := 1000
                            repeat 4
                              com0.tx("*")
                            com0.crlf  
                            com0.crlf
                            gecho~
                            waitcnt(100_000 + cnt) ' avoids confusing this last com packet with next nav packet
                            return offset  
                        gecho~
                        
                 "S":',"s":
                          com0.str(string("string was "))
                          com0.str(@TelemetryType)
                          com0.str(@isnostr)
                          if not (IsTerminator(executestring[4]) or IsTerminator(executestring[5]))
                              bytemove(@TelemetryType,@executestring+4, 14)
                          com0.str(@TelemetryType)
                          com0.crlf

                 "G":',"g":
                   com0.str(string("GPS o"))
                   gecho := NOT gecho
                   if executestring[4] == "1" or executestring[5] == "1"
                       gecho~~
                   if executestring[4] == "0" or executestring[5] == "0"
                       gecho~
                   if (gecho)
                      com0.tx("n")
                      secho~
                      gecho := 255
                   else
                      repeat 2
                          com0.tx("f")
                      gecho~

                 "O":',"o":
                      com0.str(@offstr)
                      gecho~
                      secho~


                 other: com0.str(@nochstr)
                        cmderr~~ 
                      
               other:
                       com0.str(@nochstr)
                       cmderr~~

          '' setup commands

             "S":',"s":
              case fto.Upcase(executestring[2])

               "E":',"e":
                   
                   if (!echo)
                        byte[@ech2str] := "f" 
                        byte[@ech3str] := "f"
                   else
                        byte[@ech2str] := "n" 
                        byte[@ech3str] := " "
                   com0.str(@echostr)
                                                     
                   


               "A":
                case fto.Upcase(executestring[3])
                
                 "F": com0.str(@amulstr)
                      long[constant(l#SensorDataAddress  + l#AltitudeMultiplier)] := 1.0
                      com0.str(string(": feet"))
                 "M": long[constant(l#SensorDataAddress  + l#AltitudeMultiplier)] := l#feettometers
                      com0.str(@amulstr)
                      com0.str(string(": meters"))
                 other: long[constant(l#SensorDataAddress  + l#AltitudeMultiplier)] := m.fmul(ParseExecutestring(EXPR, @amulstr, long[constant(l#SensorDataAddress  + l#AltitudeMultiplier)], 0.0, 100.0, 10, 6),1000.0)
{
' uncomment if you want to calibrate the battery sensor!
               "B":
                 long[constant(l#SensorDataAddress  + l#BatteryMultiplier)] := ParseExecutestring(EXPR, string("Batt multiplier "), long[constant(l#SensorDataAddress  + l#BatteryMultiplier)], 0.0, 90.0, 8, 4)   '' SI capped at 25, theoretical maximum 29 but let's be paranoid
}               
               "G":
                 long[constant(l#SensorDataAddress  + l#NROTDeadZone)] := ParseExecutestring(EXPR, string("Gyro deadzone "), long[constant(l#SensorDataAddress  + l#NROTDeadZone)], 0.0, 90.0, 6, 2)   '' SI capped at 25, theoretical maximum 29 but let's be paranoid

               "I":
                 intr_temp := ParseExecutestring(INUM, string("Interp rounds/sec "), interpolationrounds, InterpLimitL, InterpLimitH, 2, 0)   '' SI capped at 25, theoretical maximum 29 but let's be paranoid

               "P":
                 long[constant(l#SensorDataAddress  + l#PredictionFrames)] := ParseExecutestring(EXPR, string("Prediction frames "), long[constant(l#SensorDataAddress  + l#PredictionFrames)], 0.0, interpolationroundsF, 5, 2)   '' SI capped at 25, theoretical maximum 29 but let's be paranoid

               "A":
                 ServoAdd := ParseExecutestring(INUM, string("Servo add "), ServoAdd, 0, 5000, 9, 0)   '' SI capped at 25, theoretical maximum 29 but let's be paranoid

               "M":    
                 ServoMul := ParseExecutestring(EXPR, string("Servo mul "), ServoMul, 0.0, 2000.0, 8, 1)   '' SI capped at 25, theoretical maximum 29 but let's be paranoid

               "C":
                    long[constant(l#SensorDataAddress  + l#CompassTrim)] := ParseExecutestring(EXPR, string("Compass trim "), long[constant(l#SensorDataAddress  + l#CompassTrim)], -180.0, 180.0, 8, 2)   '' SI capped at 25, theoretical maximum 29 but let's be paranoid

               "K":
                    long[constant(l#SensorDataAddress  + l#CompassMultiplier)] := ParseExecutestring(EXPR, string("C-H interp mult "), long[constant(l#SensorDataAddress  + l#CompassMultiplier)], 0.0, 20.0, 8, 2)   '' SI capped at 25, theoretical maximum 29 but let's be paranoid

               "L":
                    long[constant(l#SensorDataAddress  + l#HeadTre)] := ParseExecutestring(EXPR, string("COG ignore speed "), long[constant(l#SensorDataAddress  + l#HeadTre)], 0.0, 99.9, 8, 2)   '' SI capped at 25, theoretical maximum 29 but let's be paranoid

               "H":
                    long[constant(l#SensorDataAddress  + l#COGTre)] := ParseExecutestring(EXPR, string("Compass sync speed "), long[constant(l#SensorDataAddress  + l#COGTre)], 0.0, 99.9, 8, 2)   '' SI capped at 25, theoretical maximum 29 but let's be paranoid

               "S":
                    repeat 10
                       long[constant(l#SensorDataAddress  + l#Heading)] := long[constant(l#SensorDataAddress  + l#Compass)] 
                       waitcnt(cnt + 5_000)
                    com0.str(string("C-H synced"))
                    
               other: cmderr~~


              
           ' Select AI type or state (aka force the state machine to change state)
             "A":',"a":
              case executestring[2]
{
               "L","l":
                  com0.str(string("Last "))
                  AIState_last := ParseExecutestring(INUM, @aiststr, AIState_last, 0, 255, 4, 0)
               "S","s":
                  AIState := ParseExecutestring(INUM, @aiststr, AIState, 0, 255, 4, 0)
}
               "N","n":
                  com0.str(string("Next "))
                  AIState_next := ParseExecutestring(INUM, @aiststr, AIState_next, 0, 255, 4, 0)

               "I","i":
                  tempvar := AIType
                  AIType := ParseExecutestring(INUM, string("AI type "), AIType, 0, 255, 4, 0)
                  AIType_last := tempvar

             ' Fudge factors / force a variable to a value
             "F":',"f":
              fudstr[6] := executestring[2]
              case executestring[2]
                "1".."4": executestring[2] := " "
                     ServoAmplitude[(fudstr[6] - "1")] := ParseExecutestring(EXPR, @fudstr, ServoAmplitude[(fudstr[6] - "1")], -2.0, 2.0, 6, 3)

                "A".."Z":
                     extvstr[9] := executestring[2]
                     extvstr[10]~
                     tempvar := (extvstr[9] - "A") * 4
                     'executestring[2] := " "
                     long[@SensorData + tempvar] := ParseExecutestring(EXPR, @extvstr, long[@SensorData + tempvar],  -100000.0, 100000.0, 8, 3)
                     long[@SensorData + extravaroffset[(tempvar/4)]] := long[@SensorData + tempvar]
                     
                     extvstr[10] := " "
                     
                {
                "a".."z":
                     vardstr[4] := executestring[2]
                     'executestring[2] := " "
                     tempvar := (vardstr[4] - "a") * 4
                     long[@SensorDataDelta + tempvar] := ParseExecutestring(EXPR, @vardstr, long[@SensorDataDelta + tempvar],  -100000.0, 100000.0, 8, 3)
                }
                                                                                                                                                 
                other: cmderr~~

             ' Kill / initialize commands   
             "K":
              com0.str(@initstr)
              case fto.Upcase(executestring[2])
               "Y":long[constant(l#SensorDataAddress  + l#gpsstatus)] := 1.0 ' Force AI init even with invalid GPS string. WARNING, DO NOT USE OUTSIDE DEBUGGING.

               "W":  ' Empties waypoint EEPROM area
                    com0.str(@eeprstr)
                    tempvar~
                    tempvar2 := long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]
                    repeat NumWaypoints

                      i2c.EraseWaypoint(tempvar++)
                     
                     if not (tempvar // 10)
                          i2c.PreloadWaypoint(tempvar2)
                          MainAIFunction(false)
                          com0.tx(".")
                     linecnt++
                     
                    com0.str(string(13,10,":::WPs erased",13,10))    
               "S": ' Resets sensors
                   com0.str(@sensstr)
                   sensor.stop
                   com0.str(@SensorType)
                   bytefill(@sensortype, "_", 5)
                   tempvar := sensor.start (SensorBaud, BattPinRx, ADPinRx, HeadingPinRX, Sensor1Rx, Sensor2Rx, Sensor3Rx, Com1PinRx, Com2PinRx, Com3PinRx, Com4PinRx, @SensorType)
               "G": ' Resets GPS/interpolator 
                   com0.str(string("GPS "))
                   gps.stop
                   case executestring[3]
                        "0".."7" : tempvar4 := executestring[3]-"0"
                        {
                        byte 0: distance geodesy/flat
                        byte 1: heading geodesy/flat
                        byte 2: logging on/off

                        default: geodesy full on, logging off (why?)
                        }       
                        other:
                              tempvar4 := 3
                              executestring[3] := "3" '"7" Do not default SD logging yet.

                   tempvar := gps.start(-1, GPS1PinRx, GPSBaud, @SensorDataLast, @SensorDataDelta, @interpolationrounds, @gpsstring,tempvar4)
                   com0.tx(executestring[3])                                                
                   
               "V": ' Resets servos
                   com0.str(string("Servos"))
                   servo.stop
                   SERVO.Set(Servo1Out,1500)
                   SERVO.Set(Servo2Out,1500)
                   SERVO.Set(Servo3Out,1500)
                   SERVO.Set(Servo4Out,1500)
                   tempvar := SERVO.Start

               "C": ' Resets comm buffer 
                   com0.stop
                   if fto.Upcase(executestring[3]) == "D"
                       tempvar := com0.start(31, 30, %0000, COMBaud) ' start com0 telemetry (and commands?)
                   else
                       tempvar := com0.start(com0PinRx, com0PinTx, COMMask, COMBaud) ' debugging radioless mode
                   bytefill(@commandstring, 0, CmdStrLength) ' used to be space, but this way it can be its own demarcator
                   commandptr~' := 0               ' Command pointer for the commandline, both for use in RX and parsing
                   com0.str(@inidstr)
                   com0.str(string("COM"))
                   
               "A": ' Restarts all 
                   com0.str(string("all! Rebooting.",13,10))
                   longmove(@ServoValI,0,8)
                   UpdateServos
                   waitcnt(40_000_000 + cnt)
                   reboot                  ' die die die!
               {
               "Z": ' emergency nuke-everything command. THIS PERMANENTLY TURNS THE AI OFF UNTIL THERE IS A POWER SWITCH. 
                   offstr[0]:="A"
                   com0.str(@offstr)
                   longmove(@ServoValI,0,8)
                   UpdateServos
                   waitcnt(40_000_000 + cnt)
                   tempvar := 8
                   repeat
                    cogstop(--tempvar)
               }
               other: cmderr~~ 
              com0.str(@inicstr)
              com0.str(fto.dec(tempvar))
              
          '' route commands, start with R     
                
          ''RD command: @DXXX or @DXX or @DX changes "arrived" distance for waypoints
             "R":',"r":
              case fto.Upcase(executestring[2])
               "D":',"d":
                 com0.str(string("Distance is "))
                 com0.str(fto.FloatToFormat(long[constant(l#SensorDataAddress  + l#Distance)],8,2))
                 long[constant(l#SensorDataAddress  + l#ArrivalDistance)] := ParseExecutestring(FNUM, string("; Arrival distance "), long[constant(l#SensorDataAddress  + l#ArrivalDistance)], 1.0, 100000.0, 7, 2)

          ''RS command: @SXXX or @SXX or @SX changes waypoint tagged as route start
               "S":',"s":
                 com0.str(@routstr)
                 com0.str(string("start "))
                 routestart := ParseExecutestring(INUM, @atwxstr, routestart, 0, constant(NumWaypoints-1), 4, 0)

          ''RE command: @EXXX or @EXX or @EX changes waypoint tagged as route start
               "E":',"e":
                 com0.str(@routstr)
                 com0.str(string("end "))
                 routeend := ParseExecutestring(INUM, @atwxstr, routeend, 0, constant(NumWaypoints-1), 4, 0)

          ''RC command: Clear route
               "C":',"c":
                 routestart~~' := -1
                 routeend~~' := -1
                 'curwayp := -1
                 flag_routeon~ ' := 0
                 com0.str(@routstr)
                 com0.str(string("cleared"))
                 
          ''RB command: Begin route. Types are B normal, P ping-pong, O circular.
               "B","P","O":',"b":
                 if (routestart <> -1 and routeend <> -1)
'                    curwayp := routestart
                    flag_routeon := fto.Upcase(executestring[2]) - "A" ' so 1 for B, 14 for O and 15 for P
                    
                    com0.str(@routstr)
                    com0.str(string("began"))
                    com0.str(@atwpstr)
                    com0.str(fto.dec(curwayp))
                    com0.str(@dashstr)
                    CallUpdateWaypoint(@stocstr, false)
                    wayp_temp := routestart'ParseExecutestring(INUM, @atwxstr, long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)], 0, constant(NumWaypoints-1), 4, 0)

                 else
                    com0.str(string("Route not defined."))
               other: cmderr~~
             other: cmderr~~

          if (cmderr)
                com0.str(@unknstr)
          
          repeat
             offset++
          until (offset > CmdStrLength or byte[CommandStringAddr + offset] == 13 or byte[CommandStringAddr + offset] == ";" or byte[CommandStringAddr + offset] == 10 or (byte[CommandStringAddr + offset] == 0))


         elseif(executestring[0] == ":" or executestring[0] == "!" or executestring[0] == 13 or executestring[0] == 10 ) ' COM or NAV packets from other entities
            return false ' completely ignore for now; consider sending a position packet

         else
            if strsize(@executestring) > 1
                 com0.str(string(":::No @ in front of "))
                 com0.str(@executestring)
            offset~
            
         com0.crlf
         
         ' can we split this between cycles by putting it somewhere else? probably...
         'WARNING: Potentially plays a number on main stack. Find a non-recursive way of doing this!!!!
         if (byte[CommandStringAddr + offset] == ";")    ' allows command stacking; add a loop and a conditional and we have it made!
             byte[CommandStringAddr + offset] := "@"
             MainAIFunction(true)
             return ExecuteCommand(CommandStringAddr + offset)

pri IsTerminator(char)
   return char == 13 or char == 10 or char == ";" or (not char)

pri CopyEquation(EqAddr, TokAddr, CoeAddr, lettervar)  'PrintAddr, lettervar)  


                    preqstr[11]~ 'byte[@preqstr + 11]~
                    com0.str(@preqstr)

                    if (executestring[3] == 13 or (executestring[3] == 0))
                       bytemove(TokAddr, @ExtraToken1, NumTokens)
                       longmove(CoeAddr, @ExtraCoeff1, NumCoefficients)
                       bytemove(EqAddr,  @ExtraEquation1, ExpStrLength) ' do we need this? might want to save it somewhere... or do we?
'                       preqstr[11]~ 'byte[@preqstr + 11]~
                       fudstr[6]~
'                       com0.str(@preqstr)
                       com0.str(@exprstr)
                       com0.tx(lettervar)
                       'byte[@preqstr + 11] := " "
                    else

                       com0.tx(lettervar)
                       com0.str(@was_str)
                       com0.str(EqAddr+1) ' was PrintAddr
                       com0.crlf
                       bytemove(EqAddr, @executestring, ExpStrLength)
                       eqr.ExpressionTokenizer(EqAddr, TokAddr, CoeAddr, true)
                       com0.str(@tokestr)
                       com0.str(TokAddr)


pri ParseExecuteString(IsFloat, InitialStringAddr,  OldParameter, LowerLimit, UpperLimit, FloatDigits, DecPoint): NewParameter | tempvar 



                 tempvar := OldParameter
                 if ParseParameterEchoBack
                   com0.str(InitialStringAddr)
                   com0.str(@was_str)
                   if IsFloat
                      com0.str(fto.FloatToFormat(OldParameter,FloatDigits,DecPoint))
                   else
                      com0.str(fto.IntToFormat(OldParameter,FloatDigits,DecPoint))
                 if (IsFloat)
                    if (IsFloat == EXPR)
                        NewParameter := eqr.ExpressionParserRPN(@executestring, @SensorData, @SensorDataDelta, false)
                        if NewParameter == NaN          ' DEVNOTE: Write the NAN-on-error inside the RPN parser!
                           NewParameter := OldParameter
                    else
                        if (fto.ParseNextFloat(@executestring, @NewParameter) == -1)
                            NewParameter := OldParameter
                    if (m.fcmpi((NewParameter), LESSTHAN, LowerLimit))
                         NewParameter := LowerLimit
                    if (m.fcmpi((NewParameter), MORETHAN, UpperLimit))
                         NewParameter := UpperLimit
                 else
                    if (fto.ParseNextInt(@executestring, @NewParameter) == -1)
                         NewParameter := OldParameter
                    if (NewParameter < LowerLimit)
                         NewParameter := LowerLimit
                    if (NewParameter > UpperLimit)
                         NewParameter := UpperLimit
                 if ParseParameterEchoBack
                   com0.str(@isnostr)
                   if IsFloat
                       com0.str(fto.FloatToFormat(NewParameter,FloatDigits,DecPoint))
                   else
                       com0.str(fto.IntToFormat(NewParameter,FloatDigits,DecPoint))
                   com0.crlf
                 return NewParameter


{    
    return ParseParameter(@executestring, IsFloat, InitialStringAddr,  OldParameter, LowerLimit, UpperLimit, FloatDigits, DecPoint)  ' obsolete
pri ParseParameter(UseStringAddr, IsFloat, InitialStringAddr,  OldParameter, LowerLimit, UpperLimit, FloatDigits, DecPoint) : NewParameter | tempvar
' Always parsed as float: if it's an int, round it later -- easier, honestly
                 tempvar := OldParameter
                 if ParseParameterEchoBack
                   com0.str(InitialStringAddr)
                   com0.str(@was_str)
                   if IsFloat
                      com0.str(fto.FloatToFormat(OldParameter,FloatDigits,DecPoint))
                   else
                      com0.str(fto.IntToFormat(OldParameter,FloatDigits,DecPoint))
                 if (IsFloat)
                    if (IsFloat == EXPR)
                        NewParameter := eqr.ExpressionParserRPN(UseStringAddr, @SensorData, @SensorDataDelta, false)
                        if NewParameter == NaN          ' DEVNOTE: Write the NAN-on-error inside the RPN parser!
                           NewParameter := OldParameter
                    else
                        if (fto.ParseNextFloat(UseStringAddr, @NewParameter) == -1)
                            NewParameter := OldParameter
                    if (m.fcmpi((NewParameter), LESSTHAN, LowerLimit))
                         NewParameter := LowerLimit
                    if (m.fcmpi((NewParameter), MORETHAN, UpperLimit))
                         NewParameter := UpperLimit
                 else
                    if (fto.ParseNextInt(UseStringAddr, @NewParameter) == -1)
                         NewParameter := OldParameter
                    'NewParameter := m.fround(eqr.ExpressionParserRPN(UseStringAddr, @SensorData, @SensorDataDelta, false))
                    if (NewParameter < LowerLimit)
                         NewParameter := LowerLimit
                    if (NewParameter > UpperLimit)
                         NewParameter := UpperLimit
                 if ParseParameterEchoBack
                   com0.str(@isnostr)
                   if IsFloat
                       com0.str(fto.FloatToFormat(NewParameter,FloatDigits,DecPoint))
                   else
                       com0.str(fto.IntToFormat(NewParameter,FloatDigits,DecPoint))
                   com0.crlf
                 return NewParameter
}

                 
pri CallUpdateWaypoint(StringAddr, force) | tempvar, tempvar2

                  

                  if (force or ((i2c.GetWaypointLat(wayp_temp) == INVALIDCOORD and long[constant(l#SensorDataAddress  + l#lat)] <> 0)))

                     ' use for xte
                     long[constant(l#SensorDataAddress  + l#lastlat)] := i2c.GetWaypointLat(curwayp)
                     long[constant(l#SensorDataAddress  + l#lastlon)] := i2c.GetWaypointLon(curwayp)
                     i2c.GetWaypointLat(wayp_temp)
                     ' use for xte
                     
                     curwplogged~
                     flag_routeupdated~~
                     tempvar := long[constant(l#SensorDataAddress  + l#lat)]
                     tempvar2 := long[constant(l#SensorDataAddress  + l#lon)]
                     com0.tx("W")
                     com0.str(@waypstr)
                     com0.str(fto.dec(wayp_temp))
                     com0.str(@atcostr)
                     com0.str(fto.IntToFormatPN(tempvar,12,4,"N","S"))
                     com0.str(string(" , "))
                     com0.str(fto.IntToFormatPN(tempvar2,12,4,"E","W"))
                     com0.tx(" ")
                     com0.str(StringAddr)
                     if (force)
                        com0.str(@selestr)
                     else
                        com0.str(@stoastr)
                     i2c.WriteWaypoint(wayp_temp,tempvar,tempvar2)

                       
{
' obsolete, just output the string directly
pri VirtualLights(num) | n    ' this nav packet is SAFE to be called asynchronously since it's small

'
'             ┌-beep
'             │lights
    num &= $00111111
    lightstr[4] := (num /  10) + $30
    lightstr[5] := (num // 10) + $30
    com0.str(@lightstr)
                  '012345

                    
dat
lightstr byte "!!!l00"
crlfstr  byte    13,10,0
}

DAT

' Surprisingly this disjointed collection of strings is enough to make the AI "talk" intelligibly.

' next up: implement ELIZA for wrong commands... ;)

inidstr  byte    ":::"
initstr  byte    "Init"
dashstr  byte    "... ",0
ininstr  byte    "NAV"
inicstr  byte    " on cog "
inibstr  byte    0,", waiting for GPS..."
crlfstr  byte    13,10,0
stoqstr  byte    "Quick" ' continues on next line
stocstr  byte    "stored ",0'because we",0
storstr  byte    " - in RC mode",0
stoastr  byte    " - didn't have it",0
selestr  byte    "s" ' continues on next line; used for capitalization
sel2str  byte    "elected"
atcostr  byte    " at" ' continues on nest line - it's actually worthwhile to have two "AT"s as this is less mem than an extra function call
cordstr  byte    " coords ",0
atwpstr  byte    " at" ' continues on next line - it's actually worthwhile to have two "AT"s as this is less mem than an extra function call
atwxstr  byte    " w" ' continues on next line; used for capitalization
waypstr  byte    "aypoint ",0
isnostr  byte    " and"
isn2str  byte    " is now ",0
'vectstr  byte    "abled. "
'vec2str  byte    "Vector"
'vec3str  byte    "ing to ",0
ais1str  byte    ":::"
aiststr  byte    "AI state"
aistxxx  byte    0
was_str  byte    " was ",0
rttpstr  byte ":::" ' continues on next line
routstr  byte    "R" ' continues on next line; used for capitalization
rou2str  byte    "oute ",0
rtt1str  byte "- One way, done",0
rtt14st  byte "- Circular",0
rtt15st  byte "- Ping-pong",0
exprstr  byte    "X assigned to " ' can continue on next line, so don't mess with
fudstr   byte    "servo _ fudge",0      ' the _ gets replaced by a number or letter 
timestr  byte    "Op time",0
nochstr  byte    "no change",0
tokestr  byte    ":::Tokens received: ",0
preqstr  byte    "Expression _" ' continues on next line
pre2str  byte    " is: ",0  ' the _ gets replaced by a number or letter
unknstr  byte    ":::Unknown command!",13,10,0
latstr   byte    "Lat ",0'itude ",0
lonstr   byte    "Lon ",0'gitude ",0
wlogstr  byte     ":::WP logged: ",0',13,10
extvstr  byte    "Variable _ offset",0  ' the _ gets replaced by a number or letter
vardstr  byte    "Var _ delta",0        ' the _ gets replaced by a number or letter
trakstr  byte    "Tracking ",0
resetstr byte    "reset",0 ' continues on next line
totostr  byte    " to "  ' continues on next line
deftstr  byte    "default",0
sen1str  byte    ":::"
sensstr  byte    "Sensors: ",0
offstr   byte    "all off",13,10
satstr   byte    ":::GPS"
sat2str  byte    " signal: ",0
gogostr  byte    ":::Ready to go! ",0
trimstr  byte    ":::Trim "
tri2str  byte    "_ "
tri3str  byte    "_ to ",0
wlisstr  byte    ":::Waypoint List"
wli2str  byte    0
wli3str  byte    "complete",0
direstr  byte    ":::Direct control O"
dir2str  byte    "_"
dir3str  byte    "_",13,10,0
echostr  byte    "Echo O"
ech2str  byte    "_"
ech3str  byte    "_",0
kml1str  byte    "/"
kml_str  byte    "coordinates>",13,10,0
spacstr  byte    ", ",0
xmitstr  byte    "Output on port "
xmi2str  byte    "_ :",0
eeprstr  byte    "EEPROM",13,10
eep2str  byte    0,"::Wait",0
amulstr  byte    "Altitude "
xmulstr  byte    "multiplier",0
zerovar  byte    "@V"
zerome   byte    "A"
zerova2  byte     "~",13,0

con
''********************************************************
''*  Powerboat AI function for eTrac Engineering RSV
''********************************************************

' names for AI states
HALT = 0
STEER = 1
AIM_COARSE = 2
AIM_FINE = 3




AIM = 2
HOLD = 3
HEAD = 1
AIM_R = 2
AIM_L = 3
NEW_STEER = 4
NEW_AIM = 5

' used internally to normalize angles
halfcirclediv = 1.0 / 180.0
sqrt2 = 1.4145 ' square root of two (no point in calculating it every time!)
var
long turnlocal ', turnlocal_old, turnlocal_delta, turnlocal_delta_check
long anglebreak1, anglebreak2, anglebreak3
long X, Y, nextX, nextY
long wantedRot, wantedSpeed, sonarL, sonarR, sonarX
PUB aifunction_etracboat | turnlocal_delta_temp        


   if ((aitype <> aitype_last))    ' A lot of this stuff was moved to startup: various reasons




    i2c.WriteWaypoint(0,long[constant(l#SensorDataAddress  + l#lat)],long[constant(l#SensorDataAddress  + l#lon)])  ' "go home" waypoint
    i2c.LogWaypoint(0)
'    executecommand(string("@SI10",13))                         ' calculation rate in hertz                 
    executecommand(string("@TSN3",13))                         ' telemetry rate in hertz                 
    executecommand(string("@VZ 284",13))                       ' show me my rotational speed                 

    com0.str(string(":::WP0 is home. @AN1 to start",13,10))
    aistate~
    aistate_next~
    aistate_last~

   ' for comparisons, use integers -- faster 
   turnlocal := m.fround(m.fmul(10.0,long[constant(l#SensorDataAddress + l#_tUrnamount)]))
   'turnlocal_delta := m.fround(m.fmul(10.0,long[constant(l#SensorDataAddress + l#NROT)]))
   'turnlocal_delta_check := m.fround(m.fmul(10.0,long[constant(l#SensorDataAddress + l#MM)]))

   anglebreak1 := m.fround(m.fmul(long[constant(l#SensorDataAddress + l#JJ)],10.0)) ' under this, go straight
   anglebreak2 := m.fround(m.fmul(long[constant(l#SensorDataAddress + l#KK)],10.0)) ' over this, steer -> aim
   anglebreak3 := m.fround(m.fmul(long[constant(l#SensorDataAddress + l#LL)],10.0)) ' under this, aim -> steer

   sonarL:= m.fround(m.fmul(long[constant(l#SensorDataAddress + l#Sonar1)],10.0)) ' under this, aim -> steer
   sonarR:= m.fround(m.fmul(long[constant(l#SensorDataAddress + l#Sonar2)],10.0)) ' under this, aim -> steer
   SonarX:= m.fround(m.fmul(long[constant(l#SensorDataAddress + l#DD)],10.0)) ' under this, aim -> steer

   

 if DirectControlStatus

    ' special : jogging overrides everything else
    
     Y := m.fmul(m.ffloat(DirectControlForward),0.5)
     X := m.fmul(m.ffloat(DirectControlRight),0.5)
     long[constant(l#SensorDataAddress + l#XX)] := X    
     long[constant(l#SensorDataAddress + l#YY)] := Y
     
 else
      case aistate ' state zero is defined at end
           
            STEER:
                WantedSpeed := m.fmul(1.95, long[constant(l#SensorDataAddress + l#MM)]) '1.54333333 ' 3 knots in meters per second '10.0 ' temporary: remember that this is in meters per seconds, not knots! 1m/s ~= 2kts so in this case, just go!!!
                   'This can be adjusted to, for example, slow down when closing in. 

                if (||turnlocal < anglebreak1) ' attempt to go straight
                   WantedRot~
                else   
                   WantedRot := m.fmul(long[constant(l#SensorDataAddress + l#ImpatientEquation)],long[constant(l#SensorDataAddress + l#BB)]) ' proportional steering according to equation 

                if ((||turnlocal) > anglebreak2)
                    aistate_next := AIM
                    WantedSpeed~
                    WantedRot~

                if (sonarL < sonarX) or (sonarR < sonarX)
                    aistate_next := HOLD
                    WantedSpeed := -0.05 ' ensures braking
                    WantedRot~
                       

            
            AIM:
                WantedSpeed := long[constant(l#SensorDataAddress + l#RR)] ' Y bias for aiming

                WantedRot := m.fmul(long[constant(l#SensorDataAddress + l#ZanyEquation)],long[constant(l#SensorDataAddress + l#AA)]) ' proportional aiming according to equation 

                if ((||turnlocal) < anglebreak3)
                    aistate_next := STEER
                    WantedSpeed~

                if (sonarL < sonarX) or (sonarR < sonarX)
                    aistate_next := HOLD
                    WantedSpeed := -0.05 ' ensures braking
                    WantedRot~

            HOLD:
                WantedSpeed := -0.05 ' ensures braking

                ' try to face the obstacle for now as a way of showing them you are aware of them (assume other boat), so the ROT equaton is S1 S2 - 
                WantedRot := m.fmul(m.fsub(long[constant(l#SensorDataAddress + l#Sonar1)],long[constant(l#SensorDataAddress + l#Sonar2)]),long[constant(l#SensorDataAddress + l#AA)])
                'WantedRot := m.fmul(long[constant(l#SensorDataAddress + l#ZanyEquation)],long[constant(l#SensorDataAddress + l#AA)]) ' proportional aiming according to equation 
                if (sonarL > sonarX) and (sonarR > sonarX)
                    aistate_next := AIM
                    WantedSpeed~
                    WantedRot~
            

       other: ' stop the vehicle!  AI state 0 also directs here. Prevents people entering AI states at random.
           aistate_next~
           Y~
           X~
           NextX~
           NextY~




          ' general acceleration-based speed/ROT decide 
      NextX := m.fmul(long[constant(l#SensorDataAddress + l#QQ)],m.fMathTurnAmount(long[constant(l#SensorDataAddress + l#NROT)],WantedRot)) ' gyro emulation amplitude
      NextY := m.fMathTurnAmount(long[constant(l#SensorDataAddress + l#cur_Speed)], WantedSpeed)


         'Clamp Y
         if m.fcmpi(NextY, MORETHAN, 0.99)
            NextY := 1.0
         if m.fcmpi(NextY, LESSTHAN, 0.0) and m.fcmpi(WantedSpeed,MORETHAN,0.0) ' allow to coast-brake
             NextY~ ' 
                                                               
         'Clamp X    ' 
         if m.fcmpi(NextX, MORETHAN, long[constant(l#SensorDataAddress + l#EE)])
              NextX:= long[constant(l#SensorDataAddress + l#EE)]
         if m.fcmpi(NextX, LESSTHAN, m.fneg(long[constant(l#SensorDataAddress + l#EE)]))
              NextX:= m.fneg(long[constant(l#SensorDataAddress + l#EE)])
                 
         ' Ramp Y up slowly, but pull down quickly. WARNING: Won't ramp negative speeds! (Good thing for quick stops)
         if m.fcmpi(NextY, MORETHAN, Y)
           Y := m.fadd(Y, long[constant(l#SensorDataAddress + l#FF)])
         else
           Y := NextY
           


         ' Erase sign fo X for comparison
         X := m.fabs(X)

        ' Ramp X up either direction slowly, but pull down quickly. Can still cause violent reversals if magnitude is high and signs change, but if that happens it's probably warranted.
         if m.fcmpi(m.fabs(NextX), MORETHAN, X)
           X := m.fadd(X, long[constant(l#SensorDataAddress + l#GG)])
         else
           X := m.fabs(NextX)

        ' Restore sign of X
         if m.fcmpi(NextX, MORETHAN, 0.0)
            X := m.fneg(X)
           
            

        




                   
      

' apply standard X and Y multipliers after everything else                  
      long[constant(l#SensorDataAddress + l#XX)] := m.fmul(X,long[constant(l#SensorDataAddress + l#WW)])     
      long[constant(l#SensorDataAddress + l#YY)] := m.fmul(Y,long[constant(l#SensorDataAddress + l#VV)])
       
