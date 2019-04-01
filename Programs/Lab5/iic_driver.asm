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
; // *IICClkPrescalerLow = (unsigned char *)IIC_CLK_PRSCL_LO;
; // *IICClkPrescalerHigh = (unsigned char *)IIC_CLK_PRSCL_HI;
; // *IICControl = (unsigned char *)IIC_CONTROL;
; // *IICTx = (unsigned char *)IIC_TRANSMIT;
; // *IICRx = (unsigned char *)IIC_RECEIVE;
; // *IICStatus = (unsigned char *)IIC_STATUS;
; // *IICCommand = (unsigned char *)IIC_COMMAND;
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
; WaitForEndOfTransfer();
       jsr       _WaitForEndOfTransfer
       jsr       _EEPROMInternalWritting
       tst.b     D0
       beq       WaitForInternalWrite_1
       unlk      A6
       rts
; } while (!EEPROMInternalWritting());
; }
; void Write_128_Bytes(unsigned char IICSlaveAddress, unsigned int EEPROMAddress, unsigned char *iicArray) {
       xdef      _Write_128_Bytes
_Write_128_Bytes:
       link      A6,#-4
       movem.l   D2/D3/A2/A3/A4/A5,-(A7)
       lea       _WaitForAck.L,A2
       lea       _WaitForEndOfTransfer.L,A3
       lea       _IICCommand.L,A4
       lea       _IICTx.L,A5
       move.l    12(A6),D3
; int i; 
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
; for (i=0; i<127; i++)
       clr.l     D2
Write_128_Bytes_1:
       cmp.l     #127,D2
       bge.s     Write_128_Bytes_3
; {
; *IICTx = iicArray[i];
       move.l    16(A6),A0
       move.l    (A5),A1
       move.b    0(A0,D2.L),(A1)
; *IICCommand = WR;	// set write bit
       move.l    (A4),A0
       move.b    #16,(A0)
; WaitForEndOfTransfer();
       jsr       (A3)
; WaitForAck();
       jsr       (A2)
       addq.l    #1,D2
       bra       Write_128_Bytes_1
Write_128_Bytes_3:
; }
; // Send Data
; *IICTx = iicArray[127];
       move.l    16(A6),A0
       move.l    (A5),A1
       move.b    127(A0),(A1)
; *IICCommand = WR | STO;	//send stop signal
       move.l    (A4),A0
       move.b    #80,(A0)
; WaitForEndOfTransfer();
       jsr       (A3)
; WaitForAck();
       jsr       (A2)
       movem.l   (A7)+,D2/D3/A2/A3/A4/A5
       unlk      A6
       rts
; }
; void Read_128_Bytes(unsigned char IICSlaveAddress, unsigned int EEPROMAddress, unsigned char *buffer){
       xdef      _Read_128_Bytes
_Read_128_Bytes:
       link      A6,#-4
       movem.l   D2/D3/D4/A2/A3/A4/A5,-(A7)
       lea       _WaitForEndOfTransfer.L,A2
       lea       _IICCommand.L,A3
       lea       _WaitForAck.L,A4
       lea       _IICTx.L,A5
       move.b    11(A6),D3
       and.l     #255,D3
       move.l    12(A6),D4
; int i; 
; unsigned char blockSelect = (unsigned char)EEPROMAddress>>16; 
       move.l    D4,D0
       lsr.b     #8,D0
       lsr.b     #8,D0
       move.b    D0,-3(A6)
; unsigned char EEPROMAddress_High = (unsigned char)(EEPROMAddress>>8); 
       move.l    D4,D0
       lsr.l     #8,D0
       move.b    D0,-2(A6)
; unsigned char EEPROMAddress_Low = (unsigned char)EEPROMAddress; 
       move.b    D4,-1(A6)
; IICSlaveAddress |= (blockSelect << 3);  
       move.b    -3(A6),D0
       lsl.b     #3,D0
       or.b      D0,D3
; // Transfer IIC Slave Address
; WaitForInternalWrite(IICSlaveAddress);
       and.l     #255,D3
       move.l    D3,-(A7)
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
       move.b    D3,D0
       or.b      #1,D0
       move.l    (A5),A0
       move.b    D0,(A0)
; *IICCommand = WR | STA;	//send start signal
       move.l    (A3),A0
       move.b    #144,(A0)
; WaitForEndOfTransfer();
       jsr       (A2)
; WaitForAck();
       jsr       (A4)
; for (i=0; i<127; i++)
       clr.l     D2
Read_128_Bytes_1:
       cmp.l     #127,D2
       bge.s     Read_128_Bytes_3
; {
; *IICCommand = RD;
       move.l    (A3),A0
       move.b    #32,(A0)
; WaitForEndOfTransfer();
       jsr       (A2)
; buffer[i] = *IICRx; 
       move.l    _IICRx.L,A0
       move.l    16(A6),A1
       move.b    (A0),0(A1,D2.L)
       addq.l    #1,D2
       bra       Read_128_Bytes_1
Read_128_Bytes_3:
; }
; // read SDA line
; *IICCommand = RD | STO | NACK;	//send stop signal
       move.l    (A3),A0
       move.b    #104,(A0)
; WaitForEndOfTransfer();
       jsr       (A2)
; buffer[127] = *IICRx; 
       move.l    _IICRx.L,A0
       move.l    16(A6),A1
       move.b    (A0),127(A1)
       movem.l   (A7)+,D2/D3/D4/A2/A3/A4/A5
       unlk      A6
       rts
; }
; void WriteBytes(unsigned char IICSlaveAddress, unsigned int EEPROMAddress, unsigned char *iicArray, unsigned int length){
       xdef      _WriteBytes
_WriteBytes:
       link      A6,#-12
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       move.l    12(A6),D4
       lea       _IICCommand.L,A2
       lea       _WaitForAck.L,A3
       lea       _WaitForEndOfTransfer.L,A4
       lea       _IICTx.L,A5
       move.l    16(A6),D6
       move.b    11(A6),D7
       and.l     #255,D7
; int i; 
; unsigned char blockSelect = (unsigned char)EEPROMAddress>>16; 
       move.l    D4,D0
       lsr.b     #8,D0
       lsr.b     #8,D0
       move.b    D0,-11(A6)
; unsigned char EEPROMAddress_High = (unsigned char)(EEPROMAddress>>8); 
       move.l    D4,D0
       lsr.l     #8,D0
       move.b    D0,-10(A6)
; unsigned char EEPROMAddress_Low = (unsigned char)EEPROMAddress; 
       move.b    D4,-9(A6)
; unsigned int bytesToWrite; 
; unsigned char lengthFlag = 0; 
       clr.b     -3(A6)
; int lengthCopy = (int)length;  
       move.l    20(A6),D5
; unsigned int CurrentAddress = EEPROMAddress; 
       move.l    D4,D2
; unsigned char CurrentAddress_High;
; unsigned char CurrentAddress_Low; 
; IICSlaveAddress |= (blockSelect << 3);  
       move.b    -11(A6),D0
       lsl.b     #3,D0
       or.b      D0,D7
; // Transfer IIC Slave Address
; WaitForInternalWrite(IICSlaveAddress);
       and.l     #255,D7
       move.l    D7,-(A7)
       jsr       _WaitForInternalWrite
       addq.w    #4,A7
; // Transfer High EEProm Address
; *IICTx = EEPROMAddress_High;	// fill the tx shift register
       move.l    (A5),A0
       move.b    -10(A6),(A0)
; *IICCommand = WR;	// set write bit
       move.l    (A2),A0
       move.b    #16,(A0)
; WaitForEndOfTransfer();
       jsr       (A4)
; WaitForAck();
       jsr       (A3)
; // Transfer Low EEProm Address
; *IICTx = EEPROMAddress_Low;	// fill the tx shift register
       move.l    (A5),A0
       move.b    -9(A6),(A0)
; *IICCommand = WR;	// set write bit
       move.l    (A2),A0
       move.b    #16,(A0)
; WaitForEndOfTransfer();
       jsr       (A4)
; WaitForAck();
       jsr       (A3)
; // Check difference between starting address and next block 
; bytesToWrite = 128-EEPROMAddress%128; 
       move.w    #128,D0
       ext.l     D0
       move.l    D4,-(A7)
       pea       128
       jsr       ULDIV
       move.l    4(A7),D1
       addq.w    #8,A7
       sub.l     D1,D0
       move.l    D0,-8(A6)
; // First block 
; for (i=0; i<bytesToWrite; i++)
       clr.l     D3
WriteBytes_1:
       cmp.l     -8(A6),D3
       bhs       WriteBytes_3
; {
; printf("\r\nEntered First Block Loop"); 
       pea       @iic_dr~1_1.L
       jsr       _printf
       addq.w    #4,A7
; *IICTx = iicArray[i];
       move.l    D6,A0
       move.l    (A5),A1
       move.b    0(A0,D3.L),(A1)
; if ( (i+1 >= length) || (i==(bytesToWrite-1)))
       move.l    D3,D0
       addq.l    #1,D0
       cmp.l     20(A6),D0
       bhs.s     WriteBytes_6
       move.l    -8(A6),D0
       subq.l    #1,D0
       cmp.l     D0,D3
       bne.s     WriteBytes_4
WriteBytes_6:
; {
; if (i+1 >= length)
       move.l    D3,D0
       addq.l    #1,D0
       cmp.l     20(A6),D0
       blo.s     WriteBytes_7
; lengthFlag = 1;
       move.b    #1,-3(A6)
WriteBytes_7:
; *IICCommand = WR | STO;	//send stop signal 
       move.l    (A2),A0
       move.b    #80,(A0)
       bra.s     WriteBytes_5
WriteBytes_4:
; }
; else
; {
; *IICCommand = WR;	// set write bit
       move.l    (A2),A0
       move.b    #16,(A0)
WriteBytes_5:
; }
; WaitForEndOfTransfer();
       jsr       (A4)
; WaitForAck();
       jsr       (A3)
; lengthCopy--; 
       subq.l    #1,D5
; CurrentAddress++; 
       addq.l    #1,D2
; if (lengthFlag)
       tst.b     -3(A6)
       beq.s     WriteBytes_9
; {
; break; 
       bra.s     WriteBytes_3
WriteBytes_9:
       addq.l    #1,D3
       bra       WriteBytes_1
WriteBytes_3:
; }
; }
; // Other blocks
; if (!lengthFlag)
       tst.b     -3(A6)
       bne       WriteBytes_16
; {
; // Complete blocks
; while (lengthCopy >= 128)
WriteBytes_13:
       cmp.l     #128,D5
       blt       WriteBytes_15
; {
; printf("\r\n Entered Intermediate Loop"); 
       pea       @iic_dr~1_2.L
       jsr       _printf
       addq.w    #4,A7
; printf("\r\n Current Address Index: %x", CurrentAddress-EEPROMAddress); 
       move.l    D2,D1
       sub.l     D4,D1
       move.l    D1,-(A7)
       pea       @iic_dr~1_3.L
       jsr       _printf
       addq.w    #8,A7
; Write_128_Bytes(0xA6, CurrentAddress, &(iicArray[CurrentAddress-EEPROMAddress])); 
       move.l    D6,D1
       move.l    D0,-(A7)
       move.l    D2,D0
       sub.l     D4,D0
       add.l     D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       move.l    D2,-(A7)
       pea       166
       jsr       _Write_128_Bytes
       add.w     #12,A7
; CurrentAddress+=128; 
       add.l     #128,D2
; lengthCopy-=128; 
       sub.l     #128,D5
       bra       WriteBytes_13
WriteBytes_15:
; }
; if (lengthCopy>0)
       cmp.l     #0,D5
       ble       WriteBytes_16
; {
; // Prepare for write to final block
; blockSelect = (unsigned char)CurrentAddress>>16; 
       move.l    D2,D0
       lsr.b     #8,D0
       lsr.b     #8,D0
       move.b    D0,-11(A6)
; CurrentAddress_High = (unsigned char)(CurrentAddress>>8);
       move.l    D2,D0
       lsr.l     #8,D0
       move.b    D0,-2(A6)
; CurrentAddress_Low = (unsigned char)(CurrentAddress);
       move.b    D2,-1(A6)
; IICSlaveAddress |= (blockSelect << 3);  
       move.b    -11(A6),D0
       lsl.b     #3,D0
       or.b      D0,D7
; // Transfer IIC Slave Address
; WaitForInternalWrite(IICSlaveAddress);
       and.l     #255,D7
       move.l    D7,-(A7)
       jsr       _WaitForInternalWrite
       addq.w    #4,A7
; // Transfer High EEProm Address
; *IICTx = CurrentAddress_High;	// fill the tx shift register
       move.l    (A5),A0
       move.b    -2(A6),(A0)
; *IICCommand = WR;	// set write bit
       move.l    (A2),A0
       move.b    #16,(A0)
; WaitForEndOfTransfer();
       jsr       (A4)
; WaitForAck();
       jsr       (A3)
; // Transfer Low EEProm Address
; *IICTx = CurrentAddress_Low;	// fill the tx shift register
       move.l    (A5),A0
       move.b    -1(A6),(A0)
; *IICCommand = WR;	// set write bit
       move.l    (A2),A0
       move.b    #16,(A0)
; WaitForEndOfTransfer();
       jsr       (A4)
; WaitForAck();
       jsr       (A3)
; // Last block
; for (i=0; i<lengthCopy-1; i++)
       clr.l     D3
WriteBytes_18:
       move.l    D5,D0
       subq.l    #1,D0
       cmp.l     D0,D3
       bge       WriteBytes_20
; {
; printf("\r\n Entered Last Block Loop"); 
       pea       @iic_dr~1_4.L
       jsr       _printf
       addq.w    #4,A7
; printf("\r\n Current Address Index: %x", CurrentAddress-EEPROMAddress); 
       move.l    D2,D1
       sub.l     D4,D1
       move.l    D1,-(A7)
       pea       @iic_dr~1_3.L
       jsr       _printf
       addq.w    #8,A7
; *IICTx = iicArray[CurrentAddress-EEPROMAddress];
       move.l    D6,A0
       move.l    D2,D0
       sub.l     D4,D0
       move.l    (A5),A1
       move.b    0(A0,D0.L),(A1)
; *IICCommand = WR;	// set write bit
       move.l    (A2),A0
       move.b    #16,(A0)
; WaitForEndOfTransfer();
       jsr       (A4)
; WaitForAck();
       jsr       (A3)
; CurrentAddress+=1; 
       addq.l    #1,D2
       addq.l    #1,D3
       bra       WriteBytes_18
WriteBytes_20:
; }
; // Final byte
; *IICTx = iicArray[CurrentAddress-EEPROMAddress];
       move.l    D6,A0
       move.l    D2,D0
       sub.l     D4,D0
       move.l    (A5),A1
       move.b    0(A0,D0.L),(A1)
; *IICCommand = WR | STO;	// set write bit
       move.l    (A2),A0
       move.b    #80,(A0)
; WaitForEndOfTransfer();
       jsr       (A4)
; WaitForAck();
       jsr       (A3)
WriteBytes_16:
; }
; }
; printf("\r\n Exited All Loops"); 
       pea       @iic_dr~1_5.L
       jsr       _printf
       addq.w    #4,A7
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; void ReadBytes(unsigned char IICSlaveAddress, unsigned int EEPROMAddress, unsigned char *buffer, unsigned int length){
       xdef      _ReadBytes
_ReadBytes:
       link      A6,#-12
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _IICCommand.L,A2
       move.l    12(A6),D4
       lea       _WaitForEndOfTransfer.L,A3
       lea       _printf.L,A4
       lea       _WaitForAck.L,A5
       move.b    11(A6),D5
       and.l     #255,D5
       move.l    16(A6),D7
; int i; 
; unsigned char blockSelect = (unsigned char)EEPROMAddress>>16; 
       move.l    D4,D0
       lsr.b     #8,D0
       lsr.b     #8,D0
       move.b    D0,-11(A6)
; unsigned char EEPROMAddress_High = (unsigned char)(EEPROMAddress>>8); 
       move.l    D4,D0
       lsr.l     #8,D0
       move.b    D0,-10(A6)
; unsigned char EEPROMAddress_Low = (unsigned char)EEPROMAddress; 
       move.b    D4,-9(A6)
; unsigned int bytesToRead; 
; unsigned char lengthFlag = 0; 
       clr.b     -3(A6)
; int lengthCopy = (int)length;  
       move.l    20(A6),D6
; unsigned int CurrentAddress = EEPROMAddress; 
       move.l    D4,D2
; unsigned char CurrentAddress_High;
; unsigned char CurrentAddress_Low; 
; IICSlaveAddress |= (blockSelect << 3);  
       move.b    -11(A6),D0
       lsl.b     #3,D0
       or.b      D0,D5
; // Transfer IIC Slave Address
; WaitForInternalWrite(IICSlaveAddress);
       and.l     #255,D5
       move.l    D5,-(A7)
       jsr       _WaitForInternalWrite
       addq.w    #4,A7
; // Transfer High EEProm Address
; *IICTx = EEPROMAddress_High;	// fill the tx shift register
       move.l    _IICTx.L,A0
       move.b    -10(A6),(A0)
; *IICCommand = WR;	// set write bit
       move.l    (A2),A0
       move.b    #16,(A0)
; WaitForEndOfTransfer();
       jsr       (A3)
; WaitForAck();
       jsr       (A5)
; // Transfer Low EEProm Address
; *IICTx = EEPROMAddress_Low;	// fill the tx shift register
       move.l    _IICTx.L,A0
       move.b    -9(A6),(A0)
; *IICCommand = WR;	// set write bit
       move.l    (A2),A0
       move.b    #16,(A0)
; WaitForEndOfTransfer();
       jsr       (A3)
; WaitForAck();
       jsr       (A5)
; // Fetch Data
; *IICTx = IICSlaveAddress | READ;
       move.b    D5,D0
       or.b      #1,D0
       move.l    _IICTx.L,A0
       move.b    D0,(A0)
; *IICCommand = WR | STA;	//send start signal
       move.l    (A2),A0
       move.b    #144,(A0)
; WaitForEndOfTransfer();
       jsr       (A3)
; WaitForAck();
       jsr       (A5)
; // Check difference between starting address and next block 
; bytesToRead = 128-EEPROMAddress%128; 
       move.w    #128,D0
       ext.l     D0
       move.l    D4,-(A7)
       pea       128
       jsr       ULDIV
       move.l    4(A7),D1
       addq.w    #8,A7
       sub.l     D1,D0
       move.l    D0,-8(A6)
; // First block 
; for (i=0; i<bytesToRead; i++)
       clr.l     D3
ReadBytes_1:
       cmp.l     -8(A6),D3
       bhs       ReadBytes_3
; {
; printf("\r\nEntered First Block Loop"); 
       pea       @iic_dr~1_1.L
       jsr       (A4)
       addq.w    #4,A7
; if ( (i+1 >= length) || (i==(bytesToRead-1)))
       move.l    D3,D0
       addq.l    #1,D0
       cmp.l     20(A6),D0
       bhs.s     ReadBytes_6
       move.l    -8(A6),D0
       subq.l    #1,D0
       cmp.l     D0,D3
       bne.s     ReadBytes_4
ReadBytes_6:
; {
; if (i+1 >= length)
       move.l    D3,D0
       addq.l    #1,D0
       cmp.l     20(A6),D0
       blo.s     ReadBytes_7
; lengthFlag = 1;
       move.b    #1,-3(A6)
ReadBytes_7:
; *IICCommand = RD | STO | NACK;	//send stop signal 
       move.l    (A2),A0
       move.b    #104,(A0)
       bra.s     ReadBytes_5
ReadBytes_4:
; }
; else
; {
; *IICCommand = RD;	// set write bit
       move.l    (A2),A0
       move.b    #32,(A0)
ReadBytes_5:
; }
; WaitForEndOfTransfer();
       jsr       (A3)
; buffer[i] = *IICRx; 
       move.l    _IICRx.L,A0
       move.l    D7,A1
       move.b    (A0),0(A1,D3.L)
; lengthCopy--; 
       subq.l    #1,D6
; CurrentAddress++; 
       addq.l    #1,D2
; if (lengthFlag)
       tst.b     -3(A6)
       beq.s     ReadBytes_9
; {
; break; 
       bra.s     ReadBytes_3
ReadBytes_9:
       addq.l    #1,D3
       bra       ReadBytes_1
ReadBytes_3:
; }
; }
; // Other blocks
; if (!lengthFlag)
       tst.b     -3(A6)
       bne       ReadBytes_16
; {
; // Complete blocks
; while (lengthCopy >= 128)
ReadBytes_13:
       cmp.l     #128,D6
       blt       ReadBytes_15
; {
; printf("\r\n Entered Intermediate Loop"); 
       pea       @iic_dr~1_2.L
       jsr       (A4)
       addq.w    #4,A7
; printf("\r\n Current Address Index: %x", CurrentAddress-EEPROMAddress); 
       move.l    D2,D1
       sub.l     D4,D1
       move.l    D1,-(A7)
       pea       @iic_dr~1_3.L
       jsr       (A4)
       addq.w    #8,A7
; Read_128_Bytes(0xA6, CurrentAddress, &(buffer[CurrentAddress-EEPROMAddress])); 
       move.l    D7,D1
       move.l    D0,-(A7)
       move.l    D2,D0
       sub.l     D4,D0
       add.l     D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       move.l    D2,-(A7)
       pea       166
       jsr       _Read_128_Bytes
       add.w     #12,A7
; CurrentAddress+=128; 
       add.l     #128,D2
; lengthCopy-=128; 
       sub.l     #128,D6
       bra       ReadBytes_13
ReadBytes_15:
; }
; if (lengthCopy>0)
       cmp.l     #0,D6
       ble       ReadBytes_16
; {
; // Prepare for write to final block
; blockSelect = (unsigned char)CurrentAddress>>16; 
       move.l    D2,D0
       lsr.b     #8,D0
       lsr.b     #8,D0
       move.b    D0,-11(A6)
; CurrentAddress_High = (unsigned char)(CurrentAddress>>8);
       move.l    D2,D0
       lsr.l     #8,D0
       move.b    D0,-2(A6)
; CurrentAddress_Low = (unsigned char)(CurrentAddress);
       move.b    D2,-1(A6)
; IICSlaveAddress |= (blockSelect << 3);  
       move.b    -11(A6),D0
       lsl.b     #3,D0
       or.b      D0,D5
; // Transfer IIC Slave Address
; WaitForInternalWrite(IICSlaveAddress);
       and.l     #255,D5
       move.l    D5,-(A7)
       jsr       _WaitForInternalWrite
       addq.w    #4,A7
; // Transfer High EEProm Address
; *IICTx = CurrentAddress_High;	// fill the tx shift register
       move.l    _IICTx.L,A0
       move.b    -2(A6),(A0)
; *IICCommand = WR;	// set write bit
       move.l    (A2),A0
       move.b    #16,(A0)
; WaitForEndOfTransfer();
       jsr       (A3)
; WaitForAck();
       jsr       (A5)
; // Transfer Low EEProm Address
; *IICTx = CurrentAddress_Low;	// fill the tx shift register
       move.l    _IICTx.L,A0
       move.b    -1(A6),(A0)
; *IICCommand = WR;	// set write bit
       move.l    (A2),A0
       move.b    #16,(A0)
; WaitForEndOfTransfer();
       jsr       (A3)
; WaitForAck();
       jsr       (A5)
; // Fetch Data
; *IICTx = IICSlaveAddress | READ;
       move.b    D5,D0
       or.b      #1,D0
       move.l    _IICTx.L,A0
       move.b    D0,(A0)
; *IICCommand = WR | STA;	//send start signal
       move.l    (A2),A0
       move.b    #144,(A0)
; WaitForEndOfTransfer();
       jsr       (A3)
; WaitForAck();
       jsr       (A5)
; // Last block
; for (i=0; i<lengthCopy-1; i++)
       clr.l     D3
ReadBytes_18:
       move.l    D6,D0
       subq.l    #1,D0
       cmp.l     D0,D3
       bge       ReadBytes_20
; {
; printf("\r\n Entered Last Block Loop"); 
       pea       @iic_dr~1_4.L
       jsr       (A4)
       addq.w    #4,A7
; printf("\r\n Current Address Index: %x", CurrentAddress-EEPROMAddress); 
       move.l    D2,D1
       sub.l     D4,D1
       move.l    D1,-(A7)
       pea       @iic_dr~1_3.L
       jsr       (A4)
       addq.w    #8,A7
; *IICCommand = RD;	// set read bit
       move.l    (A2),A0
       move.b    #32,(A0)
; WaitForEndOfTransfer();
       jsr       (A3)
; buffer[CurrentAddress-EEPROMAddress] = *IICRx; 
       move.l    _IICRx.L,A0
       move.l    D7,A1
       move.l    D2,D0
       sub.l     D4,D0
       move.b    (A0),0(A1,D0.L)
; CurrentAddress+=1; 
       addq.l    #1,D2
       addq.l    #1,D3
       bra       ReadBytes_18
ReadBytes_20:
; }
; // Final byte
; *IICCommand = RD | STO | NACK;	// set read bit
       move.l    (A2),A0
       move.b    #104,(A0)
; WaitForEndOfTransfer();
       jsr       (A3)
; buffer[CurrentAddress-EEPROMAddress] = *IICRx; 
       move.l    _IICRx.L,A0
       move.l    D7,A1
       move.l    D2,D0
       sub.l     D4,D0
       move.b    (A0),0(A1,D0.L)
ReadBytes_16:
; }
; }
; printf("\r\n Exited All Loops"); 
       pea       @iic_dr~1_5.L
       jsr       (A4)
       addq.w    #4,A7
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
       section   const
@iic_dr~1_1:
       dc.b      13,10,69,110,116,101,114,101,100,32,70,105,114
       dc.b      115,116,32,66,108,111,99,107,32,76,111,111,112
       dc.b      0
@iic_dr~1_2:
       dc.b      13,10,32,69,110,116,101,114,101,100,32,73,110
       dc.b      116,101,114,109,101,100,105,97,116,101,32,76
       dc.b      111,111,112,0
@iic_dr~1_3:
       dc.b      13,10,32,67,117,114,114,101,110,116,32,65,100
       dc.b      100,114,101,115,115,32,73,110,100,101,120,58
       dc.b      32,37,120,0
@iic_dr~1_4:
       dc.b      13,10,32,69,110,116,101,114,101,100,32,76,97
       dc.b      115,116,32,66,108,111,99,107,32,76,111,111,112
       dc.b      0
@iic_dr~1_5:
       dc.b      13,10,32,69,120,105,116,101,100,32,65,108,108
       dc.b      32,76,111,111,112,115,0
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
       xref      ULDIV
       xref      _printf
