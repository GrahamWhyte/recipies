; C:\M68KV6.0 - 640BY480\M68KV6.0 - 800BY480 - (VERILOG) FOR STUDENTS\PROGRAMS\LAB5\IIC_DRIVER.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J. Fondse
; #include <stdlib.h>
; #include "IIC_Driver.h"
; /* Globals */
; volatile unsigned char *IICClkPrescalerLow = (unsigned char *)IIC_CLK_PRSCL_LO;
; volatile unsigned char *IICClkPrescalerHigh = (unsigned char *)IIC_CLK_PRSCL_HI;
; volatile unsigned char *IICControl = (unsigned char *)IIC_CONTROL;
; volatile unsigned char *IICTx = (unsigned char *)IIC_TRANSMIT;
; volatile unsigned char *IICRx = (unsigned char *)IIC_RECEIVE;
; volatile unsigned char *IICStatus = (unsigned char *)IIC_STATUS;
; volatile unsigned char *IICCommand = (unsigned char *)IIC_COMMAND;
; /* Functions */
; void WaitForEndOfTransfer(void) {
       section   code
       xdef      _WaitForEndOfTransfer
_WaitForEndOfTransfer:
; while (1){							
WaitForEndOfTransfer_1:
; if ( ( (*IICStatus) & TIP) == 0)	
       move.l    _IICStatus.L,A0
       move.b    (A0),D0
       and.b     #2,D0
       bne.s     WaitForEndOfTransfer_4
; break;							
       bra.s     WaitForEndOfTransfer_3
WaitForEndOfTransfer_4:
       bra       WaitForEndOfTransfer_1
WaitForEndOfTransfer_3:
       rts
; }			
; }
; void WaitForAck(void) {
       xdef      _WaitForAck
_WaitForAck:
; while (1){								
WaitForAck_1:
; if ( ( (*IICStatus) & RxACK) == 0 )	
       move.l    _IICStatus.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       and.w     #128,D0
       bne.s     WaitForAck_4
; break;							
       bra.s     WaitForAck_3
WaitForAck_4:
       bra       WaitForAck_1
WaitForAck_3:
       rts
; }				
; }	
; unsigned char EEPROMInternalWritting(void) {
       xdef      _EEPROMInternalWritting
_EEPROMInternalWritting:
; return ( ( (*IICStatus) & RxACK) == 0 );
       move.l    _IICStatus.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       and.w     #128,D0
       bne.s     EEPROMInternalWritting_1
       moveq     #1,D0
       bra.s     EEPROMInternalWritting_2
EEPROMInternalWritting_1:
       clr.l     D0
EEPROMInternalWritting_2:
       rts
; }
; void Init_IIC(void) {
       xdef      _Init_IIC
_Init_IIC:
; *IICControl = 0;
       move.l    _IICControl.L,A0
       clr.b     (A0)
; *IICClkPrescalerLow = CLK_100K_LO;
       move.l    _IICClkPrescalerLow.L,A0
       move.b    #49,(A0)
; *IICClkPrescalerHigh = CLK_100K_HI;
       move.l    _IICClkPrescalerHigh.L,A0
       clr.b     (A0)
; *IICControl = CORE_ENABLED | INTERRUPT_DISABLED;
       move.l    _IICControl.L,A0
       move.b    #128,(A0)
       rts
; } 
; void WriteByte(unsigned char IICSlaveAddress, unsigned char byteToStore, unsigned int EEPROMAddress) {
       xdef      _WriteByte
_WriteByte:
       link      A6,#-4
       movem.l   D2/A2/A3/A4/A5,-(A7)
       lea       _WaitForAck.L,A2
       lea       _WaitForEndOfTransfer.L,A3
       lea       _IICCommand.L,A4
       lea       _IICTx.L,A5
       move.l    16(A6),D2
; unsigned char blockSelect = (unsigned char)EEPROMAddress>>16; 
       move.l    D2,D0
       lsr.b     #8,D0
       lsr.b     #8,D0
       move.b    D0,-3(A6)
; unsigned char EEPROMAddress_High = (unsigned char)(EEPROMAddress>>8); 
       move.l    D2,D0
       lsr.l     #8,D0
       move.b    D0,-2(A6)
; unsigned char EEPROMAddress_Low = (unsigned char)EEPROMAddress; 
       move.b    D2,-1(A6)
; IICSlaveAddress |= (blockSelect << 3);  
       move.b    -3(A6),D0
       lsl.b     #3,D0
       or.b      D0,11(A6)
; // Transfer IIC Slave Address
; WaitForInternalWrite(IICSlaveAddress);
       move.b    11(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _WaitForInternalWrite
       addq.w    #4,A7
; // Transfer High EEProm Address
; *IICTx = EEPROMAddress_High;	// fill the tx shift register
       move.l    (A5),A0
       move.b    -2(A6),(A0)
; *IICCommand = WR;	// set write bit
       move.l    (A4),A0
       move.b    #16,(A0)
; WaitForEndOfTransfer();
       jsr       (A3)
; WaitForAck();
       jsr       (A2)
; // Transfer Low EEProm Address
; *IICTx = EEPROMAddress_Low;	// fill the tx shift register
       move.l    (A5),A0
       move.b    -1(A6),(A0)
; *IICCommand = WR;	// set write bit
       move.l    (A4),A0
       move.b    #16,(A0)
; WaitForEndOfTransfer();
       jsr       (A3)
; WaitForAck();
       jsr       (A2)
; // Send Data
; *IICTx = byteToStore;
       move.l    (A5),A0
       move.b    15(A6),(A0)
; *IICCommand = WR | STO;	//send stop signal
       move.l    (A4),A0
       move.b    #80,(A0)
; WaitForEndOfTransfer();
       jsr       (A3)
; WaitForAck();
       jsr       (A2)
       movem.l   (A7)+,D2/A2/A3/A4/A5
       unlk      A6
       rts
; }
; unsigned char ReadByte(unsigned char IICSlaveAddress, unsigned int EEPROMAddress) {
       xdef      _ReadByte
_ReadByte:
       link      A6,#-4
       movem.l   D2/D3/A2/A3/A4/A5,-(A7)
       lea       _WaitForEndOfTransfer.L,A2
       lea       _IICCommand.L,A3
       lea       _WaitForAck.L,A4
       lea       _IICTx.L,A5
       move.b    11(A6),D2
       and.l     #255,D2
       move.l    12(A6),D3
; unsigned char blockSelect = (unsigned char)EEPROMAddress>>16; 
       move.l    D3,D0
       lsr.b     #8,D0
       lsr.b     #8,D0
       move.b    D0,-3(A6)
; unsigned char EEPROMAddress_High = (unsigned char)(EEPROMAddress>>8); 
       move.l    D3,D0
       lsr.l     #8,D0
       move.b    D0,-2(A6)
; unsigned char EEPROMAddress_Low = (unsigned char)EEPROMAddress; 
       move.b    D3,-1(A6)
; IICSlaveAddress |= (blockSelect << 3);  
       move.b    -3(A6),D0
       lsl.b     #3,D0
       or.b      D0,D2
; // Transfer IIC Slave Address
; WaitForInternalWrite(IICSlaveAddress);
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _WaitForInternalWrite
       addq.w    #4,A7
; // Transfer High EEProm Address
; *IICTx = EEPROMAddress_High;	// fill the tx shift register
       move.l    (A5),A0
       move.b    -2(A6),(A0)
; *IICCommand = WR;	// set write bit
       move.l    (A3),A0
       move.b    #16,(A0)
; WaitForEndOfTransfer();
       jsr       (A2)
; WaitForAck();
       jsr       (A4)
; // Transfer Low EEProm Address
; *IICTx = EEPROMAddress_Low;	// fill the tx shift register
       move.l    (A5),A0
       move.b    -1(A6),(A0)
; *IICCommand = WR;	// set write bit
       move.l    (A3),A0
       move.b    #16,(A0)
; WaitForEndOfTransfer();
       jsr       (A2)
; WaitForAck();
       jsr       (A4)
; // Fetch Data
; *IICTx = IICSlaveAddress | READ;
       move.b    D2,D0
       or.b      #1,D0
       move.l    (A5),A0
       move.b    D0,(A0)
; *IICCommand = WR | STA;	//send stop signal
       move.l    (A3),A0
       move.b    #144,(A0)
; WaitForEndOfTransfer();
       jsr       (A2)
; WaitForAck();
       jsr       (A4)
; // read SDA line
; *IICCommand = RD | STO | NACK;	//send stop signal
       move.l    (A3),A0
       move.b    #104,(A0)
; WaitForEndOfTransfer();
       jsr       (A2)
; return *IICRx;
       move.l    _IICRx.L,A0
       move.b    (A0),D0
       movem.l   (A7)+,D2/D3/A2/A3/A4/A5
       unlk      A6
       rts
; }
; void WaitForInternalWrite(unsigned char IICSlaveAddress) {
       xdef      _WaitForInternalWrite
_WaitForInternalWrite:
       link      A6,#0
; do {
WaitForInternalWrite_1:
; *IICTx = IICSlaveAddress | WRITE;	// fill the tx shift register
       move.b    11(A6),D0
       or.b      #0,D0
       move.l    _IICTx.L,A0
       move.b    D0,(A0)
; *IICCommand = STA | WR;	// set write bit
       move.l    _IICCommand.L,A0
       move.b    #144,(A0)
; printf("\r\nChecking if internal write is done...");
       pea       @iic_dr~1_1.L
       jsr       _printf
       addq.w    #4,A7
; printf("\r\nStatus REg: %x", *IICStatus);
       move.l    _IICStatus.L,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @iic_dr~1_2.L
       jsr       _printf
       addq.w    #8,A7
; WaitForEndOfTransfer();
       jsr       _WaitForEndOfTransfer
       jsr       _EEPROMInternalWritting
       tst.b     D0
       beq       WaitForInternalWrite_1
       unlk      A6
       rts
; } while (!EEPROMInternalWritting());
; }
       section   const
@iic_dr~1_1:
       dc.b      13,10,67,104,101,99,107,105,110,103,32,105,102
       dc.b      32,105,110,116,101,114,110,97,108,32,119,114
       dc.b      105,116,101,32,105,115,32,100,111,110,101,46
       dc.b      46,46,0
@iic_dr~1_2:
       dc.b      13,10,83,116,97,116,117,115,32,82,69,103,58
       dc.b      32,37,120,0
       section   data
       xdef      _IICClkPrescalerLow
_IICClkPrescalerLow:
       dc.l      4227072
       xdef      _IICClkPrescalerHigh
_IICClkPrescalerHigh:
       dc.l      4227074
       xdef      _IICControl
_IICControl:
       dc.l      4227076
       xdef      _IICTx
_IICTx:
       dc.l      4227078
       xdef      _IICRx
_IICRx:
       dc.l      4227078
       xdef      _IICStatus
_IICStatus:
       dc.l      4227080
       xdef      _IICCommand
_IICCommand:
       dc.l      4227080
       xref      _printf
