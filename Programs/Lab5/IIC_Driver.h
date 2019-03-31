#ifndef __IIC_DRIVER_H__
#define __IIC_DRIVER_H__

// register locations
#define IIC_BASE_ADDRESS 	0x00408000
#define IIC_CLK_PRSCL_LO 	(IIC_BASE_ADDRESS)
#define IIC_CLK_PRSCL_HI 	(IIC_BASE_ADDRESS + 2)
#define IIC_CONTROL 		(IIC_BASE_ADDRESS + 4)
#define IIC_TRANSMIT		(IIC_BASE_ADDRESS + 6)
#define IIC_RECEIVE 		(IIC_BASE_ADDRESS + 6)
#define IIC_COMMAND 		(IIC_BASE_ADDRESS + 8)
#define IIC_STATUS 			(IIC_BASE_ADDRESS + 8)

// read/write stuff
#define READ	0x01
#define WRITE	0x00

/**********************/
/* register bit masks */
/**********************/

// clock prescaller
#define CLK_100K_LO	0x31
#define CLK_100K_HI	0x00

// control
#define CORE_ENABLED		0x80
#define INTERRUPT_DISABLED	0x00

// command reg
#define STA 	0x80
#define STO		0x40
#define RD 		0x20
#define WR 		0x10
#define NACK	0x08
#define IACK	0x01

// status register
#define RxACK	0x80
#define BUSY	0x40
#define AL		0x20
#define TIP		0x02
#define IF 		0x01

/**************/
/* prototypes */
/**************/
void Init_IIC(void);
void WaitForEndOfTransfer(void);
void WaitForAck(void);
void WriteByte(unsigned char address, unsigned char data, unsigned int eepromAddress);
unsigned char ReadByte(unsigned char IICSlaveAddress, unsigned int EEPROMAddress);
void WaitForInternalWrite(unsigned char IICSlaveAddress);

#endif