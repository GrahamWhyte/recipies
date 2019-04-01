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

// *IICClkPrescalerLow = (unsigned char *)IIC_CLK_PRSCL_LO;
// *IICClkPrescalerHigh = (unsigned char *)IIC_CLK_PRSCL_HI;
// *IICControl = (unsigned char *)IIC_CONTROL;
// *IICTx = (unsigned char *)IIC_TRANSMIT;
// *IICRx = (unsigned char *)IIC_RECEIVE;
// *IICStatus = (unsigned char *)IIC_STATUS;
// *IICCommand = (unsigned char *)IIC_COMMAND;


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

void Write_128_Bytes(unsigned char IICSlaveAddress, unsigned int EEPROMAddress, unsigned char *iicArray) {
	
	int i; 
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

	for (i=0; i<127; i++)
	{
		*IICTx = iicArray[i];
		*IICCommand = WR;	// set write bit
		WaitForEndOfTransfer();
		WaitForAck();
	}

	// Send Data
	*IICTx = iicArray[127];
	*IICCommand = WR | STO;	//send stop signal

	WaitForEndOfTransfer();
	WaitForAck();
}

void Read_128_Bytes(unsigned char IICSlaveAddress, unsigned int EEPROMAddress, unsigned char *buffer){
	int i; 
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
	*IICCommand = WR | STA;	//send start signal

	WaitForEndOfTransfer();
	WaitForAck();

	for (i=0; i<127; i++)
	{
		*IICCommand = RD;
		WaitForEndOfTransfer();
		buffer[i] = *IICRx; 
	}

	// read SDA line
	*IICCommand = RD | STO | NACK;	//send stop signal

	WaitForEndOfTransfer();

	buffer[127] = *IICRx; 
}

void WriteBytes(unsigned char IICSlaveAddress, unsigned int EEPROMAddress, unsigned char *iicArray, unsigned int length){
	
	int i; 
	unsigned char blockSelect = (unsigned char)EEPROMAddress>>16; 
	unsigned char EEPROMAddress_High = (unsigned char)(EEPROMAddress>>8); 
	unsigned char EEPROMAddress_Low = (unsigned char)EEPROMAddress; 
	unsigned int bytesToWrite; 
	unsigned char lengthFlag = 0; 
	int lengthCopy = (int)length;  
	unsigned int CurrentAddress = EEPROMAddress; 
	unsigned char CurrentAddress_High;
	unsigned char CurrentAddress_Low; 

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

	// Check difference between starting address and next block 
	bytesToWrite = 128-EEPROMAddress%128; 

	// First block 
	for (i=0; i<bytesToWrite; i++)
	{
		printf("\r\nEntered First Block Loop"); 
		*IICTx = iicArray[i];
		if ( (i+1 >= length) || (i==(bytesToWrite-1)))
		{
			if (i+1 >= length)
				lengthFlag = 1;
			*IICCommand = WR | STO;	//send stop signal 
		}
		else
		{
			*IICCommand = WR;	// set write bit
		}
		WaitForEndOfTransfer();
		WaitForAck();
		lengthCopy--; 
		CurrentAddress++; 

		if (lengthFlag)
		{
			break; 
		}
	}
	// Other blocks
	if (!lengthFlag)
	{
		// Complete blocks
		while (lengthCopy >= 128)
		{
			printf("\r\n Entered Intermediate Loop"); 
			printf("\r\n Current Address Index: %x", CurrentAddress-EEPROMAddress); 
			Write_128_Bytes(0xA6, CurrentAddress, &(iicArray[CurrentAddress-EEPROMAddress])); 
			CurrentAddress+=128; 
			lengthCopy-=128; 
		}

		if (lengthCopy>0)
		{
			// Prepare for write to final block
			blockSelect = (unsigned char)CurrentAddress>>16; 
			CurrentAddress_High = (unsigned char)(CurrentAddress>>8);
			CurrentAddress_Low = (unsigned char)(CurrentAddress);

			IICSlaveAddress |= (blockSelect << 3);  

			// Transfer IIC Slave Address
			WaitForInternalWrite(IICSlaveAddress);

			// Transfer High EEProm Address
			*IICTx = CurrentAddress_High;	// fill the tx shift register
			*IICCommand = WR;	// set write bit

			WaitForEndOfTransfer();
			WaitForAck();

			// Transfer Low EEProm Address
			*IICTx = CurrentAddress_Low;	// fill the tx shift register
			*IICCommand = WR;	// set write bit

			WaitForEndOfTransfer();
			WaitForAck();

			// Last block
			for (i=0; i<lengthCopy-1; i++)
			{
				printf("\r\n Entered Last Block Loop"); 
				printf("\r\n Current Address Index: %x", CurrentAddress-EEPROMAddress); 
				*IICTx = iicArray[CurrentAddress-EEPROMAddress];
				*IICCommand = WR;	// set write bit
				WaitForEndOfTransfer();
				WaitForAck();
				CurrentAddress+=1; 
			}

			// Final byte
			*IICTx = iicArray[CurrentAddress-EEPROMAddress];
			*IICCommand = WR | STO;	// set write bit
			WaitForEndOfTransfer();
			WaitForAck();
		}

	}
	printf("\r\n Exited All Loops"); 
}

void ReadBytes(unsigned char IICSlaveAddress, unsigned int EEPROMAddress, unsigned char *buffer, unsigned int length){
	int i; 
	unsigned char blockSelect = (unsigned char)EEPROMAddress>>16; 
	unsigned char EEPROMAddress_High = (unsigned char)(EEPROMAddress>>8); 
	unsigned char EEPROMAddress_Low = (unsigned char)EEPROMAddress; 
	unsigned int bytesToRead; 
	unsigned char lengthFlag = 0; 
	int lengthCopy = (int)length;  
	unsigned int CurrentAddress = EEPROMAddress; 
	unsigned char CurrentAddress_High;
	unsigned char CurrentAddress_Low; 

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
	*IICCommand = WR | STA;	//send start signal

	WaitForEndOfTransfer();
	WaitForAck();

	// Check difference between starting address and next block 
	bytesToRead = 128-EEPROMAddress%128; 

	// First block 
	for (i=0; i<bytesToRead; i++)
	{
		printf("\r\nEntered First Block Loop"); 
		if ( (i+1 >= length) || (i==(bytesToRead-1)))
		{
			if (i+1 >= length)
				lengthFlag = 1;
			*IICCommand = RD | STO | NACK;	//send stop signal 
		}
		else
		{
			*IICCommand = RD;	// set write bit
		}
		WaitForEndOfTransfer();
		buffer[i] = *IICRx; 
		lengthCopy--; 
		CurrentAddress++; 

		if (lengthFlag)
		{
			break; 
		}
	}
	// Other blocks
	if (!lengthFlag)
	{
		// Complete blocks
		while (lengthCopy >= 128)
		{
			printf("\r\n Entered Intermediate Loop"); 
			printf("\r\n Current Address Index: %x", CurrentAddress-EEPROMAddress); 
			Read_128_Bytes(0xA6, CurrentAddress, &(buffer[CurrentAddress-EEPROMAddress])); 
			CurrentAddress+=128; 
			lengthCopy-=128; 
		}

		if (lengthCopy>0)
		{
			// Prepare for write to final block
			blockSelect = (unsigned char)CurrentAddress>>16; 
			CurrentAddress_High = (unsigned char)(CurrentAddress>>8);
			CurrentAddress_Low = (unsigned char)(CurrentAddress);

			IICSlaveAddress |= (blockSelect << 3);  

			// Transfer IIC Slave Address
			WaitForInternalWrite(IICSlaveAddress);

			// Transfer High EEProm Address
			*IICTx = CurrentAddress_High;	// fill the tx shift register
			*IICCommand = WR;	// set write bit

			WaitForEndOfTransfer();
			WaitForAck();

			// Transfer Low EEProm Address
			*IICTx = CurrentAddress_Low;	// fill the tx shift register
			*IICCommand = WR;	// set write bit

			WaitForEndOfTransfer();
			WaitForAck();

			// Fetch Data
			*IICTx = IICSlaveAddress | READ;
			*IICCommand = WR | STA;	//send start signal

			WaitForEndOfTransfer();
			WaitForAck();

			// Last block
			for (i=0; i<lengthCopy-1; i++)
			{
				printf("\r\n Entered Last Block Loop"); 
				printf("\r\n Current Address Index: %x", CurrentAddress-EEPROMAddress); 
				
				*IICCommand = RD;	// set read bit
				WaitForEndOfTransfer();
				buffer[CurrentAddress-EEPROMAddress] = *IICRx; 

				CurrentAddress+=1; 
			}

			// Final byte
			*IICCommand = RD | STO | NACK;	// set read bit
			WaitForEndOfTransfer();
			buffer[CurrentAddress-EEPROMAddress] = *IICRx; 
		}

	}
	printf("\r\n Exited All Loops"); 

}