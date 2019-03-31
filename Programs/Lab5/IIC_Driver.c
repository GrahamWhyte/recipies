

#include <stdlib.h>

#include "IIC_Driver.h"

/* Globals */
volatile unsigned char *IICClkPrescalerLow = (unsigned char *)IIC_CLK_PRSCL_LO;
volatile unsigned char *IICClkPrescalerHigh = (unsigned char *)IIC_CLK_PRSCL_HI;
volatile unsigned char *IICControl = (unsigned char *)IIC_CONTROL;
volatile unsigned char *IICTx = (unsigned char *)IIC_TRANSMIT;
volatile unsigned char *IICRx = (unsigned char *)IIC_RECEIVE;
volatile unsigned char *IICStatus = (unsigned char *)IIC_STATUS;
volatile unsigned char *IICCommand = (unsigned char *)IIC_COMMAND;


/* Functions */
void WaitForEndOfTransfer(void) {

	while (1){							
		if ( ( (*IICStatus) & TIP) == 0)	
			break;							
	}			
}

void WaitForAck(void) {
	while (1){								
		if ( ( (*IICStatus) & RxACK) == 0 )	
			break;							
	}				
}	

unsigned char EEPROMInternalWritting(void) {
	return ( ( (*IICStatus) & RxACK) == 0 );
}
																									

void Init_IIC(void) {
	*IICControl = 0;

	*IICClkPrescalerLow = CLK_100K_LO;
	*IICClkPrescalerHigh = CLK_100K_HI;

	*IICControl = CORE_ENABLED | INTERRUPT_DISABLED;

} 

void WriteByte(unsigned char IICSlaveAddress, unsigned char byteToStore, unsigned int EEPROMAddress) {

	unsigned char blockSelect = (unsigned char)EEPROMAddress>>16; 
	unsigned char EEPROMAddress_High = (unsigned char)(EEPROMAddress>>8); 
	unsigned char EEPROMAddress_Low = (unsigned char)EEPROMAddress; 

	IICSlaveAddress |= (blockSelect << 3);  

	// Transfer IIC Slave Address
	WaitForInternalWrite(IICSlaveAddress);

	// Transfer High EEProm Address
	*IICTx = EEPROMAddress_High;	// fill the tx shift register
	*IICCommand = WR;	// set write bit

	WaitForEndOfTransfer();
	WaitForAck();

	// Transfer Low EEProm Address
	*IICTx = EEPROMAddress_Low;	// fill the tx shift register
	*IICCommand = WR;	// set write bit

	WaitForEndOfTransfer();
	WaitForAck();

	// Send Data
	*IICTx = byteToStore;
	*IICCommand = WR | STO;	//send stop signal

	WaitForEndOfTransfer();
	WaitForAck();

}

unsigned char ReadByte(unsigned char IICSlaveAddress, unsigned int EEPROMAddress) {
	unsigned char blockSelect = (unsigned char)EEPROMAddress>>16; 
	unsigned char EEPROMAddress_High = (unsigned char)(EEPROMAddress>>8); 
	unsigned char EEPROMAddress_Low = (unsigned char)EEPROMAddress; 

	IICSlaveAddress |= (blockSelect << 3);  

	// Transfer IIC Slave Address
	WaitForInternalWrite(IICSlaveAddress);

	// Transfer High EEProm Address
	*IICTx = EEPROMAddress_High;	// fill the tx shift register
	*IICCommand = WR;	// set write bit

	WaitForEndOfTransfer();
	WaitForAck();

	// Transfer Low EEProm Address
	*IICTx = EEPROMAddress_Low;	// fill the tx shift register
	*IICCommand = WR;	// set write bit

	WaitForEndOfTransfer();
	WaitForAck();

	// Fetch Data
	*IICTx = IICSlaveAddress | READ;
	*IICCommand = WR | STA;	//send stop signal

	WaitForEndOfTransfer();
	WaitForAck();

	// read SDA line
	*IICCommand = RD | STO | NACK;	//send stop signal

	WaitForEndOfTransfer();

	return *IICRx;
}

void WaitForInternalWrite(unsigned char IICSlaveAddress) {
	
	do {
		*IICTx = IICSlaveAddress | WRITE;	// fill the tx shift register
		*IICCommand = STA | WR;	// set write bit

		WaitForEndOfTransfer();
	} while (!EEPROMInternalWritting());

}