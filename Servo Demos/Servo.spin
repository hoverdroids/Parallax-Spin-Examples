OBJ
  SERVO : "Servo32v7.spin"

CON
    _clkmode = xtal1 + pll16x                           
    _xinfreq = 5_000_000 

    ServoCh1 = 0                ' Servo to pin 0

PUB Servo32_DEMO

    SERVO.Start                 ' Start servo handler
    
  repeat
    ' Syntax: SERVO.Set(Pin, Width)
    SERVO.Set(ServoCh1,2250)    ' 2000 usec 
    repeat 800000               ' Wait a short bit
    'SERVO.Set(ServoCh1,1000)      ' 1000 usec
    'repeat 800000                           
    SERVO.Set(ServoCh1,750)    ' 1500 usec (centered)
    repeat 800000
    repeat 800000 