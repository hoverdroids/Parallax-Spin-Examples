{{
OBEX LISTING:
  http://obex.parallax.com/object/580

  The StringKeyMap is an associative array interface. The keys are null-terminated strings.
  The values may be arbitrary-length binary data, but pure-string methods are included for string/string maps.
}}

{{
 StringKeyMap demo (unit test) 
 by Chris Cantrell
 Version 1.1 6/27/2011
 Copyright (c) 2011 Chris Cantrell
 See end of file for terms of use.
}}

{{

 StringKeyMap demo

 This code executes several tests on the StringKeyMap
 data structure. The results are printed on the
 Propeller Serial Terminal.
}}
CON 
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

VAR     
        byte mapData[1024*4]

OBJ                                 
        PST  : "Parallax Serial Terminal.spin"
        
        map  : "StringKeyMap"        

PUB start | c, i, p

  PauseMSec(2_000) ' Allow 2 seconds after programming to start the PST.

  'Initialize PST screen
  PST.Start(115200)
  PST.Home
  PST.Clear

  ' Initialize the data structure 
  map.new(@mapData,1024*4)

  ' Add some key/values
  map.put(@mapData,string("Key1"),string("Value1"))
  map.put(@mapData,string("Key2"),string("Value2"))
  map.put(@mapData,string("Key3"),string("Value3"))

  dumpMapStrings(@mapData)

  PST.Str(string(13))

  ' Replace "Key2" with a new value
  map.put(@mapData,string("Key2"),string("New value2"))

  dumpMapStrings(@mapData)
  
  PST.Str(string(13))

  ' Remove the "Key1" mapping
  map.remove(@mapData,string("Key1"))

  dumpMapStrings(@mapData)
  
  PST.Str(string(13))

  ' Add some binary data
  map.putBinary(@mapData,string("BinaryKey1"),@testData,8)
  map.putBinary(@mapData,string("BinaryKey2"),@testData+3,4)
  map.put(@mapData,string("Key4"),string("012345"))

  dumpMapBinary(@mapData)

  PST.Str(string(13))

  ' Empty the map
  map.clear(@mapData)

  dumpMapBinary(@mapData)      

PUB dumpMapStrings(mapStructure) | x, i, p
'
'' This function dumps the contents of the map as string/string.
'' WARNING: Only null-terminated string values in the map!
'' @mapStructure pointer to the map data structure

  x := map.countEntries(mapStructure)
  PST.Str(string("There are "))
  PST.dec(x)
  PST.Str(string(" entries.",13))
  if x==0
    return
  repeat i from 0 to (x-1)
    p:=map.getKey(mapStructure,i)
    PST.str(string(" '"))
    PST.str(p)
    PST.str(string("' = '"))
    p:=map.getValue(mapStructure,i)
    PST.str(p)
    PST.str(String("'",13))

PUB dumpMapBinary(mapStructure) | x, i, p, c
'
'' This function dumps the contents of the map as string/binary.
'' Since string-values are stored as binary, this works fine
'' for any map.

  x := map.countEntries(mapStructure)
  PST.Str(string("There are "))
  PST.dec(x)
  PST.Str(string(" entries.",13))
  if x==0
    return
  repeat i from 0 to (x-1)
    p:=map.getKey(mapStructure,i)
    PST.str(string(" '"))
    PST.str(p)
    PST.str(string("' = ["))
    p:=map.getValueBinary(mapStructure,i)
    c := map.readWordFromMemory(p)
    p := p + 2
    PST.dec(c)
    PST.str(string("] "))
    repeat while c>0
      PST.hex(byte[p++],2)
      PST.str(string(" "))
      --c
    PST.str(String(13))
    
PRI PauseMSec(Duration)
''  Pause execution for specified milliseconds.
''  This routine is based on the set clock frequency.
''  
''  params:  Duration = number of milliseconds to delay                                                                                               
''  return:  none
  
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)

  return  'end of PauseMSec
  
dat

testData byte 1,2,3,4,5,6,7,8,9,10,11,12               

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
