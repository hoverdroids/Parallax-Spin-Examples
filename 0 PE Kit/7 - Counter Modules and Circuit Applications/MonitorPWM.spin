''This code example is from Propeller Education Kit Labs: Fundamentals, v1.1.
''A .pdf copy of the book is available from www.parallax.com, and also through
''the Propeller Tool software's Help menu (v1.2.6 or newer).
''
{{
MonitorPWM.spin

Monitors characteristics of a probed PWM signal, and updates addresses in main RAM
with the most recently measured pulse high/low times and pulse count.  

How to Use this Object in Your Application
------------------------------------------
1) Declare variables for high time, low time, and pulse count.  Example:
   
   VAR 
     long tHprobe, tlprobe, pulseCnt

2) Declare the MonitorPWM object.  Example:
   
   OBJ 
     probe : MonitorPWM

3) Call the start method and pass the I/O pin used for probing and the variable addresses
   from step 1.  Example:
   
   PUB MethodInMyApp
     '... 
     probe.start(8, @tHprobe, @tLprobe, @pulseCnt)

4) The application can now use the values of tHprobe, tLprobe, and pulseCnt to monitor
   the pulses measured on the I/O pin passed to the start method (P8 in this example).
   In this example, this object will continuously update tHprobe, tLprobe, and pulseCnt
   with the most recent pulse high/low times and pulse count.  

See Also
--------
TestDualPwmWithProbes.spin for an application example.

Tips in this object's source code comments are discussed in the Propeller Education
Kit Labs: Fundamentals book.

}}

VAR
  long cog, stack[20]                        ' Tip 1, global variables for cog and stack.
  long apin, thaddr, tladdr, pcntaddr        ' Tip 1, global variables for the process.

PUB start(pin, thighAddr, tlowaddr, pulsecntaddr) : okay

  '' Starts the object and launches PWM monitoring process into a new cog.  
  '' All time measurements are in terms of system clock ticks.
  ''
  '' pin - I/O pin number
  '' tHighAddr - address of long that receives the current signal high time measurement.
  '' tLowAddr - address of long that receives the current signal low time measurement.
  '' pulseCntAddr - address of long that receives the current count of pulses that have 
  ''                been measured.

  ' Copy method's local variables to object's global variables
  ' You could also use longmove(@apin, @pin, 4) instead of the four commands below.
  apin := pin                                ' Tip 2, copy parameters to global variables    
  thaddr := tHighAddr                        ' that the process will use.
  tladdr := tLowAddr
  pcntaddr := pulseCntAddr

  ' Launch the new cog.
  okay := cog := cognew(PwmMonitor, @stack) + 1  
    
PUB stop

  '' Stop the PWM monitoring process and free a cog.

  if cog
    cogstop(cog~ - 1)

PRI PwmMonitor

  ' Tip 3, set up counter modules and I/O pin configurations(from within the new cog!)

  ctra[30..26] := %01000                             ' POS detector
  ctra[5..0] := apin                                 ' I/O pin
  frqa := 1

  ctrb[30..26] := %01100                             ' NEG detector
  ctrb[5..0] := apin                                 ' I/O pin
  frqb := 1

  phsa~                                              ' Clear counts
  phsb~

  ' Set up I/O pin directions and states.
  dira[apin]~                                        ' Make apin an input

  ' PWM monitoring loop.
  
  repeat                                             ' Main loop for pulse 
                                                     ' monitoring cog.
    waitpeq(|<apin, |<apin, 0)                       ' Wait for apin to go high.
    long[tladdr] := phsb                             ' Save tlow, then clear.
    phsb~
    waitpeq(0, |<apin,0)                             ' Wait for apin to go low.
    long[thaddr] := phsa                             ' Save thigh then clear.
    phsa~
    long[pcntaddr]++                                 ' Increment pulse count.