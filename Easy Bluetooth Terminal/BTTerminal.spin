{ BTTerminal.spin
        Steve Nicholson <mac@steveandmimi.com>
        This program is free for any use

        A quick demo program to test out Bluetooth communication with the Parallax
        Easy Bluetooth module

        Pin configurations for the tv_terminal and keyboard objects are the default
        Propeller Demo Board pins.

        P0 is connected to Tx on the EasyBT
        P1 is connected to Rx on the EasyBT

        Use a terminal emulator through a Bluetooth serial port on your computer
        to send and receive characters. Info for setting up an EasyBT serial port
        on OS X is at http://www.steveandmimi.com/easybt/

        Version 1.0, 2009-04-11. Quick-and-dirty version.
}

CON

        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000


OBJ

        term    : "tv_terminal"
        kb      : "keyboard"
        serial  : "FullDuplexSerial"

VAR

  byte  btbyte

PUB start | i

  'start the serial object
  serial.start(0, 1, 0, 9600)

  'start the tv terminal
  term.start(12)
  term.str(string("Bluetooth Terminal",13))

  'start the keyboard
  kb.start(26, 27)

  repeat
    if kb.gotkey
      serial.tx(kb.getkey)
    btbyte := serial.rxcheck
    if btbyte => 0
      term.out(btbyte)

 