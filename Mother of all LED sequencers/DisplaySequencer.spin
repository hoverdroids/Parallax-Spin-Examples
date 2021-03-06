{{
OBEX LISTING:
  http://obex.parallax.com/object/399

  This module is a modified copy of my module "Mother of all LED Sequencers"
  In simple terms this software takes bit patterns from memory and passes them to the I/O ports.
  It will work with the Propeller demo Board, The Quickstart board and the PropBOE board.
  It also works with an led driver based on a 74HC595 shift register of my own design
  (See MyLed object for details).The differences between this and the original OBEX module is that
  first this is all spin, second this uses a circular list, and third this is modified to be able
  to wait for an input rather than being strictly timed sequences.

}}
{{                ***** For Demo, Quickstart and my LED Board  *****
                   Copyright Ray Tracy ray0665@tracyfamily.net 2013
                   Released under the MIT license blah blah blah
                   
    Update History
          V2.0    8/25/2013    Initial release
                   
    This module is a modification of my module "Mother of all LED Sequencers" which can be found in the Object Exchange.
    In simple terms this software takes bit patterns from memory and passes them to the I/O ports.  It will work with the
    Propeller demo Board, The Quickstart board and the PropBOE board. It also works with an led driver based on a 74HC595
    shift register of my own design (See MyLed object for details).  The differences between this and the original OBEX
    module is that first this is all spin, second this uses a circular list, and third this is modified to be able to wait
    for an input rather than being strictly timed sequences.

    If more I/O pins are needed you could use some external ICs to greatly extend the I/O. Simply Assign some bits to be
    addresses and the remaining bits as data.  For example assign 8 bits to be addresses, leaving 24 bits of data you then
    have 256 banks of 24 bit I/O or perhaps the 8 address bits could be used as selection/enable bits directly in this case
    you have 8 banks of 24 bits. The same scheme could be used to extend the inputs as well. Actions based on which input
    bits are active could also easily be implemented by adding new states to first test the active bits and then take action.

    
                                             Data Structure Layout    
   Pattern data is held in a DAT block in memory (all longs). Each pattern consists of a label, A  pointer to the
   next pattern, four counts, and a variable number of patterns. The first long holds the address of the next pattern
   to execute.  The second long is the repetition count which controls how many times the pattern repeats. The third
   long is the timing delay for this sequence. The forth long is the number of active bits in the pattern and the fifth
   long is the count of data elements that follow. Subsequent longs are the pattern elements.

   Patterns consist of three longs the first long is the pattern which consists of both input and output bits. Input
   bit positions should normally be set to zero. The second long is the I/O mask it defines which bits are input and
   which are output, place a one where you want an output and a zero where you want an input. The third long is the
   level mask used only for the input bits, place a one where you want the input level inverted.
   
   The demo here expects that the patterns are arranged such that each pattern points to the next in sequence with the
   last pointing back to the first making a circular list.

The Data Structure:

   Example Pattern. This sequence has 8 items as follows:
   0.  @Addr     --> The address of the next pattern, the last points back to the first
   1.  5         --> Number of pattern repetitions
   2.  Sec1      --> This is the time delay for this pattern 
   3.  8         --> This is the number of bits in the data
   4.  2         --> Number of patterns (3 longs each) 
   5.  $90810000 --> 0000 0000 1000 0001 0000 0000 0000 0000
   6.  $FFFFFFFE --> 1111 1111 1111 1111 1111 1111 1111 1110
   7.  $00000001 --> 0000 0000 0000 0000 0000 0000 0000 0001
   This pattern assigns pin zero as an active low input.
   It sends the pattern $00810000 to the io ports and waits for input on pin zero to go low.
   I think of the delay parameter as a switch debounce, if you have clean inputs it can be set to zero.

   Example of the original patterns. This sequence has 14 items as follows:
   0.  @Addr     --> The address of the next pattern, the last points back to the first
   1.  5         --> Number of pattern repetitions
   2.  $02625A00 --> This is the time delay for this pattern (more below)
   3.  8         --> This is the number of bits in the data
   4.  9         --> Number of pattern longs 
   5.  $00810000 --> 0000 0000 1000 0001 0000 0000 0000 0000
   6.  $00420000 --> 0000 0000 0100 0010 0000 0000 0000 0000
   7.  $00240000 --> 0000 0000 0010 0100 0000 0000 0000 0000
   8.  $00180000 --> 0000 0000 0001 1000 0000 0000 0000 0000
   9.  $00000000 --> 0000 0000 0000 0000 0000 0000 0000 0000
  10.  $00180000 --> 0000 0000 0001 1000 0000 0000 0000 0000
  11.  $00240000 --> 0000 0000 0010 0100 0000 0000 0000 0000
  12.  $00420000 --> 0000 0000 0100 0010 0000 0000 0000 0000
  13.  $00810000 --> 0000 0000 1000 0001 0000 0000 0000 0000
   This pattern causes the lighted LED's to start at each end and
   move to the center then back to the ends. The time delay is the
   time between pattern elements. Leds are attached to pins 16-23

The Algorithm  (refer also to the data layout above)

                                          <START> ---- [ 000 ]────────── [ 010 ] ─────────────────────┐
                                                                              |                          
                                                                              |                          │
                                                                                                        │
                                                  ┌────────────────────── [ 020 ]                       │     
                                                                             |                          │     
   000:  Entry point and setup                    │                           |                          │     
   010:  Get the repetition count                 │                           |                          │     
   020:  Get Sequence Start                       │                        [ 030 ]                       │     
   030:  Get the element count                    │                           |                          │     
   040:  Get next element                         │                           |                          │     
                                                  │                                                     │     
   050:  Output the pattern                       │          ┌─────────── [ 040 ]                       │     
   060:  Get Mask and levels                      │                          |                          │     
   070:  Wait for the input                       │          │                |                          │     
   080:  Validate and select action               │          │                                          │     
   090:  Flash error and try again                │          │             [ 050 ]                       │     
                                                  │          │                |                          │     
   200:  Process input                            │          │                |  ┌─────────────┐         │     
   200:  Process input                            │          │                                        │     
   200:  Process input                            │          │              [ 060 ]            │      [ 140 ]  
   200:  Process input                            │          │                |                │              
                                                  │          │                |  ┌────┐        │         │     
   120:  Test for end of current pattern          │          │                              │         │     
   130:  Test for end of repetitions              │          │              [ 070 ]   │        │         │     
   140:  Get the next pattern                     │          │                |  |    │        │         │     
                                                  │          │           Input|  └───┘!Input  │         │     
                                                  │          │                                │         │     
                                                  │          │             [ 080 ]─────────[ 090 ]      │     
                                                  │          │              ||│||           Error        │     
                                                  │          │     ┌───────┘|│|└───────┐               │     
                                                  │          │     │      ┌─┘│└──┐     │               │     
                                                  │          │     │      │   │    │     │               │     
                                                  │          │     │1     │2  │    │3    │4              │     
                                                  │          │   [200]  [210] │  [230] [240]             │     
                                                  │          │     │      │   │    │     |               │     
                                                  │          │                                      │     
                                                  │          │     └──────┴───┼────┴─────┘               │     
                                                  │          │                │                          │     
                                                  │          │                │                          │     
                                                  │          │        !END                              │     
                                                  │          └────────────[ 120 ]                       │     
                                                  │                           │ END                      │     
                                                  │                           │                          │     
                                                  │                           │                          │     
                                                  │                   !END                              │     
                                                  └───────────────────────[ 130 ]──────────────────────┘     
                                                                                     END                       
                                                        
Coding:                                                 
A Short Note on the Programming style used in routine Cycle:
The general coding form used here follows a map such as the one above like this
                                                        
Proc()                                                  
    Done = false, state = first state                   
    repeat                                              
        << Optional debug statements here >>            
       case state                                       
          state1: do something, setup state 2           
          state2: do something, setup state N           
          stateN: do something, setup next state
          LastState: Cleanup, Done := True
          Other:  Trap for when things really go wrong
    until Done

Since the case statement selects only one state each pass, it is very easy to add debug
statements between the repeat and the case statements that execute once each state.
For example you could print the state number and follow the logic on screen.

Each state performs one task in the algorythm and the last state sets the Done variable true.
Done however is not used in the cycle routine below since the cycle routine never ends.

And finally, This method is not the most efficient coding method but I would argue that in
most cases we have all the time we need and a few wasted cycles is insignificant.  Also,
since I can't remember what I did yesterday, for me at least, the gain in understanding and
supportability are far more valuable in the long term.

   #################################### < NOTES ON THIS DEMO > ##############################################
   For this demo, I am using the quickstart boards buttons and LEDS to simulate an I/O device.
   I have included a quickstart GetButtons routine that I used used in state 070.
   To test using the Demo board you need to build an input circuit (a bare wire works) to provide the input.
   Routine LightDaLights in state 060 and the Flash routine are just here for demo purposes.
   ##########################################################################################################
   There are some significent differences in behavour depending on how you set things up in states 070 & 080.
   I have left some statements in place that you can use to see the different behavours.
   I have it setup to get an input and output the next pattern and repeat. This case I select the input by
   masking in 070 and set state 080 to go right to state 120. In a similar manner you can do the I/O directly
   (here you most likely will need to deal with switch bounce I used the delay to wait 50 ms).
   Lastly you can simply get the input in state 070 with no masking and do all the selection / debouncing
   logic in state 080 and the action states.   Try them all to see what works best for your project. 
   ###########################################################################################################
   If you make 2 changes to state 050 you will mimic the original LEDSequencer behavour.
   1. Go straight to state 120.   2. Uncomment the delay.
   I have included some original style patterns so you can do exactly that.
   ###########################################################################################################

}}
CON
  _CLKMODE      = XTAL1 + PLL16X
  _XINFREQ      = 5_000_000
  
'===============< Precalculated Delay Times >=================
  Clock         = 80_000_000       '5Mhz Crystal
  Sec1          = Clock
  ms500         = Clock / 2
  ms333         = Clock / 3
  ms250         = Clock / 4 
  ms200         = Clock / 5
  ms125         = Clock / 8       
  ms100         = Clock / 10
  ms50          = Clock / 20
  ms40          = clock / 25
  ms33          = Clock / 30
  ms20          = Clock / 50
  ms10          = Clock / 100 
  ms5           = Clock / 200
  ms2           = Clock / 500
  ms1           = Clock / 1000 
' Quickstart board
  ioPins0        = 0          
' Led board One I/O pin assignments  
  DataPin1       = 5          ' Shift Register Data   --> White
  ClkPin1        = 6          ' Shift Register Sh-Clk --> Red
  EnaPin1        = 7          ' Shift Register St-Clk --> Black
  ioPins1        = |<DataPin1 + |<ClkPin1 + EnaPin1
' Led board Two I/O pin assignments  
  DataPin2       = 10          ' Shift Register Data   --> White
  ClkPin2        = 11          ' Shift Register Sh-Clk --> Red
  EnaPin2        = 12          ' Shift Register St-Clk --> Black
  ioPins2        = |<DataPin2 + |<ClkPin2 + EnaPin2

  LedPins        = $00FF0000   ' Put a one where there is an led attached
  XorBits        = 0           ' Output Logic level adjustment pattern 1=invert 0=no invert

  #0, Left,Right
  #0, Demo,Quick,LedBrd                                              ' I/O board type
  #0, NxtPtr, Reps, Delay, ESize, NumElem, Elem1    ' List offsets

OBJ
  Pst    : "Parallax Serial Terminal"      ' Ok to remove afer debugging / test complete
  Led[2] : "MyLed"                         ' interface to my serial Led board
  Button : "GetButtons"

Var
  long stack1[32],Stack2[32]
  Long RotateBits
  Byte Type

PUB LedDemo | P1,P2
''         Next Pattern     : @@Long[P1][NexPtr]
''         Num Repetitions  : Long[P1][Reps]
''         Delay            : Long[P1][Delay]
''         Element Width    : Long[P1][ESize]
''         Element Count    : Long[P1][NumElem]
''         Data Patterns    : Long[P1][4..N]
  Pst.Start(115200)
  Type := Quick
  Case Type
      Demo,Quick:
          RotateBits := 0                                     ' Align bit positions for these boards
          P1 := @IoP1                                         ' Point to the Starting Pattern
          Cycle(0,P1,Type,0,ioPins0,RotateBits)               ' Launch the display
      LedBrd:                                                 ' I have two led boards attached
          RotateBits := 16                                    ' Align bit positions for led boards
          P1 := @IoP1                                         ' Point to the Starting Pattern
          cognew(Cycle(0,P1,Type,DataPin1,ioPins1,RotateBits),@Stack1)   ' Launch the display for board one
          P2 := @IoP1                                                    ' Board 2, Point to the Starting Pattern
          Cycle(1,P2,Type,DataPin2,ioPins2,RotateBits)                   ' This one must be last since cycle never returns


Pri Cycle(Cpy, Ptr, Board, Dp, ioPins, Rotate) | State, R1, Seq, DSize, ECount, Data, IoMask, LvlMsk, Temp
      State := 000                                                 ' The initial State
      repeat                                                       ' Ye Ol Coffee Grinder
'         StateDisplay(State)                                                      
         case State
             000:  '' Entry point and setup
                State := 010                                        ' Assume next state
                case Board                                          ' Setup for the the board in use
                   Demo,Quick: dira |= LedPins                      ' Enable i/o for demo & quickstart boards
                   LedBrd: Led[Cpy].Init(Dp)                        ' Initialize LED Driver
                                                   
             010:  '' Get the Repetition count
                   State := 020                   
                   R1 := Long[Ptr][Reps]                            ' Get the repetition count

             020:  '' Get Sequence Start
                   State := 030                                
                   Seq := Elem1                                     ' Position of first element
                                                                
             030:  '' Get the element count and Width
                   State := 040
                   ECount := Long[Ptr][NumElem]                     ' Load the count
                   DSize  := Long[Ptr][ESize]                       ' Load the Data size

             040:  '' Get next element
                   State := 050
                   Data := long[Ptr][Seq++]                         ' Get pattern data

             050:  '' Output the pattern
                   State := 60
                   LightDaLights(Cpy, Board, Data, DSize, Rotate)     ' Turn on/off the leds
'                   waitcnt(Long[Ptr][Delay]+cnt)                      ' Wait the pattern delay time

             060:  '' Type 2 - Get the IoMask and LevelMask
                   State := 070
                   IoMask := long[Ptr][Seq++]                        ' Get the Input Pins
                   LvlMsk := long[Ptr][Seq++]                        ' Get the level Mask

             070:   '' Test for the Input condition
                   State := 070                                      ' Stay here until an input
'                   Temp := ina & !IoPins                             ' Get the input state and mask inactive pins
'                   Temp ^= LvlMsk                                   ' adjust input logic levels
'                   Temp := Button.State                              ' Get the input switch state from quickstart board
                   Temp := Button.State & !ioMask                    ' See my comments above.
                   if Temp                                           ' Test for input bit(s) high
                      State := 080                                   ' Got the input
                                                   
             080:  '' Validate and select action
                  State := 120             
'                  waitcnt(Long[Ptr][Delay]+cnt)                      ' Wait the pattern delay time
'                  case Temp                                          ' Here is where we select different actions
'                       $80: State := 200                             
'                       $40: State := 210                             
'                       $20: State := 230                             
'                       $10: State := 240                             
'                       other: State := 090                           ' unknown input, Flash error and try again

             090:  State := 060  '' Error - Unknown input trap just flash the lights and try again
                             repeat 5
                                Flash(Cpy, Board, $AA, $55, 16, Ms100)   

             200:  State := 120 '' Process input                    ' For type 2 patterns delay doesnt make much sense
                             repeat 5                               ' it is really just a number available for your use
                                Flash(Cpy, Board, $F0, 0, 16, Long[Ptr][Delay]) ' but I used it here just because I could 

             210:  State := 120 '' Process input
                             repeat 5
                                Flash(Cpy, Board, $0F, 0, 16, Long[Ptr][Delay])   

             230:  State := 120  '' Process input
                             repeat 5
                                Flash(Cpy, Board, $C3, 0, 16, Long[Ptr][Delay])   

             240:  State := 120  '' Process input
                             repeat 5
                                Flash(Cpy, Board, $3C, 0, 16, Long[Ptr][Delay])   
             
             120:  '' Test for end of current pattern
                   State := 40                                      ' Assume there are more patterns
                   if --ECount == 0
                      State := 130                                  ' New state if end of pattern

                                                           
             130:  '' Test for end of repetitions
                   State := 020                                     ' Assume there are more repetitions to go
                   if --R1  == 0
                      State := 140                                  ' New state if end of repetitions
                                                           
             140:  '' Get the next pattern                                
                   State := 010                                     ' Start over with next pattern
                   Ptr := @@Long[Ptr][NxtPtr]                       ' Get Next Pattern and start over

             other:   '' Crash This is really bad
                 Debug(Ptr, State, Seq, Data, R1, ECount, IoMask, LvlMsk, Temp)   'For debug, Show the variables and die
                 repeat
                    Flash(Cpy, Board, $FF, 0, 16, Ms100)   
              

Pri LightDaLights(Cpy, Board, _Data, Width,_Rotate)                   ' --- Here is where we light the lights ---
'' This routine aligns and converts logic levels as necessary
'' then sends the data pattern to the LEDs
'' Inputs:  Cpy - Instance number
''          Board - Board Type
''          _Data - 32 bit Led pattern
''          Number of bits in the pattern
       case Board                                                   ' Select the board type
           Demo,Quick: _Data <-= _Rotate                            ' Rotate the pattern to align with I/O pins
                       _Data ^= XorBits                             ' Set logic levels
                       outa := _Data                                ' Demo,Quickstart
           LedBrd:
                     _Data <-= _Rotate
                     Led[Cpy].ShowByte(_Data, Width, Left)          ' For my Shift register Led Board

Pri Flash(_Cpy, _Board, D1, D2, _Rotate, _Delay)
    LightDaLights(_Cpy, _Board, D1, 8, _Rotate)   
    Waitcnt(_Delay+cnt)                  
    LightDaLights(_Cpy, _Board, D2, 8, _Rotate)   
    Waitcnt(_Delay+cnt)                 

Pri StateDisplay(St)| first     ' ##### This is for diagnostics
    case St                
       070: if first                
              first := False
              Pst.Newline       ' ##### Print a newline and the state only the first time through
              Pst.Dec(St)       ' ##### Show what state we are in
              Pst.Str(String(" - "))
       other: first := True
              Pst.Dec(St)       ' ##### Show what state we are in
              Pst.Str(String(" - "))
              

Pri Debug(_Ptr, State, Seq, Data, R1, ECount, IoMask, LvlMsk, Temp)                  ' Used for debugging,  Print a bunch of stuff
  Pst.str(String(13,"-------------------<< "))
  Pst.Str(String("State: "))
  Pst.Dec(State)
  Pst.Str(String(" >>----------------------"))
  Pst.Str(String(13,"   PTR: "))
  Pst.hex(_Ptr,8)
  Pst.Str(String(13,"   Reps: "))
  Pst.hex(R1,8)
  Pst.Str(String(13,"   Seq: "))
  Pst.hex(Seq,8)
  Pst.Str(String(13,"   ECount: "))
  Pst.hex(ECount,8)
  Pst.Str(String(13,"   Delay: "))
  Pst.hex(Long[_Ptr][Delay],8)
  Pst.Str(String(13,"   Data: "))
  Pst.hex(Data,8)
  Pst.Str(String(13,"   IoMask: "))
  Pst.hex(IoMask,8)
  Pst.Str(String(13,"   LvlMsk: "))
  Pst.hex(LvlMsk,8)
  Pst.Str(String(13,"   Temp: "))
  Pst.hex(Temp,8)
  Pst.Newline

Dat      '  NextPat, Repetitions, Delay, DataSize, NumElements, Element1, Element2, . . . ElementN

' This is a test setup for use with the quickstart board      
IoP1  Long @IoP2, 1, Ms50, 8, 1
      Long $00810000, $FFFFFF7F, $00000000
IoP2  Long @IoP3, 1, Ms50, 8, 1 
      Long $003C0000, $FFFFFFBF, $00000000
IoP3  Long @IoP4, 1, Ms50, 8, 1 
      Long $00CC0000, $FFFFFFDF, $00000000
IoP4  Long @IoP1, 1, Ms50, 8, 1 
      Long $00330000, $FFFFFFEF, $00000000
      
Pat1  long  @Pat2, 5, Ms200, 8, 9               
      long  $00810000, $00420000, $00240000, $00180000, $00000000, $00180000, $00240000, $00420000
      long  $00810000
' Light one at a time from left to right and back 5 times
Pat2  long  @Pat3, 5, Ms50, 8, 16
      long  $00010000, $00020000, $00040000, $00080000, $00100000, $00200000, $00400000, $00800000
      long  $00800000, $00400000, $00200000, $00100000, $00080000, $00040000, $00020000, $00010000
' Shift from all off to all on 5 times
Pat3  long  @Pat4, 5, Ms50, 8, 32                 
      long  $00010000, $00030000, $00070000, $000F0000, $001F0000, $003F0000, $007F0000, $00FF0000
      long  $00FE0000, $00FC0000, $00F80000, $00F00000, $00E00000, $00C00000, $00800000, $00000000
      long  $00800000, $00C00000, $00E00000, $00F00000, $00F80000, $00FC0000, $00FE0000, $00FF0000
      long  $007F0000, $003F0000, $001F0000, $000F0000, $00070000, $00030000, $00010000, $00000000
' Alternate between left 4 and right four 10 times
Pat4  long  @Pat1, 10, Ms200, 8, 2           
      long  $000F0000, $00F00000

' This marks the end of all the patterns
