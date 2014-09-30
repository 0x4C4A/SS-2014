//#include <stdint.h>
#include "stm8s.h"


/* pin defs */
#define LED       0x01 /* PORT D */
#define DC_PIN    0x10 /* PORT C */
#define RESET_PIN 0x04 /* PORT C */
#define UART_TX_PIN 0x20 /* PORT D */

#define SET_DATA    GPIOC->ODR |=  DC_PIN   // Set the LCD for DATA INPUT mode  (set the D/~C pin to HIGH)
#define SET_COMMAND GPIOC->ODR &= ~DC_PIN   // Set the LCD for COMMAND mode   (set the D/~C pin to LOW)
#define SET_RESET   GPIOC->ODR &= ~RESET_PIN 
#define CLR_RESET   GPIOC->ODR |=  RESET_PIN

volatile int16_t signal[64];
volatile uint8_t LCD_RAM[84][6];
volatile uint8_t LCD_X = 0;
volatile uint8_t LCD_Y = 0;
const    uint8_t init_sequence[] = {0x21,   // Switch to extended commands
                                    0xA7,   // Set value of LCD voltage (contrast) 
                                    0x04,   // Set temperature coefficient
                                    0x15,   // Set bias mode to 1:48 (screen is multiplexed that way)
                                    0x20,   // Switch back to regular commands
                                    0x0C,   // Enable normal display (black on white), set to horizontal addressing
                                    0x00};  // End of initialisation sequence

void gotoX(uint8_t X_address)
{
  LCD_X = X_address;
  while(SPI->SR & 0x80);  /* Wait while SPI is busy transmitting data */
  SET_COMMAND;
  SPI->DR = X_address | 0x80;
}

void gotoY(uint8_t Y_address)
{
  LCD_Y = Y_address;
  while(SPI->SR & 0x80);  /* Wait while SPI is busy transmitting data */
  SET_COMMAND;
  SPI->DR = (Y_address & 0x7) | 0x40;
}

void writeData(uint8_t data)
{
  LCD_RAM[LCD_X++][LCD_Y] = data;
  if(LCD_X>84){
    LCD_X -= 84;
    LCD_Y = LCD_Y + 1;
    if(LCD_Y > 5)
      LCD_Y - 5;
  }
  while(SPI->SR & 0x80);  /* Wait while SPI is busy transmitting data */
  SET_DATA;
  SPI->DR = data;
}

void writeCommand(uint8_t command)
{
  while(SPI->SR & 0x80);  /* Wait while SPI is busy transmitting data */
  SET_COMMAND;
  SPI->DR = command;
}

void initLCD(void)
{
  uint16_t x;
  uint16_t y;
  uint8_t i=0;

  SET_RESET;
  for(x = 0; x < 254; x++);
  CLR_RESET;
  SET_COMMAND;
  for(x = 0; x < 254; x++);

  for(i = 0; init_sequence[i] != 0x00; i++){
    writeCommand(init_sequence[i]);
  }

  for(x = 0; x < 254; x++);

  /* Clear screen */
  for(y = 0; y < 6; y++){
    gotoY(y);
    gotoX(0);

    for(x = 0; x < 84; x++){
      writeData(0);
    }
  }
}





uint32_t adcToLCD(uint16_t value)
{
  return (uint32_t)1<<((value>>0)&0x1F);
}

// WORKS ONLY WITH 2^N LONG SIGNALS!!!!
uint16_t FWHT( int16_t signal_arr[64])
{
  uint8_t stages = 5;
  uint8_t tempstage, i, k, half, id; 
  uint8_t block_amount;
  int16_t upper, downer;
  
  for(tempstage = stages; tempstage>0; tempstage--){
    half = 1 << (tempstage - 1);            // Half of the block length   
    block_amount = 1<<(stages - tempstage); // The amount of blocks
    for(k=0; k<block_amount; k++)
      for(i=0; i<half; i++){
        id = i + k*half*2;
        upper  = signal_arr[id];
        downer = signal_arr[id+half];
        signal_arr[id] = upper + downer;
        signal_arr[id+half] = upper - downer;
      }
  }
  return 0;
}

uint16_t binRev(uint16_t num, uint8_t length)
{
  uint16_t rev_num = 0, count = length;
  while(num){
    rev_num <<= 1;
    rev_num  |= num & 0x01;
    num >>= 1;
    count--;
  }
  return rev_num << count;
}

// Converts regular number to it's correlating Gray code value
uint16_t binToGray(uint16_t num)
{
  return (num >> 1) ^ num;
}

// For rearranging coefficients from the Hadamar order to the Walsh order
uint16_t HadamardToWalsh(uint16_t num, uint8_t length)
{
  return binToGray(binRev(num, length));
}

int main(void){
  uint32_t data;
  uint16_t x = 0, j = 0, i = 0;
  uint8_t  PW = 0;

  /* GPIO config */
  GPIOD->DDR |= LED;	  /* Pin directions */
  GPIOD->CR1 |= LED;    /* Set pin to high speed push-pull */
  GPIOD->CR2 |= LED;
  GPIOC->DDR |= (1<<6)|(1<<5)|DC_PIN|RESET_PIN;  /* SPI MOSI and SPI CLK */
  GPIOC->CR1 |= (1<<6)|(1<<5)|DC_PIN|RESET_PIN;  /* Fast push pull for quick SPI transmissions */
  GPIOC->CR2 |= (1<<6)|(1<<5)|DC_PIN|RESET_PIN;

  
  /* CLK config */
  CLK->SWCR  |= 1<<1;	  /* Enable clock source switch */
  CLK->SWR  	= 0xE1;	  /* Switch to high speed internal clock */
  CLK->CKDIVR = 0x00;	  /* Set CPU and HSI prescalers to 1 */
  CLK->ICKR  |= 1<<3;   /* Enable low speed oscillator */
  CLK->PCKENR1= (1<<1)|(1<<3); /* Enable SPI, UART clock */
  CLK->PCKENR2= (1<<3); /* Enable ADC clock */

  /* SPI config */
  SPI->CR1  = (1<<6)|(1<<2)|(0x3<<3);   /* Enable SPI, set to master mode */
  SPI->CR2  = (1<<7)|(1<<6);            /* Transmit only */
  SPI->CR2 |= (1<<0)|(1<<1);

  /* ADC config */
  ADC1->CSR = (0x7<<4); /* Prescaler fmaster/6 */
  ADC1->CR1 = (1<<0); /* Turn ADC on */
  ADC1->CR2 = 0;//(1<<3); /* Data aligned to the right */
  initLCD();

  /* UART config */
  UART1->CR2  = 0x00;
  UART1->BRR2 = 0x0B;  /* BRR2 must be coded first */
  UART1->BRR1 = 0x08;  /* 0x0693 -> 9600 baud, referenc manual figure 119. */
  UART1->CR1  = 0x00;
  UART1->CR3  = 0x2<<4;
  UART1->CR2  = 0x08;  /* Enable transmitter */

  /* BEEP config */
  /*FLASH->CR2 |=  (1<<7);
  FLASH->NCR2&=~ (1<<7);
  OPT->OPT4  =  (1<<2);
  OPT->NOPT4 = ~(1<<2);
  i=255;
  while( !(FLASH->IAPSR & ((1<<2)|(1<<6))) ) 
    ;
  FLASH->CR2 &= ~(1<<7);
  FLASH->NCR2|=  (1<<7);

  BEEP->CSR = 0;
  BEEP->CSR = (0x1<<6);
  BEEP->CSR |= (1<<5);*/

  while(1){
    if( !(GPIOB->IDR & 0x80) ){
      GPIOD->ODR &= ~LED;
      //j = 1;
    }
    else 
      GPIOD->ODR |=  LED;
    
    //if( GPIOB->IDR & 0x80 )
    //  j = 0;

    
    for(i=0;i<32;i++){
      ADC1->CR1 |= (1<<0);  /* initiate conversion */
      while( !(ADC1->CSR & (1<<7)))
      {}
      ADC1->CSR &= ~(1<<7); /* Clear conversion-done flag */
      for(x=0; x<400; x++);
      signal[i] = ADC1->DRH;
      signal[i+32] = signal[i];
    }

    FWHT(signal);

    for(i=0; i<64; i++){
      data = adcToLCD(signal[i]);
      
      gotoX(i);
      gotoY(1);
      writeData( data & 0xFF );

      gotoX(i);
      gotoY(2);
      writeData( (data>>8)  & 0xFF);

      gotoX(i);
      gotoY(3);
      writeData( (data>>16) & 0xFF);

      gotoX(i);
      gotoY(4);
      writeData( data>>24 );
    }

    if(!(GPIOD->ODR & LED))
      for(i=0; i<64; i++){

        //j = (i<32) ? HadamardToWalsh(i,5) : i;
        j = i;
        while( !(UART1->SR & (1<<7)) )
        {}
        UART1->DR = signal[j] & 0xFF;
        while( !(UART1->SR & (1<<7)) )
        {}
        UART1->DR = (signal[j]>>8) & 0xFF;
      }    

    //for(x=0; x<20000; x++)
    //  for(i=0; i<20; i++);
  }
}