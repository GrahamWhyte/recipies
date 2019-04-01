#include <stdio.h> 
#include "IIC_Driver.h"
#include "ADC_DAC.h"

// Globals
volatile unsigned char *IICTx_ = (unsigned char *)IIC_TRANSMIT;
volatile unsigned char *IICRx_ = (unsigned char *)IIC_RECEIVE;
volatile unsigned char *IICCommand_ = (unsigned char *)IIC_COMMAND;

/* Functions */ 
void DigitalToAnalog(unsigned char slaveAddress, unsigned char *data, unsigned int size) {
    int i; 

    // Generate IIC start signal
    *IICTx_ = slaveAddress | WRITE;	// fill the tx shift register
    *IICCommand_ = STA | WR;	// set write bit
    WaitForEndOfTransfer();
    WaitForAck(); 

    printf("\r\n Generated Start Signal"); 

    // Send Control Byte 
    *IICTx_ = ANALOG_OUTPUT_ENABLE | SINGLE_ENDED | AD_CH_0; 
    *IICCommand_ = WR;	// set write bit
	WaitForEndOfTransfer();
	WaitForAck();

    printf("\r\n Sent Control Byte"); 

    // Steam Data Byte 
    while (1)
    {
        for (i = 0; i < size; i++)
        {
            *IICTx_ = data[i]; 
            *IICCommand_ = WR; 
            WaitForEndOfTransfer();
	        WaitForAck();
        }
    }
}