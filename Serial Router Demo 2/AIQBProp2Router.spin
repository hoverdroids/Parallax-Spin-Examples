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
inputpins      byte 10,     2,     5,     6,     9,     24,    13,    15,    17,    19,    21,    23,      31      ' Hardware input pin
outputpins     byte 11,     3,     4,     7,     8,     25,    12,    14,    16,    18,    20,    22,      30      ' Hardware output pin
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












































' auxilliary cog functions here. This can be treated pretty much like a normal standalone microcontroller.
' Exception: use aux0_com for serial output and, to xmit, do aux0_txflag~~ for serial receive, use reacttopacket and read aux0_buffer_rx.
' Note that a blocking function is OK and will not impair the rest of the router! (see example)
obj
aux0_com: "stringoutput_external_buffer"
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

'for servo driver
long  position1, position2, position3    'The assembly program will read these variables from the main Hub RAM to determine
                                           ' the high pulse durations of the three servo signals

pri aux0_loop ' auxiliary cog function. Should not need modifications.
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
  'if aux0_buffer_rx[0]=="A" 'note that the aux0_buffer_rx does not get reset until a new message is received;also, the buffer does not include the address
    'outa[27]:=1
    'waitcnt(clkfreq+cnt)
    'outa[27]:=0
    'waitcnt(clkfreq+cnt)
  ''aux0_com.str(string("@00@test")) 'was using for?
  ''aux0_txflag~~                    'was using for?
'use the following for a passthrough...nothing is required since that can be set by default
'repeat
 '!outa[0..7]
 'waitcnt(clkfreq+cnt)

  p1:=@position1                           'Stores the address of the "position1" variable in the main Hub RAM as "p1"
  p2:=@position2                           'Stores the address of the "position2" variable in the main Hub RAM as "p2"
  p3:=@position3                           'Stores the address of the "position3" variable in the main Hub RAM as "p3"
  cognew(@ThreeServos,0)                   'Start a new cog and run the assembly code starting at the "ThreeServos" cell         

  'The new cog that is started above continuously reads the "position1", "position2", and "position3" variables as they are
  ' changed by the example Spin code below
  repeat                                                                                                                 
    position1:=144_000                     'Start sending 2.25ms servo signal high pulses to servomotor 1  (CCW position)                                                 
    position2:=144_000                     'Start sending 1.375ms servo signal high pulses to servomotor 2 (Center position)
    position3:=144_000                      'Start sending 0.5ms servo signal high pulses to servomotor 3   (CW position)
    waitcnt(clkfreq*5+cnt)                   'Wait for 1 second (pulses continue to be generated by the other cog)                                                                
    position1:=105_600                     'Start sending 1.375ms servo signal high pulses to servomotor 1 (Center position)                                                  
    position2:=105_600
    position3:=105_600                     'Start sending 1.375ms servo signal high pulses to servomotor 3 (Center position)
                                           'Note: 1.375ms servo signal high pulses continue to be sent to servomotor 2
    waitcnt(clkfreq*5+cnt)                   'Wait for 1 second (pulses continue to be generated by the other cog)                                                                  
    'position1:=132_000                      'Start sending 0.5ms servo signal high pulses to servomotor 1   (CW position)                                              
    'position2:=132_000                      'Start sending 0.5ms servo signal high pulses to servomotor 2   (CW position)
    'position3:=132_000                     'Start sending 2.25ms servo signal high pulses to servomotor 3  (CCW position)
    'waitcnt(clkfreq/4+cnt)                   'Wait for 1 second (pulses continue to be generated by the other cog)
 


pub aux0_ReactToPacket'(PacketAddr,FromWhere) ' auxilliary cog function called when the virtual internal serial port got something. aux0_buffer_rx contains it and aux0_lastorigin says where it's from.

    repeat 5

         if (++result & 1)
             BuildAddress(aux0_lastorigin,@okstr)
             aux0_com.str(@okstr)
         else
             errcode:="!"
             BuildAddress(aux0_lastorigin,@errstr)
             aux0_com.str(@errstr)

         aux0_com.str(string(" AUX COMMAND PROCESSED!",13))
         aux0_txflag~~

         waitcnt(cnt+clkfreq)
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
              waitcnt   counter,LowTime   'Wait until "cnt" matches "counter" then add a 10ms delay to "counter" value 
              mov       outa,#0           'Set all pins on this cog low (really only sets ServoPin3 low b/c rest are inputs)
              waitcnt   counter,0         'Wait until cnt matches counter (adds 0 to "counter" afterwards)
              jmp       #Loop             'Jump back up to the cell labled "Loop"                                      
                                                                                                                    
'Constants and Variables:
ServoPin1     long      |<      12 '<------- This sets the pin that outputs the first servo signal (which is sent to the white
                                          ' wire on most servomotors). Here, this "6" indicates Pin 6. Simply change the "6" 
                                          ' to another number to specify another pin (0-31).
ServoPin2     long      |<      13 '<------- This sets the pin that outputs the second servo signal (could be 0-31). 
ServoPin3     long      |<      14 '<------- This sets the pin that outputs the third servo signal (could be 0-31).
p1            long      0                 'Used to store the address of the "position1" variable in the main RAM
p2            long      0                 'Used to store the address of the "position2" variable in the main RAM  
p3            long      0                 'Used to store the address of the "position2" variable in the main RAM
AllOn         long      $FFFFFFFF         'This will be used to set all of the pins high (this number is 32 ones in binary)
LowTime       long      800_000           'This works out to be a 10ms pause time with an 80MHz system clock. If the
                                          ' servo behaves erratically, this value can be changed to 1_600_000 (20ms pause)                                  
counter       res                         'Reserve one long of cog RAM for this "counter" variable                     
HighTime      res                         'Reserve one long of cog RAM for this "HighTime" variable
              fit                         'Makes sure the preceding code fits within cells 0-495 of the cog's RAM


{Copyright (c) 2008 Gavin Garner, University of Virginia
MIT License: Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and
this permission notice shall be included in all copies or substantial portions of the Software. The software is provided
as is, without warranty of any kind, express or implied, including but not limited to the warrenties of noninfringement.
In no event shall the author or copyright holder be liable for any claim, damages or other liablility, out of or in
connection with the software or the use or other dealings in the software.}       

    