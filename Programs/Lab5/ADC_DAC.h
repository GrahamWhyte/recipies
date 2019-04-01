#ifndef __ADC_DAC_H__
#define __ADC_DAC_H__ 

// Slave Address
#define ADC_SLAVE_ADDRESS 0x9E 

// Control Byte
#define ANALOG_OUTPUT_ENABLE 0x40

#define SINGLE_ENDED 0x00
#define DIFFERENTIAL 0x10 
#define MIXED       0x20 
#define TWO_DIFFERENTIAL 0x30

#define AUTO_INCREMENT 0x04

#define AD_CH_0 0x00
#define AD_CH_1 0x01
#define AD_CH_2 0x02
#define AD_CH_3 0x03

void DigitalToAnalog(unsigned char slaveAddress, unsigned char *data, unsigned int size); 
//void AnalogToDigital(); 

#endif

