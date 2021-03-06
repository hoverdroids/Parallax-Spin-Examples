{{
   ***************************************
   * Bot Graphics for Network Bot Example*
   * Martin Hebel                        *
   * Version 1.0     Copyright 2009      *
   ***************************************
   *  See end of file for terms of use.  *               
   ***************************************

   Accepts drive, bearing and range information
   from Propeller driven bot for display.

   Some graphics routines courtesy of Jim Fouch.
    
}}

CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  _stack = ($3000 + 100) >> 2    'accomodate display memory and stack

  ' Set pins and Baud rate for XBee comms  
  XB_Rx     = 7        ' XBee Dout
  XB_Tx     = 6        ' XBee Din
  XB_Baud   = 9600

  MY_Addr   = 2

  ' Size of screeen tiles
  x_tiles = 16
  y_tiles = 12

  paramcount = 14       
  Display_base = $5000

   ' Colors
  CL_Black      = $02
  CL_Grey1      = $03
  CL_Grey2      = $04
  CL_Grey3      = $05
  CL_Grey4      = $06
  CL_White      = $07
  CL_Blue       = $0A
  CL_SkyBlue    = $2C
  CL_DarkBlue   = $3A
  CL_Green      = $F8
  CL_DarkGreen  = $4A
  CL_Red        = $48
  CL_Brown      = $9B
  CL_Yellow     = $9E
  CL_Purple     = $88
  CL_DarkPurple = $EA
  ' Use Graphics_Palette to find more colors

VAR

  long  tv_status     '0/1/2 = off/visible/invisible       read-only
  long  tv_enable     '0/? = off/on                        write-only
  long  tv_pins       '%ppmmm = pins                       write-only
  long  tv_mode       '%ccinp = chroma,inter,ntsc/pal,swap write-only
  long  tv_screen     'pointer to screen (words)           write-only
  long  tv_colors     'pointer to colors (longs)           write-only                   
  long  tv_hc         'horizontal cells                    write-only
  long  tv_vc         'vertical cells                      write-only
  long  tv_hx         'horizontal cell expansion           write-only
  long  tv_vx         'vertical cell expansion             write-only
  long  tv_ho         'horizontal offset                   write-only
  long  tv_vo         'vertical offset                     write-only
  long  tv_broadcast  'broadcast frequency (Hz)            write-only
  long  tv_auralcog   'aural fm cog                        write-only

  word  screen[x_tiles * y_tiles]
  long  colors[64]

  Long bearing, range, rDrive, lDrive, RSSI            ' current values
  Long bearing_l, range_l, rDrive_last, lDrive_last, RSSI_l ' last 
OBJ
  tv    : "tv"
  gr    : "graphics"
  num   : "Numbers"
  XB    : "XBee_Object"

PUB start  | c,x

  'start tv
  longmove(@tv_status, @tvparams, paramcount)
  tv_screen := @screen
  tv_colors := @colors
  tv.start(@tv_status)

  ' Create pallete of 4 sets of colors  
  '              palette  
  '              num   color 0     color 1     color 2  color 3 
  SetColorPalette(0,   CL_White,   CL_Black,   CL_Red,  CL_Yellow)   
 
  'init tile screen - set up tiles with selected palettes
  '           start   start    end        end       palette
  '           col     row      col        row       num
  SetAreaColor(0,     0,       TV_HC-1,   TV_VC-1,   0)  

  range := 50                          ' Initial Values 
  rdrive := 1500
  ldrive := 1500

  gr.start                              ' start and setup graphics    
  gr.setup(16, 12, 0, 0, display_base)  ' display memory for drawing 
  Update                                ' Draw Display

  XB.start(XB_Rx, XB_Tx, 0, XB_Baud)    ' Initialize comms for XBee
  XB.AT_Init                            ' Fast AT updates
  XB.AT_ConfigVal(string("ATMY"), MY_Addr) 
  XB.AT_Config(string("ATAP 1"))        ' Switch to API mode
  
  Repeat
    XB.API_rx                           ' Accept data
    If XB.RxIdent == $81                ' If msg packet...
      if byte[XB.RxData] == "u"         ' If updates, pull out data
          ' get DEC data skipping 1st byte (u)
        range   := XB.ParseDEC(XB.RxData+1,1)
        bearing := XB.ParseDEC(XB.RxData+1,2)
        rDrive  := XB.ParseDEC(XB.RxData+1,3) <#2000 #>1000
        lDrive  := XB.ParseDEC(XB.RxData+1,4) <#2000 #>1000
        RSSI    := XB.RxRSSI
        Update
      if byte[XB.RxData] == "m"          ' if mapping data
        range := XB.ParseDEC(XB.RxData+1,1)
        bearing := XB.ParseDEC(XB.RxData+1,2)
        Map
      if byte[XB.RxData] == "c"          ' if clear command
        gr.clear                         ' clear display
        update                           ' redraw fresh

Pub Map
'' Plot points in red for map scan
    gr.color(2)
    gr.width(2)
    ' draw an arc scaling range for screen, offset bearing value
    gr.arc(120,120, range/20,range/20,bearing+2048,8,10,0)

Pub Update
'' updates the screen with received data
    ' draw arcs on screen scaled at .25m, .5m, 1.0m
    gr.color(3)                 
    gr.width(1)                                   ' yellow
    gr.arc(120,120, 250/20,250/20,0,8,2047,0)
    gr.arc(120,120, 500/20,500/20,0,8,2047,0)
    gr.arc(120,120, 1000/20,1000/20,0,8,2047,0)

    ' title screen
    gr.textmode(2,2,6,0)
    gr.width(2)
    gr.color(1)                                   ' black
    gr.text(20,165,string("3-Node Bot System"))

    ' text and value for range
    gr.text(120,25,string("Range:"))
    gr.color(0)                                   ' white
    gr.text(180,25,num.toStr(range_l,num#Dec))    ' erase last
    gr.color(1)                                   ' black
    gr.text(180,25,num.toStr(range,num#Dec))      ' new value

    ' text and value for angle
    gr.text(120,0,string("Angle:"))               
    gr.color(0)                                   ' white
    gr.text(180,0,num.toStr(bearing_l,num#Dec))   ' erase last
    gr.color(1)                                   ' black
    gr.text(180,0,num.toStr(bearing,num#Dec))     ' new value

    ' text and value for RSSI
    gr.text(5,0,string("dBm:"))                   
    gr.color(0)                                   ' white
    gr.text(55,0,num.toStr(-RSSI_l,num#Dec))      ' erase last
    gr.color(1)                                   ' black
    gr.text(55,0,num.toStr(-RSSI,num#Dec))        ' new value

    ' Draw bot vector image
    gr.width(2)
    gr.color(0)                                   ' white
    gr.vec(120,120, 100, (bearing_l), @bot)       ' erase last image
    gr.color(1)                                   ' black
    gr.vec(120,120, 100, (bearing), @bot)         ' Draw new image

    ' draws small arc at correct angle and range for detected object
    ' range and bearing offset accordingly
    gr.color(0)                                   ' white - erase last
    gr.arc(120,120, range_l/20,range_l/20,(bearing_l+2048),8,10,0)
    gr.color(2)                                   ' black - draw new
    gr.arc(120,120, range/20,range/20,(bearing+2048),8,10,0)

    ' RSSI bar - draw background * level lines based on RSSI level
    gr.width(5)
    gr.color(3)                         ' Yellow
    gr.plot(0,40)                       ' draw yellow line
    gr.line(100,40)
    gr.color(2)                         ' red
    gr.plot(0,40)                       ' draw line based on RSSI
    gr.line(100-RSSI,40)

    ' left drive bar - yellow line then scaled red line
    gr.color(3)
    gr.plot(5,70)
    gr.line(5,170)
    gr.color(2)
    gr.plot(5,120)
    gr.line(5, 120 + (lDrive-1500)/10)   ' 1500 is 0 drive

    ' Right drive - yellow line then scaled redline
    gr.color(3)
    gr.plot(235,70)
    gr.line(235,170)
    gr.color(2)
    gr.plot(235,120)
    gr.line(235, 120 + (1500-rDrive)/10)  ' 1590 is 0 drive

    ' save last data to erase next pass
    bearing_l := bearing                  
    range_l := range
    RSSI_l := RSSI

    
Pub SetAreaColor(X1,Y1,X2,Y2,ColorIndex)|DX,DY
  '' Courtesy of Jim Fouch
  '' sets the colors for the specified area of screen
  X1 := 15 - X1 
  Y1 := 11 - Y1 
  X2 := 15 - X2 
  Y2 := 11 - Y2 
  Repeat DX from X1 to X2
    Repeat DY from Y1 to Y2
      SetTileColor(DX,DY,ColorIndex)
    
Pub SetTileColor( x, y, ColorIndex)
  '' Courtesy of Jim Fouch
  '' sets individual tile colors
   screen[y * tv_hc + x] := display_base >> 6 + y + x * tv_vc + ((ColorIndex & $3F) << 10)
 
Pub SetColorPalette(ColorIndex,Color1,Color2,Color3,Color4)
  '' Courtesy of Jim Fouch
  '' sets palletes color for specified tile
  colors[ColorIndex] := (Color1) + (Color2 << 8) +  (Color3 << 16) + (Color4 << 24)     



DAT

tvparams                long    0               'status
                        long    1               'enable
                        long    %001_0101       'pins
                        long    %0000           'mode
                        long    0               'screen
                        long    0               'colors
                        long    x_tiles         'hc
                        long    y_tiles         'vc
                        long    10              'hx
                        long    1               'vx
                        long    0               'ho
                        long    0               'vo
                        long    0               'broadcast
                        long    0               'auralcog



'' Vector sprite definition:
''
''    word    $8000|$4000+angle       'vector mode + 13-bit angle
                                      ''(mode: $4000=plot, $8000=line)
''    word    length                  'vector length
''    ...                             'more vectors
''    ...
''    word    0                       'end of definition

bot                     word    $4000 + 0    'triangle to represent bot
                        word    0
                        word    $8000 + 8192/360*260
                        word    60
                        word    $8000 + 8192/360*300
                        word    60
                        word    $8000 + 0
                        word    0
                        word    0

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