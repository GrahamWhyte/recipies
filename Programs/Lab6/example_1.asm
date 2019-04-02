; C:\IDE68K\OS EXAMPLES\EXAMPLE_1.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J. Fondse
; /*
; * EXAMPLE_1.C
; *
; * This is a minimal program to verify multitasking.
; *
; * Two tasks are created, Task #1 prints "This is task 1", task #2 prints "This is task 2".
; *
; * However, simple and small as it is, there is a serious flaw in the program. The device
; * to print on is a shared resource! The error can be observed as sometimes printing of
; * task #2 is interrupted and the higher priority task #1 prints "This is task #1" in the
; * middle of "This is task #2". A mutex or semaphore would be required to synchronize both tasks.
; *
; */
; #include <ucos_ii.h>
; #include <stdio.h>
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
; /*********************************************************************************************************************************
; **  IMPORTANT FUNCTION
; **  This function install an exception handler so you can capture and deal with any 68000 exception in your program
; **  You pass it the name of a function in your code that will get called in response to the exception (as the 1st parameter)
; **  and in the 2nd parameter, you pass it the exception number that you want to take over (see 68000 exceptions for details)
; **  Calling this function allows you to deal with Interrupts for example
; ***********************************************************************************************************************************/
; void InstallExceptionHandler( void (*function_ptr)(), int level)
; {
       section   code
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
; #define STACKSIZE  256
; /* Stacks */
; OS_STK Task1Stk[STACKSIZE];
; OS_STK Task2Stk[STACKSIZE];
; /* Prototypes */
; void Task1(void *);
; void Task2(void *);
; void main(void)
; {
       xdef      _main
_main:
; printf("Did Something"); 
       pea       @exampl~1_1.L
       jsr       _printf
       addq.w    #4,A7
; OSInit();
       jsr       _OSInit
; OSTaskCreate(Task1, OS_NULL, &Task1Stk[STACKSIZE], 10);
       pea       10
       lea       _Task1Stk.L,A0
       add.w     #512,A0
       move.l    A0,-(A7)
       clr.l     -(A7)
       pea       _Task1.L
       jsr       _OSTaskCreate
       add.w     #16,A7
; OSTaskCreate(Task2, OS_NULL, &Task2Stk[STACKSIZE], 11);
       pea       11
       lea       _Task2Stk.L,A0
       add.w     #512,A0
       move.l    A0,-(A7)
       clr.l     -(A7)
       pea       _Task2.L
       jsr       _OSTaskCreate
       add.w     #16,A7
; OSStart();
       jsr       _OSStart
       rts
; }
; void Task1(void *pdata)
; {
       xdef      _Task1
_Task1:
       link      A6,#0
; for (;;) {
Task1_1:
; printf("  This is Task #1\n");
       pea       @exampl~1_2.L
       jsr       _printf
       addq.w    #4,A7
; OSTimeDlyHMSM(0, 0, 1, 0);
       clr.l     -(A7)
       pea       1
       clr.l     -(A7)
       clr.l     -(A7)
       jsr       _OSTimeDlyHMSM
       add.w     #16,A7
       bra       Task1_1
; }
; }
; void Task2(void *pdata)
; {
       xdef      _Task2
_Task2:
       link      A6,#0
; for (;;) {
Task2_1:
; printf("    This is Task #2\n");
       pea       @exampl~1_3.L
       jsr       _printf
       addq.w    #4,A7
; OSTimeDlyHMSM(0, 0, 3, 0);
       clr.l     -(A7)
       pea       3
       clr.l     -(A7)
       clr.l     -(A7)
       jsr       _OSTimeDlyHMSM
       add.w     #16,A7
       bra       Task2_1
; }
; }
       section   const
@exampl~1_1:
       dc.b      68,105,100,32,83,111,109,101,116,104,105,110
       dc.b      103,0
@exampl~1_2:
       dc.b      32,32,84,104,105,115,32,105,115,32,84,97,115
       dc.b      107,32,35,49,10,0
@exampl~1_3:
       dc.b      32,32,32,32,84,104,105,115,32,105,115,32,84
       dc.b      97,115,107,32,35,50,10,0
       section   bss
       xdef      _Task1Stk
_Task1Stk:
       ds.b      512
       xdef      _Task2Stk
_Task2Stk:
       ds.b      512
       xref      _OSTimeDlyHMSM
       xref      _OSInit
       xref      _OSStart
       xref      _OSTaskCreate
       xref      _printf