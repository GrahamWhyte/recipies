; C:\M68KV6.0 - 640BY480\M68KV6.0 - 800BY480 - (VERILOG) FOR STUDENTS\PROGRAMS\LAB6\CANBUS CONTROLLER ROUTINES - FOR STUDENTS.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J. Fondse
; /*********************************************************************************************
; ** These addresses and definitions were taken from Appendix 7 of the Can Controller
; ** application note and adapted for the 68k assignment
; *********************************************************************************************/
; /*
; ** definition for the SJA1000 registers and bits based on 68k address map areas
; ** assume the addresses for the 2 can controllers given in the assignment
; **
; ** Registers are defined in terms of the following Macro for each Can controller,
; ** where (i) represents an registers number
; */
; #define RS232_Status      *(volatile unsigned char *)(0x00400040)
; #define RS232_TxData      *(volatile unsigned char *)(0x00400042)
; #define RS232_RxData      *(volatile unsigned char *)(0x00400042)
; #define CAN0_CONTROLLER(i) (*(volatile unsigned char *)(0x00500000 + (i << 1)))
; #define CAN1_CONTROLLER(i) (*(volatile unsigned char *)(0x00500200 + (i << 1)))
; /* Can 0 register definitions */
; #define Can0_ModeControlReg      CAN0_CONTROLLER(0)
; #define Can0_CommandReg          CAN0_CONTROLLER(1)
; #define Can0_StatusReg           CAN0_CONTROLLER(2)
; #define Can0_InterruptReg        CAN0_CONTROLLER(3)
; #define Can0_InterruptEnReg      CAN0_CONTROLLER(4) /* PeliCAN mode */
; #define Can0_BusTiming0Reg       CAN0_CONTROLLER(6)
; #define Can0_BusTiming1Reg       CAN0_CONTROLLER(7)
; #define Can0_OutControlReg       CAN0_CONTROLLER(8)
; /* address definitions of Other Registers */
; #define Can0_ArbLostCapReg       CAN0_CONTROLLER(11)
; #define Can0_ErrCodeCapReg       CAN0_CONTROLLER(12)
; #define Can0_ErrWarnLimitReg     CAN0_CONTROLLER(13)
; #define Can0_RxErrCountReg       CAN0_CONTROLLER(14)
; #define Can0_TxErrCountReg       CAN0_CONTROLLER(15)
; #define Can0_RxMsgCountReg       CAN0_CONTROLLER(29)
; #define Can0_RxBufStartAdr       CAN0_CONTROLLER(30)
; #define Can0_ClockDivideReg      CAN0_CONTROLLER(31)
; /* address definitions of Acceptance Code & Mask Registers - RESET MODE */
; #define Can0_AcceptCode0Reg      CAN0_CONTROLLER(16)
; #define Can0_AcceptCode1Reg      CAN0_CONTROLLER(17)
; #define Can0_AcceptCode2Reg      CAN0_CONTROLLER(18)
; #define Can0_AcceptCode3Reg      CAN0_CONTROLLER(19)
; #define Can0_AcceptMask0Reg      CAN0_CONTROLLER(20)
; #define Can0_AcceptMask1Reg      CAN0_CONTROLLER(21)
; #define Can0_AcceptMask2Reg      CAN0_CONTROLLER(22)
; #define Can0_AcceptMask3Reg      CAN0_CONTROLLER(23)
; /* address definitions Rx Buffer - OPERATING MODE - Read only register*/
; #define Can0_RxFrameInfo         CAN0_CONTROLLER(16)
; #define Can0_RxBuffer1           CAN0_CONTROLLER(17)
; #define Can0_RxBuffer2           CAN0_CONTROLLER(18)
; #define Can0_RxBuffer3           CAN0_CONTROLLER(19)
; #define Can0_RxBuffer4           CAN0_CONTROLLER(20)
; #define Can0_RxBuffer5           CAN0_CONTROLLER(21)
; #define Can0_RxBuffer6           CAN0_CONTROLLER(22)
; #define Can0_RxBuffer7           CAN0_CONTROLLER(23)
; #define Can0_RxBuffer8           CAN0_CONTROLLER(24)
; #define Can0_RxBuffer9           CAN0_CONTROLLER(25)
; #define Can0_RxBuffer10          CAN0_CONTROLLER(26)
; #define Can0_RxBuffer11          CAN0_CONTROLLER(27)
; #define Can0_RxBuffer12          CAN0_CONTROLLER(28)
; /* address definitions of the Tx-Buffer - OPERATING MODE - Write only register */
; #define Can0_TxFrameInfo         CAN0_CONTROLLER(16)
; #define Can0_TxBuffer1           CAN0_CONTROLLER(17)
; #define Can0_TxBuffer2           CAN0_CONTROLLER(18)
; #define Can0_TxBuffer3           CAN0_CONTROLLER(19)
; #define Can0_TxBuffer4           CAN0_CONTROLLER(20)
; #define Can0_TxBuffer5           CAN0_CONTROLLER(21)
; #define Can0_TxBuffer6           CAN0_CONTROLLER(22)
; #define Can0_TxBuffer7           CAN0_CONTROLLER(23)
; #define Can0_TxBuffer8           CAN0_CONTROLLER(24)
; #define Can0_TxBuffer9           CAN0_CONTROLLER(25)
; #define Can0_TxBuffer10          CAN0_CONTROLLER(26)
; #define Can0_TxBuffer11          CAN0_CONTROLLER(27)
; #define Can0_TxBuffer12          CAN0_CONTROLLER(28)
; /* read only addresses */
; #define Can0_TxFrameInfoRd       CAN0_CONTROLLER(96)
; #define Can0_TxBufferRd1         CAN0_CONTROLLER(97)
; #define Can0_TxBufferRd2         CAN0_CONTROLLER(98)
; #define Can0_TxBufferRd3         CAN0_CONTROLLER(99)
; #define Can0_TxBufferRd4         CAN0_CONTROLLER(100)
; #define Can0_TxBufferRd5         CAN0_CONTROLLER(101)
; #define Can0_TxBufferRd6         CAN0_CONTROLLER(102)
; #define Can0_TxBufferRd7         CAN0_CONTROLLER(103)
; #define Can0_TxBufferRd8         CAN0_CONTROLLER(104)
; #define Can0_TxBufferRd9         CAN0_CONTROLLER(105)
; #define Can0_TxBufferRd10        CAN0_CONTROLLER(106)
; #define Can0_TxBufferRd11        CAN0_CONTROLLER(107)
; #define Can0_TxBufferRd12        CAN0_CONTROLLER(108)
; /* CAN1 Controller register definitions */
; #define Can1_ModeControlReg      CAN1_CONTROLLER(0)
; #define Can1_CommandReg          CAN1_CONTROLLER(1)
; #define Can1_StatusReg           CAN1_CONTROLLER(2)
; #define Can1_InterruptReg        CAN1_CONTROLLER(3)
; #define Can1_InterruptEnReg      CAN1_CONTROLLER(4) /* PeliCAN mode */
; #define Can1_BusTiming0Reg       CAN1_CONTROLLER(6)
; #define Can1_BusTiming1Reg       CAN1_CONTROLLER(7)
; #define Can1_OutControlReg       CAN1_CONTROLLER(8)
; /* address definitions of Other Registers */
; #define Can1_ArbLostCapReg       CAN1_CONTROLLER(11)
; #define Can1_ErrCodeCapReg       CAN1_CONTROLLER(12)
; #define Can1_ErrWarnLimitReg     CAN1_CONTROLLER(13)
; #define Can1_RxErrCountReg       CAN1_CONTROLLER(14)
; #define Can1_TxErrCountReg       CAN1_CONTROLLER(15)
; #define Can1_RxMsgCountReg       CAN1_CONTROLLER(29)
; #define Can1_RxBufStartAdr       CAN1_CONTROLLER(30)
; #define Can1_ClockDivideReg      CAN1_CONTROLLER(31)
; /* address definitions of Acceptance Code & Mask Registers - RESET MODE */
; #define Can1_AcceptCode0Reg      CAN1_CONTROLLER(16)
; #define Can1_AcceptCode1Reg      CAN1_CONTROLLER(17)
; #define Can1_AcceptCode2Reg      CAN1_CONTROLLER(18)
; #define Can1_AcceptCode3Reg      CAN1_CONTROLLER(19)
; #define Can1_AcceptMask0Reg      CAN1_CONTROLLER(20)
; #define Can1_AcceptMask1Reg      CAN1_CONTROLLER(21)
; #define Can1_AcceptMask2Reg      CAN1_CONTROLLER(22)
; #define Can1_AcceptMask3Reg      CAN1_CONTROLLER(23)
; /* address definitions Rx Buffer - OPERATING MODE - Read only register*/
; #define Can1_RxFrameInfo         CAN1_CONTROLLER(16)
; #define Can1_RxBuffer1           CAN1_CONTROLLER(17)
; #define Can1_RxBuffer2           CAN1_CONTROLLER(18)
; #define Can1_RxBuffer3           CAN1_CONTROLLER(19)
; #define Can1_RxBuffer4           CAN1_CONTROLLER(20)
; #define Can1_RxBuffer5           CAN1_CONTROLLER(21)
; #define Can1_RxBuffer6           CAN1_CONTROLLER(22)
; #define Can1_RxBuffer7           CAN1_CONTROLLER(23)
; #define Can1_RxBuffer8           CAN1_CONTROLLER(24)
; #define Can1_RxBuffer9           CAN1_CONTROLLER(25)
; #define Can1_RxBuffer10          CAN1_CONTROLLER(26)
; #define Can1_RxBuffer11          CAN1_CONTROLLER(27)
; #define Can1_RxBuffer12          CAN1_CONTROLLER(28)
; /* address definitions of the Tx-Buffer - OPERATING MODE - Write only register */
; #define Can1_TxFrameInfo         CAN1_CONTROLLER(16)
; #define Can1_TxBuffer1           CAN1_CONTROLLER(17)
; #define Can1_TxBuffer2           CAN1_CONTROLLER(18)
; #define Can1_TxBuffer3           CAN1_CONTROLLER(19)
; #define Can1_TxBuffer4           CAN1_CONTROLLER(20)
; #define Can1_TxBuffer5           CAN1_CONTROLLER(21)
; #define Can1_TxBuffer6           CAN1_CONTROLLER(22)
; #define Can1_TxBuffer7           CAN1_CONTROLLER(23)
; #define Can1_TxBuffer8           CAN1_CONTROLLER(24)
; #define Can1_TxBuffer9           CAN1_CONTROLLER(25)
; #define Can1_TxBuffer10          CAN1_CONTROLLER(26)
; #define Can1_TxBuffer11          CAN1_CONTROLLER(27)
; #define Can1_TxBuffer12          CAN1_CONTROLLER(28)
; /* read only addresses */
; #define Can1_TxFrameInfoRd       CAN1_CONTROLLER(96)
; #define Can1_TxBufferRd1         CAN1_CONTROLLER(97)
; #define Can1_TxBufferRd2         CAN1_CONTROLLER(98)
; #define Can1_TxBufferRd3         CAN1_CONTROLLER(99)
; #define Can1_TxBufferRd4         CAN1_CONTROLLER(100)
; #define Can1_TxBufferRd5         CAN1_CONTROLLER(101)
; #define Can1_TxBufferRd6         CAN1_CONTROLLER(102)
; #define Can1_TxBufferRd7         CAN1_CONTROLLER(103)
; #define Can1_TxBufferRd8         CAN1_CONTROLLER(104)
; #define Can1_TxBufferRd9         CAN1_CONTROLLER(105)
; #define Can1_TxBufferRd10        CAN1_CONTROLLER(106)
; #define Can1_TxBufferRd11        CAN1_CONTROLLER(107)
; #define Can1_TxBufferRd12        CAN1_CONTROLLER(108)
; /* bit definitions for the Mode & Control Register */
; #define RM_RR_Bit 0x01 /* reset mode (request) bit */
; #define LOM_Bit 0x02 /* listen only mode bit */
; #define STM_Bit 0x04 /* self test mode bit */
; #define AFM_Bit 0x08 /* acceptance filter mode bit */
; #define SM_Bit  0x10 /* enter sleep mode bit */
; /* bit definitions for the Interrupt Enable & Control Register */
; #define RIE_Bit 0x01 /* receive interrupt enable bit */
; #define TIE_Bit 0x02 /* transmit interrupt enable bit */
; #define EIE_Bit 0x04 /* error warning interrupt enable bit */
; #define DOIE_Bit 0x08 /* data overrun interrupt enable bit */
; #define WUIE_Bit 0x10 /* wake-up interrupt enable bit */
; #define EPIE_Bit 0x20 /* error passive interrupt enable bit */
; #define ALIE_Bit 0x40 /* arbitration lost interr. enable bit*/
; #define BEIE_Bit 0x80 /* bus error interrupt enable bit */
; /* bit definitions for the Command Register */
; #define TR_Bit 0x01 /* transmission request bit */
; #define AT_Bit 0x02 /* abort transmission bit */
; #define RRB_Bit 0x04 /* release receive buffer bit */
; #define CDO_Bit 0x08 /* clear data overrun bit */
; #define SRR_Bit 0x10 /* self reception request bit */
; /* bit definitions for the Status Register */
; #define RBS_Bit 0x01 /* receive buffer status bit */
; #define DOS_Bit 0x02 /* data overrun status bit */
; #define TBS_Bit 0x04 /* transmit buffer status bit */
; #define TCS_Bit 0x08 /* transmission complete status bit */
; #define RS_Bit 0x10 /* receive status bit */
; #define TS_Bit 0x20 /* transmit status bit */
; #define ES_Bit 0x40 /* error status bit */
; #define BS_Bit 0x80 /* bus status bit */
; /* bit definitions for the Interrupt Register */
; #define RI_Bit 0x01 /* receive interrupt bit */
; #define TI_Bit 0x02 /* transmit interrupt bit */
; #define EI_Bit 0x04 /* error warning interrupt bit */
; #define DOI_Bit 0x08 /* data overrun interrupt bit */
; #define WUI_Bit 0x10 /* wake-up interrupt bit */
; #define EPI_Bit 0x20 /* error passive interrupt bit */
; #define ALI_Bit 0x40 /* arbitration lost interrupt bit */
; #define BEI_Bit 0x80 /* bus error interrupt bit */
; /* bit definitions for the Bus Timing Registers */
; #define SAM_Bit 0x80                        /* sample mode bit 1 == the bus is sampled 3 times, 0 == the bus is sampled once */
; /* bit definitions for the Output Control Register OCMODE1, OCMODE0 */
; #define BiPhaseMode 0x00 /* bi-phase output mode */
; #define NormalMode 0x02 /* normal output mode */
; #define ClkOutMode 0x03 /* clock output mode */
; /* output pin configuration for TX1 */
; #define OCPOL1_Bit 0x20 /* output polarity control bit */
; #define Tx1Float 0x00 /* configured as float */
; #define Tx1PullDn 0x40 /* configured as pull-down */
; #define Tx1PullUp 0x80 /* configured as pull-up */
; #define Tx1PshPull 0xC0 /* configured as push/pull */
; /* output pin configuration for TX0 */
; #define OCPOL0_Bit 0x04 /* output polarity control bit */
; #define Tx0Float 0x00 /* configured as float */
; #define Tx0PullDn 0x08 /* configured as pull-down */
; #define Tx0PullUp 0x10 /* configured as pull-up */
; #define Tx0PshPull 0x18 /* configured as push/pull */
; /* bit definitions for the Clock Divider Register */
; #define DivBy1 0x07 /* CLKOUT = oscillator frequency */
; #define DivBy2 0x00 /* CLKOUT = 1/2 oscillator frequency */
; #define ClkOff_Bit 0x08 /* clock off bit, control of the CLK OUT pin */
; #define RXINTEN_Bit 0x20 /* pin TX1 used for receive interrupt */
; #define CBP_Bit 0x40 /* CAN comparator bypass control bit */
; #define CANMode_Bit 0x80 /* CAN mode definition bit */
; /*- definition of used constants ---------------------------------------*/
; #define YES 1
; #define NO 0
; #define ENABLE 1
; #define DISABLE 0
; #define ENABLE_N 0
; #define DISABLE_N 1
; #define INTLEVELACT 0
; #define INTEDGEACT 1
; #define PRIORITY_LOW 0
; #define PRIORITY_HIGH 1
; /* default (reset) value for register content, clear register */
; #define ClrByte 0x00
; /* constant: clear Interrupt Enable Register */
; #define ClrIntEnSJA ClrByte
; /* definitions for the acceptance code and mask register */
; #define DontCare 0xFF
; /*  bus timing values for
; **  bit-rate : 100 kBit/s
; **  oscillator frequency : 25 MHz, 1 sample per bit, 0 tolerance %
; **  maximum tolerated propagation delay : 4450 ns
; **  minimum requested propagation delay : 500 ns
; **
; **  https://www.kvaser.com/support/calculators/bit-timing-calculator/
; **  T1 	T2 	BTQ 	SP% 	SJW 	BIT RATE 	ERR% 	BTR0 	BTR1
; **  17	8	25	    68	     1	      100	    0	      04	7f
; */
; /*********************************************************************************************************
; **  Subroutine to provide a low level output function to 6850 ACIA
; **  This routine provides the basic functionality to output a single character to the serial Port
; **  to allow the board to communicate with HyperTerminal Program
; **
; **  NOTE you do not call this function directly, instead you call the normal putchar() function
; **  which in turn calls _putch() below). Other functions like puts(), printf() call putchar() so will
; **  call _putch() also
; *********************************************************************************************************/
; int _putch( int c)
; {
       section   code
       xdef      __putch
__putch:
       link      A6,#0
; while((RS232_Status & (char)(0x02)) != (char)(0x02))    // wait for Tx bit in status register or 6850 serial comms chip to be '1'
_putch_1:
       move.b    4194368,D0
       and.b     #2,D0
       cmp.b     #2,D0
       beq.s     _putch_3
       bra       _putch_1
_putch_3:
; ;
; RS232_TxData = (c & (char)(0x7f));                      // write to the data register to output the character (mask off bit 8 to keep it 7 bit ASCII)
       move.l    8(A6),D0
       and.l     #127,D0
       move.b    D0,4194370
; return c ;                                              // putchar() expects the character to be returned
       move.l    8(A6),D0
       unlk      A6
       rts
; }
; /*********************************************************************************************************
; **  Subroutine to provide a low level input function to 6850 ACIA
; **  This routine provides the basic functionality to input a single character from the serial Port
; **  to allow the board to communicate with HyperTerminal Program Keyboard (your PC)
; **
; **  NOTE you do not call this function directly, instead you call the normal getchar() function
; **  which in turn calls _getch() below). Other functions like gets(), scanf() call getchar() so will
; **  call _getch() also
; *********************************************************************************************************/
; int _getch( void )
; {
       xdef      __getch
__getch:
       link      A6,#-4
; char c ;
; while((RS232_Status & (char)(0x01)) != (char)(0x01))    // wait for Rx bit in 6850 serial comms chip status register to be '1'
_getch_1:
       move.b    4194368,D0
       and.b     #1,D0
       cmp.b     #1,D0
       beq.s     _getch_3
       bra       _getch_1
_getch_3:
; ;
; return (RS232_RxData & (char)(0x7f));                   // read received character, mask off top bit and return as 7 bit ASCII character
       move.b    4194370,D0
       and.l     #255,D0
       and.l     #127,D0
       unlk      A6
       rts
; }
; // initialisation for Can controller 0
; void Init_CanBus_Controller0(void)
; {
       xdef      _Init_CanBus_Controller0
_Init_CanBus_Controller0:
       move.l    A2,-(A7)
       lea       _printf.L,A2
; // TODO - put your Canbus initialisation code for CanController 0 here
; // See section 4.2.1 in the application note for details (PELICAN MODE)
; // disable interrupts
; Can0_InterruptEnReg = DISABLE;
       clr.b     5242888
; //put it in reset mode
; printf("\r\nPutting CAN controller in reset mode");
       pea       @canbus~1_1.L
       jsr       (A2)
       addq.w    #4,A7
; while ( (Can0_ModeControlReg & RM_RR_Bit) == ClrByte) {
Init_CanBus_Controller0_1:
       move.b    5242880,D0
       and.b     #1,D0
       bne.s     Init_CanBus_Controller0_3
; Can0_ModeControlReg |= RM_RR_Bit;
       or.b      #1,5242880
       bra       Init_CanBus_Controller0_1
Init_CanBus_Controller0_3:
; }
; // set the clode divider register (pelican mode)
; printf("\r\nSetting the clock divide register");
       pea       @canbus~1_2.L
       jsr       (A2)
       addq.w    #4,A7
; Can0_ClockDivideReg = CANMode_Bit | CBP_Bit | DivBy1;
       move.b    #199,5242942
; // Disable CAN interrupts
; printf("\r\nDisableing CAN interrupts");
       pea       @canbus~1_3.L
       jsr       (A2)
       addq.w    #4,A7
; Can0_InterruptEnReg = ClrIntEnSJA;
       clr.b     5242888
; // define acceptance code and mask
; printf("\r\nSetting acceptance code and mask");
       pea       @canbus~1_4.L
       jsr       (A2)
       addq.w    #4,A7
; Can0_AcceptMask0Reg = ClrByte;
       clr.b     5242920
; Can0_AcceptMask1Reg = ClrByte;
       clr.b     5242922
; Can0_AcceptMask2Reg = ClrByte;
       clr.b     5242924
; Can0_AcceptMask3Reg = ClrByte;
       clr.b     5242926
; Can0_AcceptCode0Reg = DontCare;
       move.b    #255,5242912
; Can0_AcceptCode1Reg = DontCare;
       move.b    #255,5242914
; Can0_AcceptCode2Reg = DontCare;
       move.b    #255,5242916
; Can0_AcceptCode3Reg = DontCare;
       move.b    #255,5242918
; //configure bus timing register
; printf("\r\nConfiguring bus timing");
       pea       @canbus~1_5.L
       jsr       (A2)
       addq.w    #4,A7
; Can0_BusTiming0Reg = 0x04;
       move.b    #4,5242892
; Can0_BusTiming1Reg = 0x7f;
       move.b    #127,5242894
; //configure output control register
; printf("\r\nConfiguring CAN Output register");
       pea       @canbus~1_6.L
       jsr       (A2)
       addq.w    #4,A7
; Can0_OutControlReg = Tx1Float | Tx0PshPull | NormalMode;
       move.b    #26,5242896
; //remove reset mode
; printf("\r\nPutting CAN controller in operation mode");
       pea       @canbus~1_7.L
       jsr       (A2)
       addq.w    #4,A7
; do {
Init_CanBus_Controller0_4:
; Can0_ModeControlReg = ClrByte;
       clr.b     5242880
       move.b    5242880,D0
       and.b     #1,D0
       bne       Init_CanBus_Controller0_4
       move.l    (A7)+,A2
       rts
; } while ( (Can0_ModeControlReg & RM_RR_Bit) != ClrByte);
; }
; // initialisation for Can controller 1
; void Init_CanBus_Controller1(void)
; {
       xdef      _Init_CanBus_Controller1
_Init_CanBus_Controller1:
       move.l    A2,-(A7)
       lea       _printf.L,A2
; // TODO - put your Canbus initialisation code for CanController 1 here
; // See section 4.2.1 in the application note for details (PELICAN MODE)
; // disable interrupts
; Can1_InterruptEnReg = DISABLE;
       clr.b     5243400
; //put it in reset mode
; printf("\r\nPutting CAN controller in reset mode");
       pea       @canbus~1_1.L
       jsr       (A2)
       addq.w    #4,A7
; while ( (Can1_ModeControlReg & RM_RR_Bit) == ClrByte) {
Init_CanBus_Controller1_1:
       move.b    5243392,D0
       and.b     #1,D0
       bne.s     Init_CanBus_Controller1_3
; Can1_ModeControlReg |= RM_RR_Bit;
       or.b      #1,5243392
       bra       Init_CanBus_Controller1_1
Init_CanBus_Controller1_3:
; }
; // set the clock divider register (pelican mode)
; printf("\r\nSetting the clock divide register");
       pea       @canbus~1_2.L
       jsr       (A2)
       addq.w    #4,A7
; Can1_ClockDivideReg = CANMode_Bit | CBP_Bit | DivBy1;
       move.b    #199,5243454
; // Disable CAN interrupts
; printf("\r\nDisableing CAN interrupts");
       pea       @canbus~1_3.L
       jsr       (A2)
       addq.w    #4,A7
; Can1_InterruptEnReg = ClrIntEnSJA;
       clr.b     5243400
; // define acceptance code and mask
; printf("\r\nSetting acceptance code and mask");
       pea       @canbus~1_4.L
       jsr       (A2)
       addq.w    #4,A7
; Can1_AcceptMask0Reg = ClrByte;
       clr.b     5243432
; Can1_AcceptMask1Reg = ClrByte;
       clr.b     5243434
; Can1_AcceptMask2Reg = ClrByte;
       clr.b     5243436
; Can1_AcceptMask3Reg = ClrByte;
       clr.b     5243438
; Can1_AcceptCode0Reg = DontCare;
       move.b    #255,5243424
; Can1_AcceptCode1Reg = DontCare;
       move.b    #255,5243426
; Can1_AcceptCode2Reg = DontCare;
       move.b    #255,5243428
; Can1_AcceptCode3Reg = DontCare;
       move.b    #255,5243430
; //configure bus timing register
; printf("\r\nConfiguring bus timing");
       pea       @canbus~1_5.L
       jsr       (A2)
       addq.w    #4,A7
; Can1_BusTiming0Reg = 0x04;
       move.b    #4,5243404
; Can1_BusTiming1Reg = 0x7f;
       move.b    #127,5243406
; //configure output control register
; printf("\r\nConfiguring CAN Output register");
       pea       @canbus~1_6.L
       jsr       (A2)
       addq.w    #4,A7
; Can1_OutControlReg = Tx1Float | Tx0PshPull | NormalMode;
       move.b    #26,5243408
; //remove reset mode
; printf("\r\nPutting CAN controller in operation mode");
       pea       @canbus~1_7.L
       jsr       (A2)
       addq.w    #4,A7
; do {
Init_CanBus_Controller1_4:
; Can1_ModeControlReg = ClrByte;
       clr.b     5243392
       move.b    5243392,D0
       and.b     #1,D0
       bne       Init_CanBus_Controller1_4
       move.l    (A7)+,A2
       rts
; } while ( (Can1_ModeControlReg & RM_RR_Bit) != ClrByte);
; }
; // Transmit for sending a message via Can controller 0
; void CanBus0_Transmit(void)
; {
       xdef      _CanBus0_Transmit
_CanBus0_Transmit:
       move.l    D2,-(A7)
; // TODO - put your Canbus transmit code for CanController 0 here
; // See section 4.2.2 in the application note for details (PELICAN MODE)
; int i;
; do {
CanBus0_Transmit_1:
; for (i = 0; i < 1000; i++) {};
       clr.l     D2
CanBus0_Transmit_3:
       cmp.l     #1000,D2
       bge.s     CanBus0_Transmit_5
       addq.l    #1,D2
       bra       CanBus0_Transmit_3
CanBus0_Transmit_5:
       move.b    5242884,D0
       and.b     #4,D0
       cmp.b     #4,D0
       bne       CanBus0_Transmit_1
; } while ( (Can0_StatusReg & TBS_Bit) != TBS_Bit);
; Can0_TxFrameInfo = 0x08;
       move.b    #8,5242912
; Can0_TxBuffer1 = 0xa5;
       move.b    #165,5242914
; Can0_TxBuffer2 = 0x20;
       move.b    #32,5242916
; Can0_TxBuffer3 = 0x51;
       move.b    #81,5242918
; Can0_TxBuffer4 = 0x52;
       move.b    #82,5242920
; Can0_TxBuffer5 = 0x53;
       move.b    #83,5242922
; Can0_TxBuffer6 = 0x54;
       move.b    #84,5242924
; Can0_TxBuffer7 = 0x55;
       move.b    #85,5242926
; Can0_TxBuffer8 = 0x56;
       move.b    #86,5242928
; Can0_TxBuffer9 = 0x57;
       move.b    #87,5242930
; Can0_TxBuffer10 = 0x58;
       move.b    #88,5242932
; Can0_CommandReg = TR_Bit;
       move.b    #1,5242882
       move.l    (A7)+,D2
       rts
; //check transmission is complete TS, RS, TBS, TCS
; }
; // Transmit for sending a message via Can controller 1
; void CanBus1_Transmit(void)
; {
       xdef      _CanBus1_Transmit
_CanBus1_Transmit:
       move.l    D2,-(A7)
; // TODO - put your Canbus transmit code for CanController 1 here
; // See section 4.2.2 in the application note for details (PELICAN MODE)
; int i;
; do {
CanBus1_Transmit_1:
; for (i = 0; i < 1000; i++) {};
       clr.l     D2
CanBus1_Transmit_3:
       cmp.l     #1000,D2
       bge.s     CanBus1_Transmit_5
       addq.l    #1,D2
       bra       CanBus1_Transmit_3
CanBus1_Transmit_5:
       move.b    5243396,D0
       and.b     #4,D0
       cmp.b     #4,D0
       bne       CanBus1_Transmit_1
; } while ( (Can1_StatusReg & TBS_Bit) != TBS_Bit);
; Can1_TxFrameInfo = 0x08;
       move.b    #8,5243424
; Can1_TxBuffer1 = 0xa5;
       move.b    #165,5243426
; Can1_TxBuffer2 = 0x20;
       move.b    #32,5243428
; Can1_TxBuffer3 = 0x51;
       move.b    #81,5243430
; Can1_TxBuffer4 = 0x52;
       move.b    #82,5243432
; Can1_TxBuffer5 = 0x53;
       move.b    #83,5243434
; Can1_TxBuffer6 = 0x54;
       move.b    #84,5243436
; Can1_TxBuffer7 = 0x55;
       move.b    #85,5243438
; Can1_TxBuffer8 = 0x56;
       move.b    #86,5243440
; Can1_TxBuffer9 = 0x57;
       move.b    #87,5243442
; Can1_TxBuffer10 = 0x58;
       move.b    #88,5243444
; Can1_CommandReg = TR_Bit;
       move.b    #1,5243394
       move.l    (A7)+,D2
       rts
; //check transmission is complete TS, RS, TBS, TCS
; }
; // Receive for reading a received message via Can controller 0
; void CanBus0_Receive(void)
; {
       xdef      _CanBus0_Receive
_CanBus0_Receive:
; // TODO - put your Canbus receive code for CanController 0 here
; // See section 4.2.4 in the application note for details (PELICAN MODE)
; // wait for receive full flag
; while ( (Can0_StatusReg & RBS_Bit) == ClrByte);
CanBus0_Receive_1:
       move.b    5242884,D0
       and.b     #1,D0
       bne.s     CanBus0_Receive_3
       bra       CanBus0_Receive_1
CanBus0_Receive_3:
; //get the content
; printf("\r\nCan0 Received: 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x",
       move.b    5242932,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    5242930,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    5242928,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    5242926,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    5242924,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    5242922,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    5242920,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    5242918,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    5242916,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    5242914,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @canbus~1_8.L
       jsr       _printf
       add.w     #44,A7
; Can0_RxBuffer1, Can0_RxBuffer2, Can0_RxBuffer3, Can0_RxBuffer4, Can0_RxBuffer5, 
; Can0_RxBuffer6, Can0_RxBuffer7, Can0_RxBuffer8, Can0_RxBuffer9, Can0_RxBuffer10);
; // release receive buffer
; Can0_CommandReg = RRB_Bit;
       move.b    #4,5242882
       rts
; }
; // Receive for reading a received message via Can controller 1
; void CanBus1_Receive(void)
; {
       xdef      _CanBus1_Receive
_CanBus1_Receive:
; // TODO - put your Canbus receive code for CanController 1 here
; // See section 4.2.4 in the application note for details (PELICAN MODE)
; // wait for receive full flag
; while ( (Can1_StatusReg & RBS_Bit) == ClrByte);
CanBus1_Receive_1:
       move.b    5243396,D0
       and.b     #1,D0
       bne.s     CanBus1_Receive_3
       bra       CanBus1_Receive_1
CanBus1_Receive_3:
; //get the content
; printf("\r\nCan1 Received: 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x",
       move.b    5243444,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    5243442,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    5243440,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    5243438,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    5243436,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    5243434,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    5243432,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    5243430,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    5243428,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    5243426,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @canbus~1_9.L
       jsr       _printf
       add.w     #44,A7
; Can1_RxBuffer1, Can1_RxBuffer2, Can1_RxBuffer3, Can1_RxBuffer4, Can1_RxBuffer5, 
; Can1_RxBuffer6, Can1_RxBuffer7, Can1_RxBuffer8, Can1_RxBuffer9, Can1_RxBuffer10);
; // release receive buffer
; Can1_CommandReg = RRB_Bit;
       move.b    #4,5243394
       rts
; }
; void delay(void) {
       xdef      _delay
_delay:
       movem.l   D2/D3,-(A7)
; int i,j;
; for (i = 0; i < 1000; i++) {
       clr.l     D3
delay_1:
       cmp.l     #1000,D3
       bge.s     delay_3
; for (j = 0; j < 1000; j++) {};
       clr.l     D2
delay_4:
       cmp.l     #1000,D2
       bge.s     delay_6
       addq.l    #1,D2
       bra       delay_4
delay_6:
       addq.l    #1,D3
       bra       delay_1
delay_3:
       movem.l   (A7)+,D2/D3
       rts
; }
; }
; void CanBusTest(void)
; {
       xdef      _CanBusTest
_CanBusTest:
       move.l    A2,-(A7)
       lea       _printf.L,A2
; // initialise the two Can controllers
; Init_CanBus_Controller0();
       jsr       _Init_CanBus_Controller0
; Init_CanBus_Controller1();
       jsr       _Init_CanBus_Controller1
; printf("\r\n\r\n---- CANBUS Test ----\r\n") ;
       pea       @canbus~1_10.L
       jsr       (A2)
       addq.w    #4,A7
; // while (1) {
; //     CanBus0_Transmit();
; // }
; Can0_ModeControlReg = RM_RR_Bit; /* Enter Reset Mode */
       move.b    #1,5242880
; Can0_ClockDivideReg = CANMode_Bit; /* PeliCAN Mode */
       move.b    #128,5242942
; Can0_ModeControlReg = STM_Bit; /* Enter Self Test Mode */
       move.b    #4,5242880
; /* and leave Reset Mode */
; Can0_TxFrameInfo = 0x03; /* Fill Transmit Buffer */
       move.b    #3,5242912
; Can0_TxBuffer1 = 0x53; /* */
       move.b    #83,5242914
; Can0_TxBuffer5 = 0xAA; /* Last Transmit Byte */
       move.b    #170,5242922
; Can0_CommandReg = SRR_Bit; /* Self Reception Request */
       move.b    #16,5242882
; if (Can0_RxBuffer1 != Can0_TxBufferRd1) {
       move.b    5242914,D0
       cmp.b     5243074,D0
       beq.s     CanBusTest_1
; printf("Self test failed");
       pea       @canbus~1_11.L
       jsr       (A2)
       addq.w    #4,A7
       bra.s     CanBusTest_2
CanBusTest_1:
; } else {
; printf("Self test passed, received:0x%x", Can0_RxBuffer1);
       move.b    5242914,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @canbus~1_12.L
       jsr       (A2)
       addq.w    #8,A7
CanBusTest_2:
; }
; if (Can0_RxBuffer2 != Can0_TxBufferRd2) {
       move.b    5242916,D0
       cmp.b     5243076,D0
       beq.s     CanBusTest_3
; printf("Self test failed");
       pea       @canbus~1_11.L
       jsr       (A2)
       addq.w    #4,A7
CanBusTest_3:
; }
; // simple application to alternately transmit and receive messages from each of two nodes
; while(1)    {
CanBusTest_5:
; delay();                    // write a routine to delay say 1/2 second so we don't flood the network with messages to0 quickly
       jsr       _delay
; CanBus0_Transmit() ;       // transmit a message via Controller 0
       jsr       _CanBus0_Transmit
; CanBus1_Receive() ;        // receive a message via Controller 1 (and display it)
       jsr       _CanBus1_Receive
; printf("\r\n") ;
       pea       @canbus~1_13.L
       jsr       (A2)
       addq.w    #4,A7
; delay();                    // write a routine to delay say 1/2 second so we don't flood the network with messages to0 quickly
       jsr       _delay
; CanBus1_Transmit() ;        // transmit a message via Controller 1
       jsr       _CanBus1_Transmit
; CanBus0_Receive() ;         // receive a message via Controller 0 (and display it)
       jsr       _CanBus0_Receive
; printf("\r\n") ;
       pea       @canbus~1_13.L
       jsr       (A2)
       addq.w    #4,A7
       bra       CanBusTest_5
; }
; }
; void main (void){
       xdef      _main
_main:
; CanBusTest();
       jsr       _CanBusTest
       rts
; }
       section   const
@canbus~1_1:
       dc.b      13,10,80,117,116,116,105,110,103,32,67,65,78
       dc.b      32,99,111,110,116,114,111,108,108,101,114,32
       dc.b      105,110,32,114,101,115,101,116,32,109,111,100
       dc.b      101,0
@canbus~1_2:
       dc.b      13,10,83,101,116,116,105,110,103,32,116,104
       dc.b      101,32,99,108,111,99,107,32,100,105,118,105
       dc.b      100,101,32,114,101,103,105,115,116,101,114,0
@canbus~1_3:
       dc.b      13,10,68,105,115,97,98,108,101,105,110,103,32
       dc.b      67,65,78,32,105,110,116,101,114,114,117,112
       dc.b      116,115,0
@canbus~1_4:
       dc.b      13,10,83,101,116,116,105,110,103,32,97,99,99
       dc.b      101,112,116,97,110,99,101,32,99,111,100,101
       dc.b      32,97,110,100,32,109,97,115,107,0
@canbus~1_5:
       dc.b      13,10,67,111,110,102,105,103,117,114,105,110
       dc.b      103,32,98,117,115,32,116,105,109,105,110,103
       dc.b      0
@canbus~1_6:
       dc.b      13,10,67,111,110,102,105,103,117,114,105,110
       dc.b      103,32,67,65,78,32,79,117,116,112,117,116,32
       dc.b      114,101,103,105,115,116,101,114,0
@canbus~1_7:
       dc.b      13,10,80,117,116,116,105,110,103,32,67,65,78
       dc.b      32,99,111,110,116,114,111,108,108,101,114,32
       dc.b      105,110,32,111,112,101,114,97,116,105,111,110
       dc.b      32,109,111,100,101,0
@canbus~1_8:
       dc.b      13,10,67,97,110,48,32,82,101,99,101,105,118
       dc.b      101,100,58,32,48,120,37,120,32,48,120,37,120
       dc.b      32,48,120,37,120,32,48,120,37,120,32,48,120
       dc.b      37,120,32,48,120,37,120,32,48,120,37,120,32
       dc.b      48,120,37,120,32,48,120,37,120,32,48,120,37
       dc.b      120,0
@canbus~1_9:
       dc.b      13,10,67,97,110,49,32,82,101,99,101,105,118
       dc.b      101,100,58,32,48,120,37,120,32,48,120,37,120
       dc.b      32,48,120,37,120,32,48,120,37,120,32,48,120
       dc.b      37,120,32,48,120,37,120,32,48,120,37,120,32
       dc.b      48,120,37,120,32,48,120,37,120,32,48,120,37
       dc.b      120,0
@canbus~1_10:
       dc.b      13,10,13,10,45,45,45,45,32,67,65,78,66,85,83
       dc.b      32,84,101,115,116,32,45,45,45,45,13,10,0
@canbus~1_11:
       dc.b      83,101,108,102,32,116,101,115,116,32,102,97
       dc.b      105,108,101,100,0
@canbus~1_12:
       dc.b      83,101,108,102,32,116,101,115,116,32,112,97
       dc.b      115,115,101,100,44,32,114,101,99,101,105,118
       dc.b      101,100,58,48,120,37,120,0
@canbus~1_13:
       dc.b      13,10,0
       xref      _printf
