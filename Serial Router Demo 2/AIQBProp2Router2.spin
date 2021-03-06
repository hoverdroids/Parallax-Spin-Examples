CON
                                                                                                                              
        _clkmode                = xtal1 + pll16x
        _xinfreq                = 6_000_000'5_000_000
        _stack                  = 100 ' mah? set this to MainStack instead?                                                                                       




obj

 com:"TwelveSerialPorts32"  '32, 128 or 512 mean size of primary RX buffer.
'com:"TwelveSerialPorts128" '32, 128 or 512 mean size of primary RX buffer.
'com:"TwelveSerialPorts512" '32, 128 or 512 mean size of primary RX buffer.
terminal: "FullDuplexSerialExt"
dummyplug: "serial_output_thingy"

con
numbuffers  = 1'12  'modify the number of ports you want here; this doesn't include the debug port
buffersize  = com#SECONDARY_BUFFER_SIZE
delimchar   = "@" ' address delimiter
termichar   = 13  ' packet delimiter
termichar2  = 10  ' packet delimiter
con
' 0..11 are the port addresses
term        = 12 ' terminal address
router      = 13 ' if we get this address in, it means it's a command for the router, so handle accordingly.
aux0_cog1   = 14 ' if we get this address in, it means it's a command for the auxilliary cog, so handle accordingly.
devnull     = 99 ' guaranteed /dev/null for any conceivable reason
stealthmask = 50 ' This + address means "deliver the packet without sending information", useful for devices that don't know about the router, e.g. NMEA devices. 0 disables. Do not overlap ports or you'll miss the first stealthed x ports.


var  ' router variables
byte buffer[(buffersize+1)*numbuffers] ' includes padding
long ptr[numbuffers]

byte terminalbuffer[buffersize]   ' high speed port gets special treatment
byte terminalpad
long terminalptr



var ' spin stacks
long aux0_stack[128]


dat   'device num     0      1       2      3      4       5     6     7      8      9      10     11     term      device num
'                  bridge  Prop2
inputpins      byte 10,     2,     5,     6,     2,     24,    13,    15,    17,    19,    21,    23,      31      ' Hardware input pin
outputpins     byte 11,     3,     4,     7,     1,     25,    12,    14,    16,    18,    20,    22,      30      ' Hardware output pin
inversions     byte %0000, %0000, %0000, %0000, %0000, %0011, %0011, %0011, %0011, %0011, %0011, %0011,   %0000   ' Signal flags (open collector, inversion etc.)
baudrates      long 9600,  9600,  9600,  9600,  9600,  9600,  9600,  9600,  9600,  9600,  9600,  9600,  115200  ' Baud rate
defaultroute   byte 62,  term,  term,  term,  term,  term,  term,  term,  term,  term,  term,  term,    50  '0 was:term;term was:router If a packet coming from this port has no address, default to sending it to that port. Use stealthmask to strip packet information.
dat ' configuration options for the router
defaultaddress byte term   ' where to send things we don't know what to do with
bigbrother     byte  2     ' 0 none, 1 terminal monitors inter-device exchange, 2 terminal monitors that AND packet contents (useful to not have to send the same packet twice
doupcase       byte  0     ' if 1, convert lowercase letters to uppercase
dolowcase      byte  0     ' if 1, convert uppercase letters to lowercase


dat ' premade sentences
busystr byte "@__@BUSY",0
errstr  byte "@__@ERR "
errcode byte "_",0
okstr   byte "@__@OK",0

con 'For auxilliary cog functions, go at the end of this file.
debug = false
pub start | temp, bufferbaseaddr, port ' Main router code.
if (debug)
 dummyplug.start(12,-19200) ' sends test data to ports above. remove once debugging is over



terminal.start(byte[@inputpins+12],byte[@outputpins+12],byte[@inversions+12],long[@baudrates+12*4])    ' high speed port gets special treatment (update: should it?)

aux0_com.init(@aux0_buffer_tx,buffersize) ' virtual com port for aux0_ device


port~    ' start all the other ports here 
repeat numbuffers
  if (byte[@inputpins+port] < 32) and (byte[@outputpins+port] < 32)
    com.AddPortNoHandshake(port,byte[@inputpins+port],byte[@outputpins+port],byte[@inversions+port],long[@baudrates+port*4])'CHRIS:this is where the ports are "added"
    port++
com.start

' start aux0_illiary cog here (if wanted). Add cogs to fit.
repeat
  aux0_rxflag~
  aux0_cog := cognew(aux0_loop, @aux0_stack) + 1
until aux0_cog

' main loop
repeat
     ' device ports
   port~
   repeat numbuffers
      bufferbaseaddr := port*buffersize
      temp := com.rxcheck(port)
      if (temp > 0)
          buffer[bufferbaseaddr+ptr[port]]:=temp
          ptr[port]++
        if (temp == termichar or temp == termichar2 or ptr[port] => buffersize)
          buffer[bufferbaseaddr+ptr[port]] := 0
          output(@buffer+bufferbaseaddr,port)
          ptr[port] := 0
      port++

     ' terminal port (checked every round)
      temp := terminal.rxcheck
      if (temp > 0)
          terminalbuffer[terminalptr++]:=temp
        if (temp == termichar or temp == termichar2 or terminalptr > buffersize)
          terminalbuffer[terminalptr]~
          output(@terminalbuffer,term)
          terminalptr~

     ' internal virtual serial port (ok to check every round: virtually free)
      if(aux0_txflag)
       output(@aux0_buffer_tx,(constant(aux0_cog1)))
       aux0_com.zap(0)
       aux0_txflag~ 

pri ExecuteRouterCommand(CommandAddr, origin) : valid | cmdbyte, arg1, arg2 ' unrolled loops for speed here. use this to set verbosity, pins, baud rates etc. Can also set routing tables if we want to go that way. Synchronous, so it sehould be fast!
         valid~
         cmdbyte := upcase(byte[CommandAddr])
         if cmdbyte == "L" 'Lx ' logging level
            if isDigit(byte[CommandAddr+1])
               bigbrother := byte[CommandAddr+1]-"0"
               valid~~

         if cmdbyte == "R" 'reboot
            reboot

         if cmdbyte == "D" 'Dxx>yy ' default route for port x is y ( use stealthmask to strip!)
            if isDigit(byte[CommandAddr+1]) and isDigit(byte[CommandAddr+2]) and byte[CommandAddr+3] == ">" and isDigit(byte[CommandAddr+4]) and isDigit(byte[CommandAddr+5]) 
               arg1 := (byte[CommandAddr+1]-"0")*10
               arg1 += (byte[CommandAddr+2]-"0")

               arg2 := (byte[CommandAddr+4]-"0")*10
               arg2 += (byte[CommandAddr+5]-"0")

               byte[@defaultroute+arg1] := arg2 & $FF
               valid~~
{
         ' these are best set in hardware really...
         
         if cmdbyte == "B" 'Dxx:yyyy[-+] ' baud rate for port x is y
            if isDigit(byte[CommandAddr+1]) and isDigit(byte[CommandAddr+2]) and byte[CommandAddr+3] == ":" and isDigit(byte[CommandAddr+4]) and isDigit(byte[CommandAddr+5]) and isDigit(byte[CommandAddr+6]) and isDigit(byte[CommandAddr+7]) 
               arg1 := (byte[CommandAddr+1]-"0")*10
               arg1 += (byte[CommandAddr+2]-"0")
               
               arg2 := (byte[CommandAddr+3]-"0")*1000
               arg2 += (byte[CommandAddr+4]-"0")*100
               arg2 += (byte[CommandAddr+5]-"0")*10
               arg2 += (byte[CommandAddr+6]-"0")
               if byte[CommandAddr+8] == "-"
                   byte[@inversions+arg1]:=%0011
               else
                   byte[@inversions+arg1]:=%0000
               long[@baudrates+(arg1*4)] := arg2 & $FF
               valid~~

         if cmdbyte == "P" 'Pxx:yy:zz ' pins for port x are y and z
            if isDigit(byte[CommandAddr+1]) and isDigit(byte[CommandAddr+2]) and byte[CommandAddr+3] == ":" and isDigit(byte[CommandAddr+4]) and isDigit(byte[CommandAddr+5]) and byte[CommandAddr+6] == ":" and isDigit(byte[CommandAddr+7]) and isDigit(byte[CommandAddr+8]) 
               arg1 := (byte[CommandAddr+1]-"0")*10
               arg1 += (byte[CommandAddr+2]-"0")
               
               arg2 := (byte[CommandAddr+4]-"0")*10
               arg2 += (byte[CommandAddr+5]-"0")

               cmdbyte += (byte[CommandAddr+7]-"0")*10
               cmdbyte += (byte[CommandAddr+8]-"0")
               
               byte[@inputpins+(arg1*4)] := arg2 & $FF
               byte[@outputpins+(arg1*4)] := cmdbyte & $FF
               valid~~
}
         if (valid)
             BuildAddress(origin,@okstr)
             output(@okstr,router)
         else
             errcode:="U"
             BuildAddress(origin,@errstr)
             output(@errstr,router)

pri output(StringAddr,origin) | size, address, dobbout, sta

     
     address := defaultaddress ' default to term. Could also default to bit bucket if desired?
     dobbout := (origin <> term)

     if byte[StringAddr] == delimchar and byte[StringAddr+3] == delimchar    ' we got an address indicator, so generate an address. Default is send to terminal. Invalid addresses will be sent to terminal.
        address := (byte[++StringAddr]-"0")*10
        address += (byte[++StringAddr]-"0")
        StringAddr+=2
        if (address > 99 or address < 0)
          address := defaultaddress ' default
     else
        if (dobbout==false)
           address := byte[@defaultroute + 12] 
        elseif (origin > -1 and origin < numbuffers) ' no address? then default to the specified static routing table.
           address := byte[@defaultroute + origin]
       

     removetermchar(StringAddr)
     size := strsize(StringAddr) 

     if (size < 1)
         return
         

     case address

      router:
        ExecuteRouterCommand(StringAddr,origin) ' no need to have an address in there because this is delivered locally

      aux0_cog1:
        CallAsyncCommand(StringAddr,origin)     ' no need to have an address in there because this is delivered locally


      ' devices 0 to 11
      0..constant(numbuffers-1):  ' the terminal may still want to know what goes on, so let's enable it to monitor things
       com.tx(address,delimchar)
       com.tx(address,"0"+origin/10)
       com.tx(address,"0"+origin//10)
       com.tx(address,delimchar)
       sta := StringAddr
       repeat size
         com.tx(address,reformat(byte[sta++],address))
       com.tx(address,delimchar)
       com.tx(address,termichar)
       
      ' terminal
      term:
       dobbout~
       terminal.tx(delimchar)
       terminal.tx("0"+origin/10)
       terminal.tx("0"+origin//10)
       terminal.tx(delimchar)
       sta := StringAddr
       repeat size
         terminal.tx(reformat(byte[sta++],term))
       terminal.tx(delimchar)
       terminal.tx(termichar)

      ' devices 0 to 11, with stealth mask 
      stealthmask..constant(stealthmask+numbuffers-1):  ' the terminal may still want to know what goes on, so let's enable it to monitor things
       sta := StringAddr
       repeat size
         com.tx(address-stealthmask,reformat(byte[sta++],address))
       com.tx(address-stealthmask,termichar)

      ' terminal with stealth mask
      stealthmask+term:
       dobbout~
       sta := StringAddr
       repeat size
         terminal.tx(reformat(byte[sta++],term))
       terminal.tx(termichar)

      devnull: ' always nothing
      other: ' everything else: currently bit bucketed, unless terminal is monitoring it, see below

if(dobbout and bigbrother)
           terminal.tx(delimchar)
           terminal.tx("0"+origin/10)
           terminal.tx("0"+origin//10)
           terminal.tx(">")
           terminal.tx("0"+address/10)
           terminal.tx("0"+address//10)
           if (bigbrother>1)
               terminal.tx(delimchar)
               sta := StringAddr
               repeat size
                  terminal.tx(reformat(byte[sta++],term))
           terminal.tx(delimchar)
           terminal.tx(termichar)

pri CallAsyncCommand(CommandAddr,origin)
  if (aux0_busyflag)                      ' synchronously say that the other core is busy
     BuildAddress(@busystr,origin)
     output(@busystr,aux0_cog1)
  else
     bytemove(@aux0_buffer_rx,CommandAddr,buffersize) ' deliver the command to the virtual com port
     aux0_lastorigin:=origin
     aux0_rxflag~~
    
pri removetermchar(StringAddr) : i
    i := StringAddr
    repeat strsize(StringAddr)
       if (byte[i] == termichar or byte[i] == termichar2)
           byte[i] := 0 '32
       i++

pri reformat (ByteVal, destinationport) ' how about doing per-string instead of per-character? Probably faster...

    if (doupcase and ByteVal > constant("a"-1) and ByteVal < constant("z"+1))
         ByteVal-=$20
    if (dolowcase and ByteVal > constant("A"-1) and ByteVal < constant("Z"+1))
         ByteVal+=$20

{
    if (doupcase)
       ByteVal := upcase(ByteVal)
    elseif (dolowcase)
       ByteVal := lowcase(ByteVal)
}
    return ByteVal

pri upcase(ByteVal)
'' go to uppercase, 1 character -- that's all it does (used in parsing)

    if (ByteVal > constant("a"-1) and ByteVal < constant("z"+1))
         return (ByteVal-$20)
    return ByteVal
{
pri lowcase(ByteVal)
'' go to uppercase, 1 character -- that's all it does (used in parsing)

    if (ByteVal > constant("A"-1) and ByteVal < constant("Z"+1))
         return (ByteVal+$20)
    return ByteVal
}
pri BuildAddress(num,where) 
    byte[where] := delimchar
    byte[where+1] := "0"+num/10
    byte[where+2] := "0"+num//10
    byte[where+3] := delimchar
pri isDigit(char)
    if (char > "9" or char < "0")
       return false
    return true

con











'Ping hardware constants
  pingA           = 22'9         'pin-- ping))) Front
  pingB           = 23'8         'pin-- ping))) Rear
'Ping software constants
  updaterate      = 8        'range update rate when active (measurement cycles per second) ~15 max
'Ping machine states
  #0, a, b

' auxilliary cog functions here. This can be treated pretty much like a normal standalone microcontroller.
' Exception: use aux0_com for serial output and, to xmit, do aux0_txflag~~ for serial receive, use reacttopacket and read aux0_buffer_rx.
' Note that a blocking function is OK and will not impair the rest of the router! (see example)
obj
aux0_com:       "stringoutput_external_buffer"
cogCounter :    "COG_counter"
numbers:        "Numbers"
math    :       "FloatMath"
fstring :       "FloatString"
ping:           "dualPing"             'Updated ping object (dual channel fire & forget)
var  ' auxilliary cog variables
byte aux0_buffer_rx[buffersize]   ' receive buffer for aux0_ cog / virtual com port
byte aux0_rxpad
byte aux0_busyflag
byte aux0_rxflag ' did anything come in?
byte aux0_buffer_tx[buffersize]   ' transmit buffer for aux0_ cog / virtual com port
byte aux0_txpad  ' used by the aux0_ cog as "clear to send" tag
byte aux0_txflag
long aux0_cog
long aux0_lastorigin
'timing between messages
long termWaitTime
long bridgeWaitTime

'counters
byte ii,jj,kk
'disecting the message into parts
byte messageType[buffersize]   'byte space for the message type;should never reach this size
byte values[buffersize]     'for storing the values of the incoming message
long decValues[buffersize]
byte commas[buffersize]     'notes the locations of commas in the message
byte numCommas
'servo positions
long  position1, position2, position3,position4     'The assembly program will read these variables from the main Hub RAM to determine
long futabaDir                                         ' the high pulse durations of the three servo signals

'Object Detection vars
long objDetectStack[200]
byte objectDetected[364]                            'the minimum measurement angle is .5 and a span of 180 degrees means 360 possible measurements                   
                                                    'this is 90 longs but turns into 180 longs since it will be called in a new cog
pri aux0_loop ' auxiliary cog function. Should not need modifications.
    aiqbP2Init     'initialize AIQB functions-comms already started above

    repeat
     aux0_Activities  'the aux0_Activity will keep looping even though there are no received packets; the buffer is updated when a new message comes in
     if (aux0_rxflag) ' we got something in buffer
         aux0_rxflag~
         aux0_busyflag~~
         aux0_ReactToPacket'(@aux0_buffer_rx,aux0_lastorigin)
         aux0_busyflag~
    cogstop(aux0_cog~ - 1)

pub aux0_Activities|char1 ' auxilliary cog loop cycle (gets looped by aux0_loop). You can treat this as its own microcontroller basically.

  
''repeat 'don't use without a condition else it blocks
  'objectDetect
  if aux0_buffer_rx[0]<>0 'was =="A" 'note that the aux0_buffer_rx does not get reset until a new message is received;also, the buffer does not include the address
    disectMessage
    'boardResponse
    
    'if strcomp(@messageType,string("position"))
      'servoUpdate

    'BIG NOTE:
    'everything happening after the echo info is sent to the Android device is heavily dependent on
    'bridgeWaitTime. Too low and the messsages will be skipped entirely and hence unpredicatable behaviour
    'will ensue. Is there a way to fix this?Maybe increase the baud?
    ''aux0_com.str(string("@50@$echo ...   string received:"))
    ''aux0_com.str(@messageType)                   'tx(byte[@aux0_buffer_rx][0])
    ''aux0_com.str(string(">>./COM0 ")) 'sending a string to the serialterminal
    ''aux0_txflag~~
    ''waitcnt(bridgeWaitTime+cnt)
    
    clearOld
  
 
pub aux0_ReactToPacket'(PacketAddr,FromWhere) ' auxilliary cog function called when the virtual internal serial port got something. aux0_buffer_rx contains it and aux0_lastorigin says where it's from.

    repeat 5

         if (++result & 1)
             BuildAddress(aux0_lastorigin,@okstr)
             'aux0_com.str(@okstr)                   'chris removed
         else
             errcode:="!"
             BuildAddress(aux0_lastorigin,@errstr)
             'aux0_com.str(@errstr)

         'aux0_com.str(string(" AUX COMMAND PROCESSED!",13))    'chris removed
         'aux0_txflag~~

         waitcnt(cnt+clkfreq) 'does this need to be 1sec?

Pri aiqbP2Init
  {--Initialize wait times for comms--}
  termWaitTime:=clkfreq/100     'the terminal misses messages when no wait time; this number is the lowest that works
  bridgeWaitTime:=clkfreq   'the bridge includes messages that weren't directed at it without a wait time; this number is the lowest that works

  {--Indicate the router has started}
  aux0_com.str(string("@62@Prop2 Router Initialized",13))
  aux0_txflag~~
  waitcnt(termWaitTime +cnt)

  {--initialize the decimal/string converter--}
  numbers.Init

  {--initialize the servo driver code--}
  'The new cog that is started below continuously reads the "position1", "position2", and "position3" variables as they are
  'changed by the main code
  p1:=@position1                           'Stores the address of the "position1" variable in the main Hub RAM as "p1"
  p2:=@position2                           'Stores the address of the "position2" variable in the main Hub RAM as "p2"
  p3:=@position3
  p4:=@position4                           'Stores the address of the "position4" variable in the main Hub RAM as "p4" 
  futabaDir:=-1                            'initial direction is always towards 180deg
  cognew(@ThreeServos,0)                   'Start a new cog and run the assembly code starting at the "ThreeServos" cell
  position1:=105_600                     'Set Pan servo to 0deg (HiTec HS-785HB timing)                                             
  position2:=futaba0Time'105_600                     'Set Tilt servo to 0 deg (HiTec HS-785HB timing)
  position3:=futaba0Time                 'Set front Ping servo to 0 deg (Parallax Standard Servo timing)
  position4:=futaba0Time                 'Set front Ping servo to 0 deg (Parallax Standard Servo timing)
  waitcnt(futabaWait[10]+cnt)                 'this ensures that the servo always has time to reach 0 degrees before starting object detection
  {--Start Object Detect in new cog--}
  cognew(objectDetect,@objDetectStack[0])
  {--Ping Initialize--}
  waitcnt(clkfreq * 5 + cnt)                      'Start FullDuplexSerial
  aux0_com.str(string("@62@Ping Initializing",13))
  aux0_txflag~~
  waitcnt(termWaitTime +cnt)
  ping.calibrate(68)                              'calibrate ping for ambient temperature=68 F
  
  {--determine how many cogs are free--}
  aux0_com.str(string("@62@Number of Free Cogs:"))
  aux0_com.dec(cogCounter.free_cogs)
  aux0_txflag~~
  waitcnt(termWaitTime +cnt)
  aux0_com.str(string("@62@ ",13))
  aux0_txflag~~
  waitcnt(termWaitTime+cnt)
  'Cog count:6 for router,1 for servos
  
Pri disectMessage

  ii:=0  'null these just in case
  jj:=0
  kk:=1   'need to start noting value locations after the 0th element, since that is the first value
  repeat strsize(@aux0_buffer_rx) 'determine the message type, and only go for as long as was the received message
    if aux0_buffer_rx[ii]==","
      ii++
      Quit
    messageType[ii]:=aux0_buffer_rx[ii]
    ii++

    'now that the first comma is reached, store the values, add zero terminator and note their locations
  repeat strsize(@aux0_buffer_rx)-ii
    values[jj++]:=aux0_buffer_rx[ii++]   'the first element of values, is that after the first comma, not including the first comma
    if aux0_buffer_rx[ii]==","
      commas[kk]:=jj+1  'when hitting a comma,replace with a 0 in values matrix, and note the next value start location
      values[jj]:=0 'need to add a 0 string terminator where the comma was, but no need to add the comma
      kk++
      jj++
      ii++

  numCommas:=kk     'this notes how many zeros, i.e. number of values sent -1

  ii:=0
  jj:=0

  'convert the values matrix from strings to decimals 
  repeat numCommas
    jj:=commas[ii]
    decValues[ii]:=numbers.FromStr(@values[jj], numbers#DEC)
    ii++

  ii:=0
  jj:=0
  kk:=1
Pri clearOld
    ii:=0                        'reset i for later index
    jj:=0
    kk:=1
    bytefill(@aux0_buffer_rx,0,buffersize) 'clear the buffer after use
    bytefill(@messageType,0,buffersize) 'clear the messageType bytes to be null bytes
    bytefill(@commas,0,buffersize)
    bytefill(@values,0,buffersize)
    bytefill(@decValues,0,buffersize)
                                 
Pri objectDetect| mark, distA, distB,objDetInd,objDetIndTemp
       
      'The below code moves the front Ping Servo 180 degrees while stepping a given number of degrees
      'the number of degrees is seleceted in DAT by setting the desired futabaOpt;  also, without forcing the
      'servo to reach the exact boundary value, the steps would compound in error over time
    mark := cnt                                       'process initialization time for Ping
    objDetInd:=1                'first measurement should be stored in block 1 since block 0 is for overall status
    'fire the first ping sounds to start the cycle; pings will not fire again unless
    'a measurement finishes.  this eliminates the need for a ping wait time
    ping.selectAB(a)
    distA := ping.ReadPingIn
    ping.fireping(pingA)
    ping.selectAB(b)
    distB := ping.ReadPingIn
    ping.fireping(pingB)
    waitcnt(clkfreq+cnt)
    repeat
     
      ping.selectAB(a)                                'Select channel A
      distA := ping.ReadPingIn                        'read Ping))) channel A
  '    distA := ping.ReadPingTenths                     
      if (distA>0)                                    'if distA=0 then measurement not complete yet, so don't fire again
        distA := kalman1c(distA,0)                    'Mild filtering to supress msmnt jitter, only after the measurement finished
        ping.fireping(pingA)                          'if distA>0 the measurement finished; restart measurement cycle on channel A 
      ping.selectAB(b)                                'Select channel B
      distB := ping.ReadPingIn                        'read Ping))) channel B
  '   distB := ping.ReadPingTenths
      if (distB>0)                                    'if distB=0 then measurement not complete yet, so don't fire again
        distB := kalman1c(distB,b)                    'Mild filtering to supress msmnt jitter
        ping.fireping(pingB)                          'if distB>0 the measurement finished;restart measurement cycle on channel B
   
      'Now have two new measurement values and have restarted the Ping))) measurement cycle...
      'Cog is free to do other things while the next measurement cycle is runnning...

      'determine if object is within unsafe range
      if ((distA=<inchSafety)OR (distB<=inchSafety))
        objectDetected[objDetInd]:=1
      else
        objectDetected[objDetInd]:=0
                                
      'after sweeping 180degrees, sum the elements to determine if an object is present at any point
      if ((objDetInd==1)OR (objDetInd==futabaLastBin[futabaOpt])) 'after sweeping 180 degrees in either direction
        objectDetected[0]:=0      'set to zero on entry and only set to 1 if there's a 1 in the detect matrix
        objDetIndTemp:=1          'reset the temp counter each 180degrees
        repeat futabaLastBin[futabaOpt]'strsize(@objectDetected[objDetInd]) 'repeat until any element has a 1 for the length of non-zero elements 
          if (objectDetected[objDetIndTemp++]==1)         'start evaluating element 1, not 0
            objectDetected[0]:=objectDetected[0]+1        'if any but the first element are 1, set this to 1; it indicates overall objectDetect status
            'QUIT                        'exit repeat on first finding a 1
          'else

      'after the sensors are installed, measure the "noise floor" to determine how many counts will acutally indicate no objects
      'This is tabulated by testing both PINGs and the IR together in their final locations with the desired ranges mapped out
      'and compared to the step angles; for example, there is a higher value of false triggers at lower step value since the angle
      'which the servo sweeps the same object is higher.  Also, the machine will have a certain number of reflections from the neck
      'joint and so this is the easiest way to remove those to determine the zero object reference number.  Anything above that number
      'will indicate there is an object present      
      'send only the average element once per 180deg sweep
      aux0_com.str(string("@62@ObjectDetected,"))
      aux0_com.dec(objectDetected[0])
      aux0_com.str(string(13))
      aux0_txflag~~

      'send all object detected elements to terminal  
      'aux0_com.str(string("@62@Index,"))
      'aux0_com.dec(objDetInd)
      'aux0_com.str(string(",Object Detected,"))
      'aux0_com.dec(objectDetected[objDetInd])
      'aux0_com.str(string(13))
      'aux0_txflag~~
 
      'send raw distance measurements to terminal
      'aux0_com.str(string("@62@DistA,"))
      'aux0_com.dec(distA)
      'aux0_com.str(string(",DistB,"))
      'aux0_com.dec(distB)
      'aux0_com.str(string(13))
      'aux0_txflag~~
      'usually there's a termWait here; no need since there's a longer wait below 

      'set the next object detect index for storing next detected object
      objDetInd:=objDetInd-futabaDir

      'set the servo angle and rotation direction                                                                                                                
      if (position3==(futaba0Time-futabaRem[futabaOpt]))
        position3:=futaba0Time                          'when servo reaches ~1deg, set next step to exactly 0 degrees
        position4:=futaba0Time
      elseif (position3==(futaba180Time+futabaRem[futabaOpt]))'                                           
        position3:=futaba180Time                        'when servo reaches ~179deg, set next step to exactly 180 degrees
        position4:=futaba180Time                                                
      else
        position3:=position3+futabaDir*futabaDelT[futabaOpt]
        position4:=position4+futabaDir*futabaDelT[futabaOpt] 

      'only change the sweep direction when the position is already equal to the boundary; it won't work changing them at any other time as the code is written
      if (position3==futaba0Time)
        futabaDir:=-1                                   'and change the scan direction
      elseif (position3==futaba180Time)
        futabaDir:=1
     
      waitcnt(futabaWait[futabaOpt]+cnt)
      'waitcnt(LowTime+cnt)                              'lowTime is defined in assembly and is roughly 10ms which
                                                        'is required between servo pulses; this object therefore can't override
                                                        'the 10ms rule

pri kalman1c(x_meas,AorB):x_ret
''Simple 1-D kalman filter for scalar random constant with simplified covariance model.
''Uses a constant covariance (and therefore hard-coded kalman gain). Simplifies/speeds
''up calculations. User must manually select gain, where gain is given by:
''gain = const / k_scale (high gainbelieve msmnts)
''Max filter update rate ~9000 samples/sec for 1 cog @ clkfreq=80
'Note: as implemented here, this is actually 2 filters, one for channel A and one for B
'Can easily delete the AorB functionality if only a single channel is desired

  x_prev[AorB] := x_cur[AorB]                        
  x_cur[AorB] := (x_prev[AorB] * k_scale + (k * (x_meas - x_prev[AorB]))) / k_scale
'   Debug.Str(String("  x_meas, "))
'   Debug.dec(x_meas)
'   Debug.Str(String("  x_prev, "))
'   Debug.Dec(x_prev[AorB])
'   Debug.Str(String("  x_cur, "))
'   Debug.dec(x_cur[AorB])
  return x_cur[AorB]
Pri boardResponse
  'show what is stored in the messagType variable
  aux0_com.str(string("@62@Message Type determined to be:"))
  aux0_com.str(@messageType)
  aux0_com.str(string(13))
  aux0_txflag~~
  waitcnt(termWaitTime+cnt)
  
 'note how many commas, and hence values, were sent
  aux0_com.str(string("@62@Number of Commas:"))
  aux0_com.dec(numCommas)
  aux0_com.str(string(13))
  aux0_txflag~~
  waitcnt(termWaitTime+cnt)
  
 'display the converted string values that are now decimals, in the decValues matrix
  ii:=0
  repeat numCommas
    aux0_com.str(string("@62@Value "))
    aux0_com.dec(ii)
    aux0_com.str(string(":"))
    aux0_com.dec(decValues[ii])
    aux0_com.str(string(13))
    aux0_txflag~~
    waitcnt(termWaitTime+cnt)
    ii++
  'display the message type and the first value on the board via the seven segment LEDs
  ii:=0
  jj:=0
  repeat msgN
      if strcomp(@messageType,@msgType[ii])
        'outa[0..7]:=byte[@msgTypeDispNum][jj]
        QUIT
      ii:=ii+strsize(@msgType[ii])+1 'says to add the string size plus 1 to the current index; the plus 1 is due to the zero terminator after every string
      jj++
      'if jj==msgN   'indicate that the received message wasn't in the acceptable list by displaying the "dot"
        'outa[0..7]:=%00010000

  if jj<msgN        'if the message was within the list, display the first value
      ii:=0 
      repeat 10 'msgV, which is total number of displayable values(0 to 9)
        if (decValues[0]==msgValue[ii]) 'strcomp(@values,@msgValue[ii])
          'outa[16..23]:=byte[@msgValueDispNum][ii]
          QUIT
        ii++'ii:=ii+strsize(@msgValue[ii])+1
  else
      'outa[16..23]:=%00000000
        
    'outa[0..7]:=byte[@msgTypeDispNum][sevSegCnt]
    'outa[16..23]:=byte[@msgValueDispNum][sevSegCnt++]    
   
DAT 'this was inserted by CHRIS and is used for AIQB data
null byte %00000000   'used for turning off the 7-segment displays

{The following numbers correspond to the green 7-segment display (left side)on the AIQB Propeller1.
The assigned values correspond to pin0 through 7, from left to right. Also, note that these are given
in tens of values rather than single digits; it's because this display is on the left in the tens location
when using both 7-segment displays
}
  'uncomment the following 2 lines and comment their "live copies" in order to revert to message names being numbers
  msgN byte 1 'the number of messages in msgType
  msgType byte "state",0          
  'msgType byte "hundred",0,"ten",0,"twenty",0,"thirty",0,"fourty",0,"fifty",0,"sixty",0,"seventy",0,"eighty", 0,"ninety",0

  
{The following numbers correspond to the red 7-segment display (right side)on the AIQB Propeller1.
The assigned values correspond to pin16 through 23, from left to right;
NOTE:pin 20 is burned out at present so DO NOT TURN ON pin 20!
}
  msgV byte 10
  msgValue byte 0,1,2,3,4,5,6,7,8,9
  
{Breakdown of Commands}
DAT
'This section defines the servo timing requirements based on the step angle desired.  Note that as the step angle increases the waiting time
'increases.  This is because it's best to send the servo one command and allow it to completely execute that command before sending it another
'position command.  This will ensure that the highest average velocity is achieved since it's only accelerating once per command.  Also, these
'data are calculated for 96MHz and assumes the futaba has a 1.5sec/180deg average speed since that's what's mentioned in the parallax document
'The distance accuracy is the amount of distance between measurement angles assuming measurements are only taken at the intervals listed.
'To use a given angle for the sweep, set futabaOpt to the degree value (e.g. for 1/2deg use futabaOpt=0, for 1deg use futabaOpt=1,etc)
'FutabaWait is 10ms for 1/2deg and 1 deg since their travel time was less than the 10ms requirement
'3deg,6deg,9deg, and 180 deg wouldn't work with 0 for futabaRem(remainder) and yet putting 1 worked.  I assume it's due to a rounding error 
'distance accuracy at 30inches where x is the adjacent leg on the triangle
'step angle           1/2deg       1deg      2deg      3deg      4deg      5deg      6deg      7deg      8deg      9deg      180deg
'x"                   ~0.26"       0.52"     1.04"     1.57"      2.1"     2.62"     3.15"     3.68"     4.22"     4.75"       N/A
'total time for 180deg
futabaDelT    long          466,    933,     1866,     2800,     3733,     4666,     5600,     6533,     7466,     8400,     168000 'this is the closest integer value to 1.003 degrees for the futaba servo
futabaRem     long          240,     60,       60,        1,       15,       24,        1,     4675,     3748,        1,          1
futabaWait    long      960_000,960_000,1_600_000,2_400_000,3_200_000,4_000_000,4_800_000,5_600_000,6_400_000,7_200_000,144_000_000
futabaLastBin word          362,    182,       92,       61,       47,       38,       31,       27,       24,       21,          1
futaba0time   long      216_000  'this is a 2.25ms pulse width for 0 degrees at 96MHz for the futaba servo
futaba180time long      48_000   'this is a 0.5ms pulse width for 180 degrees at 96MHz for the futaba servo
futabaOpt     byte      9         'define the sweep delta theta
inchSafety    byte      30
DAT
'The assembly program below runs on a parallel cog and checks the value of the "position1", "position2" and "position3"
' variables in the main Hub RAM (which other cogs can change at any time). It then outputs three servo high pulses (back to
' back) each corresponding to the three position variables (which represent the number of system clock ticks during which
' each pulse is outputed) and sends a 10ms low part of the pulse. It repeats this signal continuously and changes the width
' of the high pulses as the "position1", "position2" and "position3" variables are changed by other cogs.

ThreeServos   org                         'Assembles the next command to the first cell (cell 0) in the new cog's RAM                                                                                                                     
Loop          mov       dira,ServoPin1    'Set the direction of the "ServoPin1" to be an output (and all others to be inputs)  
              rdlong    HighTime,p1       'Read the "position1" variable from Main RAM and store it as "HighTime"
              mov       counter,cnt       'Store the current system clock count in the "counter" cell's address 
              mov       outa,AllOn        'Set all pins on this cog high (really only sets ServoPin1 high b/c rest are inputs)               
              add       counter,HighTime  'Add "HighTime" value to "counter" value
              waitcnt   counter,0         'Wait until cnt matches counter (adds 0 to "counter" afterwards)
              mov       outa,#0           'Set all pins on this cog low (really only sets ServoPin1 low b/c rest are inputs)

              mov       dira,ServoPin2    'Set the direction of the "ServoPin2" to be an output (and all others to be inputs)  
              rdlong    HighTime,p2       'Read the "position2" variable from Main RAM and store it as "HighTime"
              mov       counter,cnt       'Store the current system clock count in the "counter" cell's address 
              mov       outa,AllOn        'Set all pins on this cog high (really only sets ServoPin2 high b/c rest are inputs)               
              add       counter,HighTime  'Add "HighTime" value to "counter" value
              waitcnt   counter,0         'Wait until cnt matches counter (adds 0 to "counter" afterwards)
              mov       outa,#0           'Set all pins on this cog low (really only sets ServoPin2 low b/c rest are inputs)

              mov       dira,ServoPin3    'Set the direction of the "ServoPin3" to be an output (and all others to be inputs)  
              rdlong    HighTime,p3       'Read the "position3" variable from Main RAM and store it as "HighTime"
              mov       counter,cnt       'Store the current system clock count in the "counter" cell's address    
              mov       outa,AllOn        'Set all pins on this cog high (really only sets ServoPin3 high b/c rest are inputs)            
              add       counter,HighTime  'Add "HighTime" value to "counter" value
              waitcnt   counter,0   'Wait until "cnt" matches "counter" then add a 10ms delay to "counter" value 
              mov       outa,#0           'Set all pins on this cog low (really only sets ServoPin3 low b/c rest are inputs)
              
              
              mov       dira,ServoPin4    'Set the direction of the "ServoPin3" to be an output (and all others to be inputs)  
              rdlong    HighTime,p4       'Read the "position3" variable from Main RAM and store it as "HighTime"
              mov       counter,cnt       'Store the current system clock count in the "counter" cell's address    
              mov       outa,AllOn        'Set all pins on this cog high (really only sets ServoPin3 high b/c rest are inputs)            
              add       counter,HighTime  'Add "HighTime" value to "counter" value
              waitcnt   counter,LowTime   'Wait until "cnt" matches "counter" then add a 10ms delay to "counter" value 
              mov       outa,#0           'Set all pins on this cog low (really only sets ServoPin3 low b/c rest are inputs)
              waitcnt   counter,0         'Wait until cnt matches counter (adds 0 to "counter" afterwards)
              jmp       #Loop             'Jump back up to the cell labled "Loop"                                      
                                                                                                                    
'Constants and Variables:
ServoPin1     long      |<      12 '<------- This sets the pin that outputs the first servo signal (which is sent to the white
                                          ' wire on most servomotors). Here, this "6" indicates Pin 6. Simply change the "6" 
                                          ' to another number to specify another pin (0-31).
ServoPin2     long      |<      13 '<------- This sets the pin that outputs the second servo signal (could be 0-31). 
ServoPin3     long      |<      15
ServoPin4     long      |<      14 '<------- This sets the pin that outputs the third servo signal (could be 0-31).
p1            long      0                 'Used to store the address of the "position1" variable in the main RAM
p2            long      0                 'Used to store the address of the "position2" variable in the main RAM  
p3            long      0
p4            long      0                 'Used to store the address of the "position2" variable in the main RAM
AllOn         long      $FFFFFFFF         'This will be used to set all of the pins high (this number is 32 ones in binary)
LowTime       long      800_000           'This works out to be a 10ms pause time with an 80MHz system clock. If the
                                          ' servo behaves erratically, this value can be changed to 1_600_000 (20ms pause)                                  
counter       res                         'Reserve one long of cog RAM for this "counter" variable                     
HighTime      res                         'Reserve one long of cog RAM for this "HighTime" variable
              fit                         'Makes sure the preceding code fits within cells 0-495 of the cog's RAM
DAT
'-----------[ Predefined Ping variables and constants ]-----------------------------
k_scale        long      65_536            '2^16 (scaling varible on K, needed because K is of order 1)                      
k              long      32_768            'Kalman filter gain, in this case 32_768 / 65_536 = 0.5
x_prev         long      0,0               'Kalman filter estimate of x at previous timestep
x_cur          long      0,0               'Kalman filter estimate of x at current timestep

              