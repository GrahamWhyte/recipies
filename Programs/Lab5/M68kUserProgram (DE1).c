#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "IIC_Driver.h"
#include "ADC_DAC.h"


//IMPORTANT
//
// Uncomment one of the two #defines below
// Define StartOfExceptionVectorTable as 08030000 if running programs from sram or
// 0B000000 for running programs from dram
//
// In your labs, you will initially start by designing a system with SRam and later move to
// Dram, so these constants will need to be changed based on the version of the system you have
// building
//
// The working 68k system SOF file posted on canvas that you can use for your pre-lab
// is based around Dram so #define accordingly before building

#define MAX_SPI_ADDRESS 0x7FFFF
#define NUM_SECTORS 128
#define WRITES_PER_SECTOR 16

// #define StartOfExceptionVectorTable 0x08030000
#define StartOfExceptionVectorTable 0x0B000000

// #define CLOCK_FREQUENCY 45000000
#define CLOCK_FREQUENCY 25000000

/**********************************************************************************************
**	Parallel port addresses
**********************************************************************************************/

#define PortA   *(volatile unsigned char *)(0x00400000)
#define PortB   *(volatile unsigned char *)(0x00400002)
#define PortC   *(volatile unsigned char *)(0x00400004)
#define PortD   *(volatile unsigned char *)(0x00400006)
#define PortE   *(volatile unsigned char *)(0x00400008)

// /*********************************************************************************************
// **	Hex 7 seg displays port addresses
// *********************************************************************************************/

#define HEX_A        *(volatile unsigned char *)(0x00400010)
#define HEX_B        *(volatile unsigned char *)(0x00400012)
#define HEX_C        *(volatile unsigned char *)(0x00400014)    // de2 only
#define HEX_D        *(volatile unsigned char *)(0x00400016)    // de2 only

/**********************************************************************************************
**	LCD display port addresses
**********************************************************************************************/

#define LCDcommand   *(volatile unsigned char *)(0x00400020)
#define LCDdata      *(volatile unsigned char *)(0x00400022)

/*******************************************************************************************
**	Timer Port addresses
********************************************************************************************/

#define Timer1Data      *(volatile unsigned char *)(0x00400030)
#define Timer1Control   *(volatile unsigned char *)(0x00400032)
#define Timer1Status    *(volatile unsigned char *)(0x00400032)

#define Timer2Data      *(volatile unsigned char *)(0x00400034)
#define Timer2Control   *(volatile unsigned char *)(0x00400036)
#define Timer2Status    *(volatile unsigned char *)(0x00400036)

#define Timer3Data      *(volatile unsigned char *)(0x00400038)
#define Timer3Control   *(volatile unsigned char *)(0x0040003A)
#define Timer3Status    *(volatile unsigned char *)(0x0040003A)

#define Timer4Data      *(volatile unsigned char *)(0x0040003C)
#define Timer4Control   *(volatile unsigned char *)(0x0040003E)
#define Timer4Status    *(volatile unsigned char *)(0x0040003E)

// /*********************************************************************************************
// **	RS232 port addresses
// *********************************************************************************************/

#define RS232_Control     *(volatile unsigned char *)(0x00400040)
#define RS232_Status      *(volatile unsigned char *)(0x00400040)
#define RS232_TxData      *(volatile unsigned char *)(0x00400042)
#define RS232_RxData      *(volatile unsigned char *)(0x00400042)
#define RS232_Baud        *(volatile unsigned char *)(0x00400044)

/*********************************************************************************************
**	PIA 1 and 2 port addresses
*********************************************************************************************/

#define PIA1_PortA_Data     *(volatile unsigned char *)(0x00400050)         // combined data and data direction register share same address
#define PIA1_PortA_Control *(volatile unsigned char *)(0x00400052)
#define PIA1_PortB_Data     *(volatile unsigned char *)(0x00400054)         // combined data and data direction register share same address
#define PIA1_PortB_Control *(volatile unsigned char *)(0x00400056)

#define PIA2_PortA_Data     *(volatile unsigned char *)(0x00400060)         // combined data and data direction register share same address
#define PIA2_PortA_Control *(volatile unsigned char *)(0x00400062)
#define PIA2_PortB_data     *(volatile unsigned char *)(0x00400064)         // combined data and data direction register share same address
#define PIA2_PortB_Control *(volatile unsigned char *)(0x00400066)

// SPI Registers
#define SPI_Control         (*(volatile unsigned char *)(0x00408020))
#define SPI_Status          (*(volatile unsigned char *)(0x00408022))
#define SPI_Data            (*(volatile unsigned char *)(0x00408024))
#define SPI_Ext             (*(volatile unsigned char *)(0x00408026))
#define SPI_CS              (*(volatile unsigned char *)(0x00408028))

// these two macros enable or disable the flash memory chip enable off SSN_O[7..0]
// in this case we assume there is only 1 device connected to SSN_O[0] so we can
// write hex FE to the SPI_CS to enable it (the enable on the flash chip is active low)
// and write FF to disable it

#define   Enable_SPI_CS()             SPI_CS = 0xFE
#define   Disable_SPI_CS()            SPI_CS = 0xFF 


typedef struct 
{
    unsigned char SPR       : 2;
    unsigned char CPHA      : 1;
    unsigned char CPOL      : 1; 
    unsigned char MSTR      : 1;
    unsigned char reserved  : 1; 
    unsigned char SPE       : 1;
    unsigned char SPIE      : 1; 
} ControlRegister_t; 

typedef struct 
{
    unsigned char ESPR      : 2;
    unsigned char Reserved  : 4;
    unsigned char ICNT      : 2; 
} ExtRegister_t;

typedef struct 
{
    unsigned char CS0       : 1; 
    unsigned char CS1       : 1; 
    unsigned char CS2       : 1; 
    unsigned char CS3       : 1; 
    unsigned char CS4       : 1; 
    unsigned char CS5       : 1; 
    unsigned char CS6       : 1; 
    unsigned char CS7       : 1; 
} CSRegister_t;

typedef struct 
{
    unsigned char SPIF      : 1;
    unsigned char WCOL      : 1;
    unsigned char reserved  : 2; 
    unsigned char WF_FULL   : 1;
    unsigned char WF_EMPTY  : 1; 
    unsigned char RF_FULL   : 1;
    unsigned char RF_EMPTY  : 1; 
} StatusRegister_t; 

/*********************************************************************************************************************************
(( DO NOT initialise global variables here, do it main even if you want 0
(( it's a limitation of the compiler
(( YOU HAVE BEEN WARNED
*********************************************************************************************************************************/

unsigned int x, y, z, PortA_Count;
unsigned char Timer1Count, Timer2Count, Timer3Count, Timer4Count ;
volatile unsigned long int counter, rollovers;

int a[100][100], b[100][100], c[100][100];
int i, j, k, sum;

/*******************************************************************************************
** Function Prototypes
*******************************************************************************************/
void Wait1ms(void);
void Wait3ms(void);
void Init_LCD(void) ;
void LCDOutchar(int c);
void LCDOutMess(char *theMessage);
void LCDClearln(void);
void LCDline1Message(char *theMessage);
void LCDline2Message(char *theMessage);
int sprintf(char *out, const char *format, ...) ;
void startTimer(void);
unsigned long int endTimer(void);

/*****************************************************************************************
**	Interrupt service routine for Timers
**
**  Timers 1 - 4 share a common IRQ on the CPU  so this function uses polling to figure
**  out which timer is producing the interrupt
**
*****************************************************************************************/

void Timer_ISR()
{
   	if(Timer1Status == 1) {         // Did Timer 1 produce the Interrupt?
   	    Timer1Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
   	    //PortA = Timer1Count++ ;     // increment an LED count on PortA with each tick of Timer 1
        counter++;
        if (!counter)   //handle the counter rolling over, who knows, maybe something will take an eternity to run
            rollovers++;
   	}

  	if(Timer2Status == 1) {         // Did Timer 2 produce the Interrupt?
   	    Timer2Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
   	    PortC = Timer2Count++ ;     // increment an LED count on PortC with each tick of Timer 2
   	}

   	if(Timer3Status == 1) {         // Did Timer 3 produce the Interrupt?
   	    Timer3Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
        HEX_A = Timer3Count++ ;     // increment a HEX count on Port HEX_A with each tick of Timer 3
   	}

   	if(Timer4Status == 1) {         // Did Timer 4 produce the Interrupt?
   	    Timer4Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
        HEX_B = Timer4Count++ ;     // increment a HEX count on HEX_B with each tick of Timer 4
   	}
}

/*****************************************************************************************
**	Interrupt service routine for ACIA. This device has it's own dedicate IRQ level
**  Add your code here to poll Status register and clear interrupt
*****************************************************************************************/

void ACIA_ISR()
{}

/***************************************************************************************
**	Interrupt service routine for PIAs 1 and 2. These devices share an IRQ level
**  Add your code here to poll Status register and clear interrupt
*****************************************************************************************/

void PIA_ISR()
{}

/***********************************************************************************
**	Interrupt service routine for Key 2 on DE1 board. Add your own response here
************************************************************************************/
void Key2PressISR()
{}

/***********************************************************************************
**	Interrupt service routine for Key 1 on DE1 board. Add your own response here
************************************************************************************/
void Key1PressISR()
{}

/************************************************************************************
**   Delay Subroutine to give the 68000 something useless to do to waste 1 mSec
************************************************************************************/
void Wait1ms(void)
{
    int  i ;
    for(i = 0; i < 1000; i ++)
        ;
}

/************************************************************************************
**  Subroutine to give the 68000 something useless to do to waste 3 mSec
**************************************************************************************/
void Wait3ms(void)
{
    int i ;
    for(i = 0; i < 3; i++)
        Wait1ms() ;
}

/*********************************************************************************************
**  Subroutine to initialise the LCD display by writing some commands to the LCD internal registers
**  Sets it for parallel port and 2 line display mode (if I recall correctly)
*********************************************************************************************/
void Init_LCD(void)
{
    LCDcommand = 0x0c ;
    Wait3ms() ;
    LCDcommand = 0x38 ;
    Wait3ms() ;
}

/*********************************************************************************************
**  Subroutine to initialise the RS232 Port by writing some commands to the internal registers
*********************************************************************************************/
void Init_RS232(void)
{
    RS232_Control = 0x15 ; //  %00010101 set up 6850 uses divide by 16 clock, set RTS low, 8 bits no parity, 1 stop bit, transmitter interrupt disabled
    RS232_Baud = 0x1 ;      // program baud rate generator 001 = 115k, 010 = 57.6k, 011 = 38.4k, 100 = 19.2, all others = 9600
}

/*********************************************************************************************************
**  Subroutine to provide a low level output function to 6850 ACIA
**  This routine provides the basic functionality to output a single character to the serial Port
**  to allow the board to communicate with HyperTerminal Program
**
**  NOTE you do not call this function directly, instead you call the normal putchar() function
**  which in turn calls _putch() below). Other functions like puts(), printf() call putchar() so will
**  call _putch() also
*********************************************************************************************************/

int _putch( int c)
{
    while((RS232_Status & (char)(0x02)) != (char)(0x02))    // wait for Tx bit in status register or 6850 serial comms chip to be '1'
        ;

    RS232_TxData = (c & (char)(0x7f));                      // write to the data register to output the character (mask off bit 8 to keep it 7 bit ASCII)
    return c ;                                              // putchar() expects the character to be returned
}

/*********************************************************************************************************
**  Subroutine to provide a low level input function to 6850 ACIA
**  This routine provides the basic functionality to input a single character from the serial Port
**  to allow the board to communicate with HyperTerminal Program Keyboard (your PC)
**
**  NOTE you do not call this function directly, instead you call the normal getchar() function
**  which in turn calls _getch() below). Other functions like gets(), scanf() call getchar() so will
**  call _getch() also
*********************************************************************************************************/
int _getch( void )
{
    char c ;
    while((RS232_Status & (char)(0x01)) != (char)(0x01))    // wait for Rx bit in 6850 serial comms chip status register to be '1'
        ;

    return (RS232_RxData & (char)(0x7f));                   // read received character, mask off top bit and return as 7 bit ASCII character
}

/******************************************************************************
**  Subroutine to output a single character to the 2 row LCD display
**  It is assumed the character is an ASCII code and it will be displayed at the
**  current cursor position
*******************************************************************************/
void LCDOutchar(int c)
{
    LCDdata = (char)(c);
    Wait1ms() ;
}

/**********************************************************************************
*subroutine to output a message at the current cursor position of the LCD display
************************************************************************************/
void LCDOutMessage(char *theMessage)
{
    char c ;
    while((c = *theMessage++) != 0)     // output characters from the string until NULL
        LCDOutchar(c) ;
}

/******************************************************************************
*subroutine to clear the line by issuing 24 space characters
*******************************************************************************/
void LCDClearln(void)
{
    int i ;
    for(i = 0; i < 24; i ++)
        LCDOutchar(' ') ;       // write a space char to the LCD display
}

/******************************************************************************
**  Subroutine to move the LCD cursor to the start of line 1 and clear that line
*******************************************************************************/
void LCDLine1Message(char *theMessage)
{
    LCDcommand = 0x80 ;
    Wait3ms();
    LCDClearln() ;
    LCDcommand = 0x80 ;
    Wait3ms() ;
    LCDOutMessage(theMessage) ;
}

/******************************************************************************
**  Subroutine to move the LCD cursor to the start of line 2 and clear that line
*******************************************************************************/
void LCDLine2Message(char *theMessage)
{
    LCDcommand = 0xC0 ;
    Wait3ms();
    LCDClearln() ;
    LCDcommand = 0xC0 ;
    Wait3ms() ;
    LCDOutMessage(theMessage) ;
}

/*********************************************************************************************************************************
**  IMPORTANT FUNCTION
**  This function install an exception handler so you can capture and deal with any 68000 exception in your program
**  You pass it the name of a function in your code that will get called in response to the exception (as the 1st parameter)
**  and in the 2nd parameter, you pass it the exception number that you want to take over (see 68000 exceptions for details)
**  Calling this function allows you to deal with Interrupts for example
***********************************************************************************************************************************/

void InstallExceptionHandler( void (*function_ptr)(), int level)
{
    volatile long int *RamVectorAddress = (volatile long int *)(StartOfExceptionVectorTable) ;   // pointer to the Ram based interrupt vector table created in Cstart in debug monitor

    RamVectorAddress[level] = (long int *)(function_ptr);                       // install the address of our function into the exception table
}


/******************************************************************************************
** The following code is for the SPI controller
*******************************************************************************************/
// return true if the SPI has finished transmitting a byte (to say the Flash chip) return false otherwise
// this can be used in a polling algorithm to know when the controller is busy or idle.

int TestForSPITransmitDataComplete(void)    {

    /* TODO replace 0 below with a test for status register SPIF bit and if set, return true */
    return (SPI_Status>>7);
}

/************************************************************************************
** initialises the SPI controller chip to set speed, interrupt capability etc.
************************************************************************************/
void SPI_Init(void)
{
    //TODO
    //
    // Program the SPI Control, EXT, CS and Status registers to initialise the SPI controller
    // Don't forget to call this routine from main() before you do anything else with SPI
    //
    // Here are some settings we want to create
    //
    // Control Reg     - interrupts disabled, core enabled, Master mode, Polarity and Phase of clock = [0,0], speed =  divide by 32 = approx 700Khz
    // Ext Reg         - in conjunction with control reg, sets speed above and also sets interrupt flag after every completed transfer (each byte)
    // SPI_CS Reg      - control selection of slave SPI chips via their CS# signals
    // Status Reg      - status of SPI controller chip and used to clear any write collision and interrupt on transmit complete flag
    
    // ControlRegister_t tempControl; 
    // memset(&SPI_Control, 0, sizeof(unsigned char)); 
    // memset(&tempControl, 0, sizeof(ControlRegister_t));
    // tempControl.SPIE = 0; 
    // tempControl.SPE = 1; 
    // tempControl.MSTR = 1; 
    // tempControl.CPOL = 0;
    // tempControl.CPHA = 0; 
    // tempControl.SPR = 3; 
    // SPI_Control = (volatile unsigned char)tempControl; 
    
    // SPI_Control = (unsigned char)0b01010011; 
    SPI_Control = (unsigned char)0x53;
    SPI_Ext = (unsigned char)0x00; 
    Disable_SPI_CS(); 
}

/************************************************************************************
** return ONLY when the SPI controller has finished transmitting a byte
************************************************************************************/
void WaitForSPITransmitComplete(void)
{
    // TODO : poll the status register SPIF bit looking for completion of transmission
    // once transmission is complete, clear the write collision and interrupt on transmit complete flags in the status register (read documentation)
    // just in case they were set
    // while ((SPI_Status>>7)==0);
    while (1) {
        if (SPI_Status & (unsigned char)0x80) {
            break;
        }
    }
    // SPI_Status &= 0x3F; // And with 00111111 to clear top two bits
    SPI_Status = (unsigned char)0xC0;  
}

/************************************************************************************
** Write a byte to the SPI flash chip via the controller and returns (reads) whatever was
** given back by SPI device at the same time (removes the read byte from the FIFO)
************************************************************************************/
int WriteSPIChar(int c)
{
    // todo - write the byte in parameter 'c' to the SPI data register, this will start it transmitting to the flash device
    // wait for completion of transmission
    // return the received data from Flash chip (which may not be relevent depending upon what we are doing)
    // by reading fom the SPI controller Data Register.
    // note however that in order to get data from an SPI slave device (e.g. flash) chip we have to write a dummy byte to it
    //
    // modify '0' below to return back read byte from data register
    //
    unsigned char temp;

    // Load data register
    SPI_Data = (unsigned char)c; 

    // Poll for completion 
    WaitForSPITransmitComplete(); 

    temp = SPI_Data;
    // printf("\r\nRead: %x", temp);
    // Read data register
    return (int)temp;  
                
}

void ChipErase() {
    // wren
    Enable_SPI_CS();
    WriteSPIChar(0x06);
    Disable_SPI_CS(); 

    //chip erase
    Enable_SPI_CS();
    WriteSPIChar(0x60);
    Disable_SPI_CS(); 

    //wait for WIP
    Enable_SPI_CS();
    WriteSPIChar(0x05);
    while((WriteSPIChar(0x55)&0x01) == 1);
    Disable_SPI_CS();
}

void WriteData(int startAddress, unsigned char *dataArray, int numBytes) {
    int i = 0;
    
    // wren command
    Enable_SPI_CS();
    WriteSPIChar(0x06);
    Disable_SPI_CS(); 
    

    // write command
    Enable_SPI_CS();
    WriteSPIChar(0x02); //page program command

    WriteSPIChar(startAddress>>16); //addres high
    WriteSPIChar(startAddress>>8); // address middle
    WriteSPIChar(startAddress); //address low

    //stream data
    for (i; i < numBytes; i++) {
        WriteSPIChar((int)dataArray[i]);
    }
    
    Disable_SPI_CS();

    //wait for internal writing    
    Enable_SPI_CS();
    WriteSPIChar(0x05);
    while((WriteSPIChar(0x55)&0x01) == 1);
    Disable_SPI_CS();
}

void ReadData(int startAddress, int numBytes, unsigned char *data) {
    int i = 0;

    Enable_SPI_CS();
    WriteSPIChar(0x03); //read command

    WriteSPIChar(startAddress>>16); //addres high
    WriteSPIChar(startAddress>>8); // address middle
    WriteSPIChar(startAddress); //address low

    //stream data
    for (i; i < numBytes; i++) {
        data[i] = (unsigned char)WriteSPIChar(0x55); //dummy byte
    }

    Disable_SPI_CS();
}

void startTimer(void) {
    counter = 0;
    rollovers = 0;
}

unsigned long int endTimer(void) {
    return counter + (rollovers * sizeof(counter) * 256);
}

/******************************************************************************************************************************
* Start of user program
******************************************************************************************************************************/

void main()
{
    unsigned char iicArray[512]; 
    unsigned char readBuffer[512]; 
    unsigned char temp;
    unsigned int address; 
    unsigned int startingAddress = 0x40; 
    int i; 
    int length = 500; 

    // Populate test array 
    for (i=0; i<length; i++)
    {
        iicArray[i] = 0xFF; 
    }
    
    printf("\r\nInitializing IIC Controller");
    Init_IIC();
    printf("\r\nDone initialization, sending a byte...");
    // WriteByte(0xA6, 0x42, (unsigned int)0x55);
    // printf("\r\nDone writing!");
    // temp = ReadByte(0xA6, (unsigned int)0x55);
    // printf("\r\nRead back %x!", temp);
    // Write_128_Bytes(0xA6, 0x00, iicArray); 
    // temp = ReadByte(0xA6, 0x00);
    // printf("\r\nRead back %x!", temp);
    // temp = ReadByte(0xA6, 0x05);
    // printf("\r\nRead back %x!", temp);
    // temp = ReadByte(0xA6, 0x7F);
    // printf("\r\nRead back %x!", temp);
    // Read_128_Bytes(0xA6, 0x00, readBuffer); 
    // for (i=0; i<128; i++)
    // {
    //     printf("\r\nRead back %x!", readBuffer[i]);
    // }

    /**********************************************
     * Testing Read/Write Bytes functions
     **********************************************/

    // WriteBytes(0xA6, startingAddress, iicArray, length); 
    // ReadBytes(0xA6, startingAddress, readBuffer, length); 
    // for (i=0; i<length; i++)
    // {
    //     printf("\r\nRead back %x from %x!", readBuffer[i], startingAddress+i);
    // }

    // temp = ReadByte(0xA6, 0x40);
    // printf("\r\nRead back %x!", temp);
    // temp = ReadByte(0xA6, 0x7f);
    // printf("\r\nRead back %x!", temp);
    // temp = ReadByte(0xA6, 0x80);
    // printf("\r\nRead back %x!", temp);
    // temp = ReadByte(0xA6, 0x81);
    // printf("\r\nRead back %x!", temp);

    // for (address = startingAddress; address < startingAddress+length; address++)
    // {
    //     temp = ReadByte(0xA6, address);
    //     printf("\r\nRead back %x from %x!", temp, address);
    // }

    DigitalToAnalog(ADC_SLAVE_ADDRESS, iicArray, sizeof(iicArray)); 

    while(1);
}