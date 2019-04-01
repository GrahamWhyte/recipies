; C:\M68KV6.0 - 640BY480\M68KV6.0 - 800BY480 - (VERILOG) FOR STUDENTS\PROGRAMS\LAB5\M68KUSERPROGRAM (DE1).C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J. Fondse
; #include <stdio.h>
; #include <string.h>
; #include <ctype.h>
; #include "IIC_Driver.h"
; #include "ADC_DAC.h"
; //IMPORTANT
; //
; // Uncomment one of the two #defines below
; // Define StartOfExceptionVectorTable as 08030000 if running programs from sram or
; // 0B000000 for running programs from dram
; //
; // In your labs, you will initially start by designing a system with SRam and later move to
; // Dram, so these constants will need to be changed based on the version of the system you have
; // building
; //
; // The working 68k system SOF file posted on canvas that you can use for your pre-lab
; // is based around Dram so #define accordingly before building
; #define MAX_SPI_ADDRESS 0x7FFFF
; #define NUM_SECTORS 128
; #define WRITES_PER_SECTOR 16
; // #define StartOfExceptionVectorTable 0x08030000
; #define StartOfExceptionVectorTable 0x0B000000
; // #define CLOCK_FREQUENCY 45000000
; #define CLOCK_FREQUENCY 25000000
; /**********************************************************************************************
; **	Parallel port addresses
; **********************************************************************************************/
; #define PortA   *(volatile unsigned char *)(0x00400000)
; #define PortB   *(volatile unsigned char *)(0x00400002)
; #define PortC   *(volatile unsigned char *)(0x00400004)
; #define PortD   *(volatile unsigned char *)(0x00400006)
; #define PortE   *(volatile unsigned char *)(0x00400008)
; // /*********************************************************************************************
; // **	Hex 7 seg displays port addresses
; // *********************************************************************************************/
; #define HEX_A        *(volatile unsigned char *)(0x00400010)
; #define HEX_B        *(volatile unsigned char *)(0x00400012)
; #define HEX_C        *(volatile unsigned char *)(0x00400014)    // de2 only
; #define HEX_D        *(volatile unsigned char *)(0x00400016)    // de2 only
; /**********************************************************************************************
; **	LCD display port addresses
; **********************************************************************************************/
; #define LCDcommand   *(volatile unsigned char *)(0x00400020)
; #define LCDdata      *(volatile unsigned char *)(0x00400022)
; /*******************************************************************************************
; **	Timer Port addresses
; ********************************************************************************************/
; #define Timer1Data      *(volatile unsigned char *)(0x00400030)
; #define Timer1Control   *(volatile unsigned char *)(0x00400032)
; #define Timer1Status    *(volatile unsigned char *)(0x00400032)
; #define Timer2Data      *(volatile unsigned char *)(0x00400034)
; #define Timer2Control   *(volatile unsigned char *)(0x00400036)
; #define Timer2Status    *(volatile unsigned char *)(0x00400036)
; #define Timer3Data      *(volatile unsigned char *)(0x00400038)
; #define Timer3Control   *(volatile unsigned char *)(0x0040003A)
; #define Timer3Status    *(volatile unsigned char *)(0x0040003A)
; #define Timer4Data      *(volatile unsigned char *)(0x0040003C)
; #define Timer4Control   *(volatile unsigned char *)(0x0040003E)
; #define Timer4Status    *(volatile unsigned char *)(0x0040003E)
; // /*********************************************************************************************
; // **	RS232 port addresses
; // *********************************************************************************************/
; #define RS232_Control     *(volatile unsigned char *)(0x00400040)
; #define RS232_Status      *(volatile unsigned char *)(0x00400040)
; #define RS232_TxData      *(volatile unsigned char *)(0x00400042)
; #define RS232_RxData      *(volatile unsigned char *)(0x00400042)
; #define RS232_Baud        *(volatile unsigned char *)(0x00400044)
; /*********************************************************************************************
; **	PIA 1 and 2 port addresses
; *********************************************************************************************/
; #define PIA1_PortA_Data     *(volatile unsigned char *)(0x00400050)         // combined data and data direction register share same address
; #define PIA1_PortA_Control *(volatile unsigned char *)(0x00400052)
; #define PIA1_PortB_Data     *(volatile unsigned char *)(0x00400054)         // combined data and data direction register share same address
; #define PIA1_PortB_Control *(volatile unsigned char *)(0x00400056)
; #define PIA2_PortA_Data     *(volatile unsigned char *)(0x00400060)         // combined data and data direction register share same address
; #define PIA2_PortA_Control *(volatile unsigned char *)(0x00400062)
; #define PIA2_PortB_data     *(volatile unsigned char *)(0x00400064)         // combined data and data direction register share same address
; #define PIA2_PortB_Control *(volatile unsigned char *)(0x00400066)
; // SPI Registers
; #define SPI_Control         (*(volatile unsigned char *)(0x00408020))
; #define SPI_Status          (*(volatile unsigned char *)(0x00408022))
; #define SPI_Data            (*(volatile unsigned char *)(0x00408024))
; #define SPI_Ext             (*(volatile unsigned char *)(0x00408026))
; #define SPI_CS              (*(volatile unsigned char *)(0x00408028))
; // these two macros enable or disable the flash memory chip enable off SSN_O[7..0]
; // in this case we assume there is only 1 device connected to SSN_O[0] so we can
; // write hex FE to the SPI_CS to enable it (the enable on the flash chip is active low)
; // and write FF to disable it
; #define   Enable_SPI_CS()             SPI_CS = 0xFE
; #define   Disable_SPI_CS()            SPI_CS = 0xFF 
; typedef struct 
; {
; unsigned char SPR       : 2;
; unsigned char CPHA      : 1;
; unsigned char CPOL      : 1; 
; unsigned char MSTR      : 1;
; unsigned char reserved  : 1; 
; unsigned char SPE       : 1;
; unsigned char SPIE      : 1; 
; } ControlRegister_t; 
; typedef struct 
; {
; unsigned char ESPR      : 2;
; unsigned char Reserved  : 4;
; unsigned char ICNT      : 2; 
; } ExtRegister_t;
; typedef struct 
; {
; unsigned char CS0       : 1; 
; unsigned char CS1       : 1; 
; unsigned char CS2       : 1; 
; unsigned char CS3       : 1; 
; unsigned char CS4       : 1; 
; unsigned char CS5       : 1; 
; unsigned char CS6       : 1; 
; unsigned char CS7       : 1; 
; } CSRegister_t;
; typedef struct 
; {
; unsigned char SPIF      : 1;
; unsigned char WCOL      : 1;
; unsigned char reserved  : 2; 
; unsigned char WF_FULL   : 1;
; unsigned char WF_EMPTY  : 1; 
; unsigned char RF_FULL   : 1;
; unsigned char RF_EMPTY  : 1; 
; } StatusRegister_t; 
; /*********************************************************************************************************************************
; (( DO NOT initialise global variables here, do it main even if you want 0
; (( it's a limitation of the compiler
; (( YOU HAVE BEEN WARNED
; *********************************************************************************************************************************/
; unsigned int x, y, z, PortA_Count;
; unsigned char Timer1Count, Timer2Count, Timer3Count, Timer4Count ;
; volatile unsigned long int counter, rollovers;
; int a[100][100], b[100][100], c[100][100];
; int i, j, k, sum;
; /*******************************************************************************************
; ** Function Prototypes
; *******************************************************************************************/
; void Wait1ms(void);
; void Wait3ms(void);
; void Init_LCD(void) ;
; void LCDOutchar(int c);
; void LCDOutMess(char *theMessage);
; void LCDClearln(void);
; void LCDline1Message(char *theMessage);
; void LCDline2Message(char *theMessage);
; int sprintf(char *out, const char *format, ...) ;
; void startTimer(void);
; unsigned long int endTimer(void);
; /*****************************************************************************************
; **	Interrupt service routine for Timers
; **
; **  Timers 1 - 4 share a common IRQ on the CPU  so this function uses polling to figure
; **  out which timer is producing the interrupt
; **
; *****************************************************************************************/
; void Timer_ISR()
; {
       section   code
       xdef      _Timer_ISR
_Timer_ISR:
; if(Timer1Status == 1) {         // Did Timer 1 produce the Interrupt?
       move.b    4194354,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_3
; Timer1Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194354
; //PortA = Timer1Count++ ;     // increment an LED count on PortA with each tick of Timer 1
; counter++;
       addq.l    #1,_counter.L
; if (!counter)   //handle the counter rolling over, who knows, maybe something will take an eternity to run
       tst.l     _counter.L
       bne.s     Timer_ISR_3
; rollovers++;
       addq.l    #1,_rollovers.L
Timer_ISR_3:
; }
; if(Timer2Status == 1) {         // Did Timer 2 produce the Interrupt?
       move.b    4194358,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_5
; Timer2Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194358
; PortC = Timer2Count++ ;     // increment an LED count on PortC with each tick of Timer 2
       move.b    _Timer2Count.L,D0
       addq.b    #1,_Timer2Count.L
       move.b    D0,4194308
Timer_ISR_5:
; }
; if(Timer3Status == 1) {         // Did Timer 3 produce the Interrupt?
       move.b    4194362,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_7
; Timer3Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194362
; HEX_A = Timer3Count++ ;     // increment a HEX count on Port HEX_A with each tick of Timer 3
       move.b    _Timer3Count.L,D0
       addq.b    #1,_Timer3Count.L
       move.b    D0,4194320
Timer_ISR_7:
; }
; if(Timer4Status == 1) {         // Did Timer 4 produce the Interrupt?
       move.b    4194366,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_9
; Timer4Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194366
; HEX_B = Timer4Count++ ;     // increment a HEX count on HEX_B with each tick of Timer 4
       move.b    _Timer4Count.L,D0
       addq.b    #1,_Timer4Count.L
       move.b    D0,4194322
Timer_ISR_9:
       rts
; }
; }
; /*****************************************************************************************
; **	Interrupt service routine for ACIA. This device has it's own dedicate IRQ level
; **  Add your code here to poll Status register and clear interrupt
; *****************************************************************************************/
; void ACIA_ISR()
; {}
       xdef      _ACIA_ISR
_ACIA_ISR:
       rts
; /***************************************************************************************
; **	Interrupt service routine for PIAs 1 and 2. These devices share an IRQ level
; **  Add your code here to poll Status register and clear interrupt
; *****************************************************************************************/
; void PIA_ISR()
; {}
       xdef      _PIA_ISR
_PIA_ISR:
       rts
; /***********************************************************************************
; **	Interrupt service routine for Key 2 on DE1 board. Add your own response here
; ************************************************************************************/
; void Key2PressISR()
; {}
       xdef      _Key2PressISR
_Key2PressISR:
       rts
; /***********************************************************************************
; **	Interrupt service routine for Key 1 on DE1 board. Add your own response here
; ************************************************************************************/
; void Key1PressISR()
; {}
       xdef      _Key1PressISR
_Key1PressISR:
       rts
; /************************************************************************************
; **   Delay Subroutine to give the 68000 something useless to do to waste 1 mSec
; ************************************************************************************/
; void Wait1ms(void)
; {
       xdef      _Wait1ms
_Wait1ms:
       move.l    D2,-(A7)
; int  i ;
; for(i = 0; i < 1000; i ++)
       clr.l     D2
Wait1ms_1:
       cmp.l     #1000,D2
       bge.s     Wait1ms_3
       addq.l    #1,D2
       bra       Wait1ms_1
Wait1ms_3:
       move.l    (A7)+,D2
       rts
; ;
; }
; /************************************************************************************
; **  Subroutine to give the 68000 something useless to do to waste 3 mSec
; **************************************************************************************/
; void Wait3ms(void)
; {
       xdef      _Wait3ms
_Wait3ms:
       move.l    D2,-(A7)
; int i ;
; for(i = 0; i < 3; i++)
       clr.l     D2
Wait3ms_1:
       cmp.l     #3,D2
       bge.s     Wait3ms_3
; Wait1ms() ;
       jsr       _Wait1ms
       addq.l    #1,D2
       bra       Wait3ms_1
Wait3ms_3:
       move.l    (A7)+,D2
       rts
; }
; /*********************************************************************************************
; **  Subroutine to initialise the LCD display by writing some commands to the LCD internal registers
; **  Sets it for parallel port and 2 line display mode (if I recall correctly)
; *********************************************************************************************/
; void Init_LCD(void)
; {
       xdef      _Init_LCD
_Init_LCD:
; LCDcommand = 0x0c ;
       move.b    #12,4194336
; Wait3ms() ;
       jsr       _Wait3ms
; LCDcommand = 0x38 ;
       move.b    #56,4194336
; Wait3ms() ;
       jsr       _Wait3ms
       rts
; }
; /*********************************************************************************************
; **  Subroutine to initialise the RS232 Port by writing some commands to the internal registers
; *********************************************************************************************/
; void Init_RS232(void)
; {
       xdef      _Init_RS232
_Init_RS232:
; RS232_Control = 0x15 ; //  %00010101 set up 6850 uses divide by 16 clock, set RTS low, 8 bits no parity, 1 stop bit, transmitter interrupt disabled
       move.b    #21,4194368
; RS232_Baud = 0x1 ;      // program baud rate generator 001 = 115k, 010 = 57.6k, 011 = 38.4k, 100 = 19.2, all others = 9600
       move.b    #1,4194372
       rts
; }
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
; /******************************************************************************
; **  Subroutine to output a single character to the 2 row LCD display
; **  It is assumed the character is an ASCII code and it will be displayed at the
; **  current cursor position
; *******************************************************************************/
; void LCDOutchar(int c)
; {
       xdef      _LCDOutchar
_LCDOutchar:
       link      A6,#0
; LCDdata = (char)(c);
       move.l    8(A6),D0
       move.b    D0,4194338
; Wait1ms() ;
       jsr       _Wait1ms
       unlk      A6
       rts
; }
; /**********************************************************************************
; *subroutine to output a message at the current cursor position of the LCD display
; ************************************************************************************/
; void LCDOutMessage(char *theMessage)
; {
       xdef      _LCDOutMessage
_LCDOutMessage:
       link      A6,#-4
; char c ;
; while((c = *theMessage++) != 0)     // output characters from the string until NULL
LCDOutMessage_1:
       move.l    8(A6),A0
       addq.l    #1,8(A6)
       move.b    (A0),-1(A6)
       move.b    (A0),D0
       beq.s     LCDOutMessage_3
; LCDOutchar(c) ;
       move.b    -1(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _LCDOutchar
       addq.w    #4,A7
       bra       LCDOutMessage_1
LCDOutMessage_3:
       unlk      A6
       rts
; }
; /******************************************************************************
; *subroutine to clear the line by issuing 24 space characters
; *******************************************************************************/
; void LCDClearln(void)
; {
       xdef      _LCDClearln
_LCDClearln:
       move.l    D2,-(A7)
; int i ;
; for(i = 0; i < 24; i ++)
       clr.l     D2
LCDClearln_1:
       cmp.l     #24,D2
       bge.s     LCDClearln_3
; LCDOutchar(' ') ;       // write a space char to the LCD display
       pea       32
       jsr       _LCDOutchar
       addq.w    #4,A7
       addq.l    #1,D2
       bra       LCDClearln_1
LCDClearln_3:
       move.l    (A7)+,D2
       rts
; }
; /******************************************************************************
; **  Subroutine to move the LCD cursor to the start of line 1 and clear that line
; *******************************************************************************/
; void LCDLine1Message(char *theMessage)
; {
       xdef      _LCDLine1Message
_LCDLine1Message:
       link      A6,#0
; LCDcommand = 0x80 ;
       move.b    #128,4194336
; Wait3ms();
       jsr       _Wait3ms
; LCDClearln() ;
       jsr       _LCDClearln
; LCDcommand = 0x80 ;
       move.b    #128,4194336
; Wait3ms() ;
       jsr       _Wait3ms
; LCDOutMessage(theMessage) ;
       move.l    8(A6),-(A7)
       jsr       _LCDOutMessage
       addq.w    #4,A7
       unlk      A6
       rts
; }
; /******************************************************************************
; **  Subroutine to move the LCD cursor to the start of line 2 and clear that line
; *******************************************************************************/
; void LCDLine2Message(char *theMessage)
; {
       xdef      _LCDLine2Message
_LCDLine2Message:
       link      A6,#0
; LCDcommand = 0xC0 ;
       move.b    #192,4194336
; Wait3ms();
       jsr       _Wait3ms
; LCDClearln() ;
       jsr       _LCDClearln
; LCDcommand = 0xC0 ;
       move.b    #192,4194336
; Wait3ms() ;
       jsr       _Wait3ms
; LCDOutMessage(theMessage) ;
       move.l    8(A6),-(A7)
       jsr       _LCDOutMessage
       addq.w    #4,A7
       unlk      A6
       rts
; }
; /*********************************************************************************************************************************
; **  IMPORTANT FUNCTION
; **  This function install an exception handler so you can capture and deal with any 68000 exception in your program
; **  You pass it the name of a function in your code that will get called in response to the exception (as the 1st parameter)
; **  and in the 2nd parameter, you pass it the exception number that you want to take over (see 68000 exceptions for details)
; **  Calling this function allows you to deal with Interrupts for example
; ***********************************************************************************************************************************/
; void InstallExceptionHandler( void (*function_ptr)(), int level)
; {
       xdef      _InstallExceptionHandler
_InstallExceptionHandler:
       link      A6,#-4
; volatile long int *RamVectorAddress = (volatile long int *)(StartOfExceptionVectorTable) ;   // pointer to the Ram based interrupt vector table created in Cstart in debug monitor
       move.l    #184549376,-4(A6)
; RamVectorAddress[level] = (long int *)(function_ptr);                       // install the address of our function into the exception table
       move.l    -4(A6),A0
       move.l    12(A6),D0
       lsl.l     #2,D0
       move.l    8(A6),0(A0,D0.L)
       unlk      A6
       rts
; }
; /******************************************************************************************
; ** The following code is for the SPI controller
; *******************************************************************************************/
; // return true if the SPI has finished transmitting a byte (to say the Flash chip) return false otherwise
; // this can be used in a polling algorithm to know when the controller is busy or idle.
; int TestForSPITransmitDataComplete(void)    {
       xdef      _TestForSPITransmitDataComplete
_TestForSPITransmitDataComplete:
; /* TODO replace 0 below with a test for status register SPIF bit and if set, return true */
; return (SPI_Status>>7);
       move.b    4227106,D0
       and.l     #255,D0
       lsr.l     #7,D0
       rts
; }
; /************************************************************************************
; ** initialises the SPI controller chip to set speed, interrupt capability etc.
; ************************************************************************************/
; void SPI_Init(void)
; {
       xdef      _SPI_Init
_SPI_Init:
; //TODO
; //
; // Program the SPI Control, EXT, CS and Status registers to initialise the SPI controller
; // Don't forget to call this routine from main() before you do anything else with SPI
; //
; // Here are some settings we want to create
; //
; // Control Reg     - interrupts disabled, core enabled, Master mode, Polarity and Phase of clock = [0,0], speed =  divide by 32 = approx 700Khz
; // Ext Reg         - in conjunction with control reg, sets speed above and also sets interrupt flag after every completed transfer (each byte)
; // SPI_CS Reg      - control selection of slave SPI chips via their CS# signals
; // Status Reg      - status of SPI controller chip and used to clear any write collision and interrupt on transmit complete flag
; // ControlRegister_t tempControl; 
; // memset(&SPI_Control, 0, sizeof(unsigned char)); 
; // memset(&tempControl, 0, sizeof(ControlRegister_t));
; // tempControl.SPIE = 0; 
; // tempControl.SPE = 1; 
; // tempControl.MSTR = 1; 
; // tempControl.CPOL = 0;
; // tempControl.CPHA = 0; 
; // tempControl.SPR = 3; 
; // SPI_Control = (volatile unsigned char)tempControl; 
; // SPI_Control = (unsigned char)0b01010011; 
; SPI_Control = (unsigned char)0x53;
       move.b    #83,4227104
; SPI_Ext = (unsigned char)0x00; 
       clr.b     4227110
; Disable_SPI_CS(); 
       move.b    #255,4227112
       rts
; }
; /************************************************************************************
; ** return ONLY when the SPI controller has finished transmitting a byte
; ************************************************************************************/
; void WaitForSPITransmitComplete(void)
; {
       xdef      _WaitForSPITransmitComplete
_WaitForSPITransmitComplete:
; // TODO : poll the status register SPIF bit looking for completion of transmission
; // once transmission is complete, clear the write collision and interrupt on transmit complete flags in the status register (read documentation)
; // just in case they were set
; // while ((SPI_Status>>7)==0);
; while (1) {
WaitForSPITransmitComplete_1:
; if (SPI_Status & (unsigned char)0x80) {
       move.b    4227106,D0
       and.b     #128,D0
       beq.s     WaitForSPITransmitComplete_4
; break;
       bra.s     WaitForSPITransmitComplete_3
WaitForSPITransmitComplete_4:
       bra       WaitForSPITransmitComplete_1
WaitForSPITransmitComplete_3:
; }
; }
; // SPI_Status &= 0x3F; // And with 00111111 to clear top two bits
; SPI_Status = (unsigned char)0xC0;  
       move.b    #192,4227106
       rts
; }
; /************************************************************************************
; ** Write a byte to the SPI flash chip via the controller and returns (reads) whatever was
; ** given back by SPI device at the same time (removes the read byte from the FIFO)
; ************************************************************************************/
; int WriteSPIChar(int c)
; {
       xdef      _WriteSPIChar
_WriteSPIChar:
       link      A6,#-4
; // todo - write the byte in parameter 'c' to the SPI data register, this will start it transmitting to the flash device
; // wait for completion of transmission
; // return the received data from Flash chip (which may not be relevent depending upon what we are doing)
; // by reading fom the SPI controller Data Register.
; // note however that in order to get data from an SPI slave device (e.g. flash) chip we have to write a dummy byte to it
; //
; // modify '0' below to return back read byte from data register
; //
; unsigned char temp;
; // Load data register
; SPI_Data = (unsigned char)c; 
       move.l    8(A6),D0
       move.b    D0,4227108
; // Poll for completion 
; WaitForSPITransmitComplete(); 
       jsr       _WaitForSPITransmitComplete
; temp = SPI_Data;
       move.b    4227108,-1(A6)
; // printf("\r\nRead: %x", temp);
; // Read data register
; return (int)temp;  
       move.b    -1(A6),D0
       and.l     #255,D0
       unlk      A6
       rts
; }
; void ChipErase() {
       xdef      _ChipErase
_ChipErase:
       move.l    A2,-(A7)
       lea       _WriteSPIChar.L,A2
; // wren
; Enable_SPI_CS();
       move.b    #254,4227112
; WriteSPIChar(0x06);
       pea       6
       jsr       (A2)
       addq.w    #4,A7
; Disable_SPI_CS(); 
       move.b    #255,4227112
; //chip erase
; Enable_SPI_CS();
       move.b    #254,4227112
; WriteSPIChar(0x60);
       pea       96
       jsr       (A2)
       addq.w    #4,A7
; Disable_SPI_CS(); 
       move.b    #255,4227112
; //wait for WIP
; Enable_SPI_CS();
       move.b    #254,4227112
; WriteSPIChar(0x05);
       pea       5
       jsr       (A2)
       addq.w    #4,A7
; while((WriteSPIChar(0x55)&0x01) == 1);
ChipErase_1:
       pea       85
       jsr       (A2)
       addq.w    #4,A7
       and.l     #1,D0
       cmp.l     #1,D0
       bne.s     ChipErase_3
       bra       ChipErase_1
ChipErase_3:
; Disable_SPI_CS();
       move.b    #255,4227112
       move.l    (A7)+,A2
       rts
; }
; void WriteData(int startAddress, unsigned char *dataArray, int numBytes) {
       xdef      _WriteData
_WriteData:
       link      A6,#0
       movem.l   D2/D3/A2,-(A7)
       lea       _WriteSPIChar.L,A2
       move.l    8(A6),D3
; int i = 0;
       clr.l     D2
; // wren command
; Enable_SPI_CS();
       move.b    #254,4227112
; WriteSPIChar(0x06);
       pea       6
       jsr       (A2)
       addq.w    #4,A7
; Disable_SPI_CS(); 
       move.b    #255,4227112
; // write command
; Enable_SPI_CS();
       move.b    #254,4227112
; WriteSPIChar(0x02); //page program command
       pea       2
       jsr       (A2)
       addq.w    #4,A7
; WriteSPIChar(startAddress>>16); //addres high
       move.l    D3,D1
       asr.l     #8,D1
       asr.l     #8,D1
       move.l    D1,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; WriteSPIChar(startAddress>>8); // address middle
       move.l    D3,D1
       asr.l     #8,D1
       move.l    D1,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; WriteSPIChar(startAddress); //address low
       move.l    D3,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; //stream data
; for (i; i < numBytes; i++) {
WriteData_1:
       cmp.l     16(A6),D2
       bge.s     WriteData_3
; WriteSPIChar((int)dataArray[i]);
       move.l    12(A6),A0
       move.b    0(A0,D2.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A2)
       addq.w    #4,A7
       addq.l    #1,D2
       bra       WriteData_1
WriteData_3:
; }
; Disable_SPI_CS();
       move.b    #255,4227112
; //wait for internal writing    
; Enable_SPI_CS();
       move.b    #254,4227112
; WriteSPIChar(0x05);
       pea       5
       jsr       (A2)
       addq.w    #4,A7
; while((WriteSPIChar(0x55)&0x01) == 1);
WriteData_4:
       pea       85
       jsr       (A2)
       addq.w    #4,A7
       and.l     #1,D0
       cmp.l     #1,D0
       bne.s     WriteData_6
       bra       WriteData_4
WriteData_6:
; Disable_SPI_CS();
       move.b    #255,4227112
       movem.l   (A7)+,D2/D3/A2
       unlk      A6
       rts
; }
; void ReadData(int startAddress, int numBytes, unsigned char *data) {
       xdef      _ReadData
_ReadData:
       link      A6,#0
       movem.l   D2/D3/A2,-(A7)
       lea       _WriteSPIChar.L,A2
       move.l    8(A6),D3
; int i = 0;
       clr.l     D2
; Enable_SPI_CS();
       move.b    #254,4227112
; WriteSPIChar(0x03); //read command
       pea       3
       jsr       (A2)
       addq.w    #4,A7
; WriteSPIChar(startAddress>>16); //addres high
       move.l    D3,D1
       asr.l     #8,D1
       asr.l     #8,D1
       move.l    D1,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; WriteSPIChar(startAddress>>8); // address middle
       move.l    D3,D1
       asr.l     #8,D1
       move.l    D1,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; WriteSPIChar(startAddress); //address low
       move.l    D3,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; //stream data
; for (i; i < numBytes; i++) {
ReadData_1:
       cmp.l     12(A6),D2
       bge.s     ReadData_3
; data[i] = (unsigned char)WriteSPIChar(0x55); //dummy byte
       pea       85
       jsr       (A2)
       addq.w    #4,A7
       move.l    16(A6),A0
       move.b    D0,0(A0,D2.L)
       addq.l    #1,D2
       bra       ReadData_1
ReadData_3:
; }
; Disable_SPI_CS();
       move.b    #255,4227112
       movem.l   (A7)+,D2/D3/A2
       unlk      A6
       rts
; }
; void startTimer(void) {
       xdef      _startTimer
_startTimer:
; counter = 0;
       clr.l     _counter.L
; rollovers = 0;
       clr.l     _rollovers.L
       rts
; }
; unsigned long int endTimer(void) {
       xdef      _endTimer
_endTimer:
; return counter + (rollovers * sizeof(counter) * 256);
       move.l    _counter.L,D0
       move.l    _rollovers.L,-(A7)
       pea       4
       jsr       ULMUL
       move.l    (A7),D1
       addq.w    #8,A7
       move.l    D1,-(A7)
       pea       256
       jsr       ULMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D1,D0
       rts
; }
; /******************************************************************************************************************************
; * Start of user program
; ******************************************************************************************************************************/
; void main()
; {
       xdef      _main
_main:
       link      A6,#-1040
       move.l    D2,-(A7)
; unsigned char iicArray[512]; 
; unsigned char readBuffer[512]; 
; unsigned char temp;
; unsigned int address; 
; unsigned int startingAddress = 0x40; 
       move.l    #64,-8(A6)
; int i; 
; int length = 500; 
       move.l    #500,-4(A6)
; // Populate test array 
; for (i=0; i<length; i++)
       clr.l     D2
main_1:
       cmp.l     -4(A6),D2
       bge.s     main_3
; {
; iicArray[i] = 0xFF; 
       lea       -1038(A6),A0
       move.b    #255,0(A0,D2.L)
       addq.l    #1,D2
       bra       main_1
main_3:
; }
; printf("\r\nInitializing IIC Controller");
       pea       @m68kus~1_1.L
       jsr       _printf
       addq.w    #4,A7
; Init_IIC();
       jsr       _Init_IIC
; printf("\r\nDone initialization, sending a byte...");
       pea       @m68kus~1_2.L
       jsr       _printf
       addq.w    #4,A7
; // WriteByte(0xA6, 0x42, (unsigned int)0x55);
; // printf("\r\nDone writing!");
; // temp = ReadByte(0xA6, (unsigned int)0x55);
; // printf("\r\nRead back %x!", temp);
; // Write_128_Bytes(0xA6, 0x00, iicArray); 
; // temp = ReadByte(0xA6, 0x00);
; // printf("\r\nRead back %x!", temp);
; // temp = ReadByte(0xA6, 0x05);
; // printf("\r\nRead back %x!", temp);
; // temp = ReadByte(0xA6, 0x7F);
; // printf("\r\nRead back %x!", temp);
; // Read_128_Bytes(0xA6, 0x00, readBuffer); 
; // for (i=0; i<128; i++)
; // {
; //     printf("\r\nRead back %x!", readBuffer[i]);
; // }
; /**********************************************
; * Testing Read/Write Bytes functions
; **********************************************/
; // WriteBytes(0xA6, startingAddress, iicArray, length); 
; // ReadBytes(0xA6, startingAddress, readBuffer, length); 
; // for (i=0; i<length; i++)
; // {
; //     printf("\r\nRead back %x from %x!", readBuffer[i], startingAddress+i);
; // }
; // temp = ReadByte(0xA6, 0x40);
; // printf("\r\nRead back %x!", temp);
; // temp = ReadByte(0xA6, 0x7f);
; // printf("\r\nRead back %x!", temp);
; // temp = ReadByte(0xA6, 0x80);
; // printf("\r\nRead back %x!", temp);
; // temp = ReadByte(0xA6, 0x81);
; // printf("\r\nRead back %x!", temp);
; // for (address = startingAddress; address < startingAddress+length; address++)
; // {
; //     temp = ReadByte(0xA6, address);
; //     printf("\r\nRead back %x from %x!", temp, address);
; // }
; DigitalToAnalog(ADC_SLAVE_ADDRESS, iicArray, sizeof(iicArray)); 
       pea       512
       pea       -1038(A6)
       pea       158
       jsr       _DigitalToAnalog
       add.w     #12,A7
; while(1);
main_4:
       bra       main_4
; }
       section   const
@m68kus~1_1:
       dc.b      13,10,73,110,105,116,105,97,108,105,122,105
       dc.b      110,103,32,73,73,67,32,67,111,110,116,114,111
       dc.b      108,108,101,114,0
@m68kus~1_2:
       dc.b      13,10,68,111,110,101,32,105,110,105,116,105
       dc.b      97,108,105,122,97,116,105,111,110,44,32,115
       dc.b      101,110,100,105,110,103,32,97,32,98,121,116
       dc.b      101,46,46,46,0
       section   bss
       xdef      _x
_x:
       ds.b      4
       xdef      _y
_y:
       ds.b      4
       xdef      _z
_z:
       ds.b      4
       xdef      _PortA_Count
_PortA_Count:
       ds.b      4
       xdef      _Timer1Count
_Timer1Count:
       ds.b      1
       xdef      _Timer2Count
_Timer2Count:
       ds.b      1
       xdef      _Timer3Count
_Timer3Count:
       ds.b      1
       xdef      _Timer4Count
_Timer4Count:
       ds.b      1
       xdef      _counter
_counter:
       ds.b      4
       xdef      _rollovers
_rollovers:
       ds.b      4
       xdef      _a
_a:
       ds.b      40000
       xdef      _b
_b:
       ds.b      40000
       xdef      _c
_c:
       ds.b      40000
       xdef      _i
_i:
       ds.b      4
       xdef      _j
_j:
       ds.b      4
       xdef      _k
_k:
       ds.b      4
       xdef      _sum
_sum:
       ds.b      4
       xref      ULMUL
       xref      _Init_IIC
       xref      _DigitalToAnalog
       xref      _printf
