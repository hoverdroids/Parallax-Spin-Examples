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
{{
       ====================<< MY LED >>====================
       LED's are connected to the output of a 74HC595N serial to
       Parallel shift register and the propeller controls the shift
       and enable inputs to the 74HC595 directly. Thus three Propeller
       I/O pins control 8 (or more) output pins. By cascading  more
       74HC595 chips 8 additional I/O Pins are added for each 74HC595.

                Shift Register Board Physical Layout
                ┌───────────────────────────────────┐           
                │  J1    J2   J3     J4   ┌───────┐ │                                 
                │  •--nc-•  -• Data •-  │74HC595│ │
                │  •-Gnd-•    •-Clk--•    └───────┘ │    Note Gnd & +5 is reversed                             
                │  •-+5--•    •-Ena--•              │    from std 3 pin servo cable                            
                │                                   │    My mistake, sorry                             
                │  L8  L7  L6  L5  L4  L3  L2  L1   │                                 
                └───────────────────────────────────┘
             

   VCC +5   ───────────────────────────────┳───────────┳─────────────────────── VCC +5
      Gnd   ───────────────────────────────┼──┳─────┳──┼─────────────────────── Gnd
      Ena   ─────────────────────┳─────┼──┼─────┼──┼─────────────────── Ena
      Clk   ──────────────────┳──┼─────┼──┼─────┼──┼─────────────────── Clk
      Din   ───────────────┐  │  │     │  │     │  │     ┌───────────── Dout                                 
               J3        ┌─────┴──┴──┴─────┴──┴─────┴──┴─────┴───┐        J4
                         │     14 11 12    10  13    8 16    9   │         
                         │                                       │          
                         │               74HC595N                │         
                         │           Serial to Parallel          │           
                         │              Shift Register           │         
                         │                                       │          
                         │    15  1   2   3   4   5   6   7      │  
                         └────┬───┬───┬───┬───┬───┬───┬───┬──────┘
                              │   │   │   │   │   │   │   └┐
                              │   │   │   │   │   │   └┐    
                              │   │   │   │   │   └┐   
                              │   │   │   │   └┐   
                              │   │   │   └┐   
                              │   │   └┐   
                              │   └┐   
                              └┐   
                                   
                                                                                                                    
}}
CON
  _CLKMODE      = XTAL1 + PLL16X
  _XINFREQ      = 5_000_000

'===============< Precalculated Delay Times >=================
  Clock         = 80_000_000            '5Mhz Crystal
  us10          = Clock / 100_000
  us5           = Clock / 200_000
  us1           = Clock / 1_000_000
  Delay         = us5

'===========< Led board assignments >=================
  DataPin       = 5          ' Shift Register Data   --> White
  ClkPin        = 6          ' Shift Register Clock  --> Red
  EnaPin        = 7          ' Shift Register Enable --> Black
  #0,Left,Right              ' LSB position
  #0,Led0,Led1,Led2,Led3,Led4,Led5,Led6,Led7
  #0,DRed,DBlue,Blue,Green,Yellow,Red,White,Purple          ' Dark Red attached to D7
 
Var
  Long Dpin,Cpin,Epin

PUB Init(_DataPin)
   Dpin := _DataPin
   Cpin := _DataPin + 1
   Epin := _DataPin + 2
   dira |= |<DPin + |<EPin + |<CPin    ' Setup Led output pins
   return
                
Pub ShowByte(Data, Width, LSB)
        case LSB                             
           Left : LShiftout(Data, Width)   ' LSB on the left
           Right: RShiftout(Data, Width)   ' LSB on the right

Pri LShiftout(Data, NBits)
'Left Shift data, MSB first                 ' This puts the LSB on the Left  
'SrEna  
'SrData   10110010
'SrClk  
    Data <-= (32-NBits)                      ' Align for Size bits
    outa[Cpin]~                              ' Force clock low
    outa[Epin]~                              ' Disable output while changing
    repeat NBits                             ' Number of bits MSB first
      outa[Dpin] := (Data <-= 1) & 1         ' Rotate to bit one and output
      waitcnt(Delay+cnt)                     ' Wait 5us to allow data line to settle  
      outa[Cpin]~~                           ' Clock the bit - High-Low
      waitcnt(Delay+cnt)
      outa[Cpin]~
      waitcnt(Delay+cnt)
    outa[Epin]~~                             ' Enable Output register

Pri RShiftout(Data, NBits)                  ' This puts the LSB on the Right
'Right shift data LSB first
'SrEna  
'SrData   10110010
'SrClk  
    outa[Cpin]~                             ' Force clock low
    outa[Epin]~                             ' Disable output while changing
    repeat NBits                            ' Number of bits LSB first
      outa[Dpin] := Data & 1                ' Output the data bit
      waitcnt(Delay+cnt)                    ' Wait 5us to allow data line to settle
      outa[Cpin]~~                          ' Clock the bit - High-Low
      waitcnt(Delay+cnt)
      outa[Cpin]~
      waitcnt(Delay+cnt)
      Data ->= 1                            ' Rotate next bit into position
    outa[Epin]~~                            ' Enable Output register

