''This code example is from Propeller Education Kit Labs: Fundamentals, v1.1.
''A .pdf copy of the book is available from www.parallax.com, and also through
''the Propeller Tool software's Help menu (v1.2.6 or newer).
''
{{
StackLengthDemoModified.spin

This is a modified version of Stack Length Demo object from the Propeller Library
Demos folder.  This modified version tests the Propeller Education Kit Objects
lab's Blinker object's Blink method for stack space requirements.  See Project #2
in the Objects lab for more information.
}}

{•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
  Temporary Code to Test Stack Usage
••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••}

CON
  _clkmode      = xtal1 + pll16x         'Use crystal * 16 for fast serial               
  _xinfreq      = 5_000_000              'External 5 MHz crystal on XI & XO

OBJ
  Stk   :       "Stack Length" 'Include Stack Length Object

PUB TestStack
  Stk.Init(@Stack, 32)         'Initialize reserved Stack space (reserved below)
  start(4, clkfreq/10, 20)     'Exercise code/object under test
  waitcnt(clkfreq * 3 + cnt)   'Wait ample time for max stack usage
  Stk.GetLength(30, 19200)     'Transmit results serially out P30 at 19,200 baud


{•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
Code/Object Being Tested for Stack Usage
••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••}

{{
File: Blinker.spin
Example cog manager for a blinking LED process.

SCHEMATIC
─────────────────────────────── 
          100 Ω  LED     
    pin ──────────┐
                        
                      GND
─────────────────────────────── 
}}

VAR
  long  stack[32]                      'Cog stack space
  byte  cog                            'Cog ID


PUB Start(pin, rate, reps) : success
{{Start new blinking process in new cog; return True if successful.

Parameters:
  pin - the I/O connected to the LED circuit → see schematic
  rate - On/off cycle time is defined by the number of clock ticks
  reps - the number of on/off cycles
}}
  Stop
  success := (cog := cognew(Blink(pin, rate, reps), @stack) + 1)


PUB Stop
''Stop blinking process, if any.

  if Cog
    cogstop(Cog~ - 1)


PUB Blink(pin, rate, reps)
{{Blink an LED circuit connected to pin at a given rate for reps repetitions.

Parameters:
  pin - the I/O connected to the LED circuit → see schematic
  rate - On/off cycle time is defined by the number of clock ticks
  reps - the number of on/off cycles
}}

    dira[pin]~~
    outa[pin]~
    
    repeat reps * 2
       waitcnt(rate/2 + cnt)
       !outa[pin]