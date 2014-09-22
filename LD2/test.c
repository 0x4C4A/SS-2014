//#include <stdint.h>
#include "stm8s.h"


/* pin defs */
#define LED       0x01 /* PORT D */
#define DC_PIN    0x10 /* PORT C */
#define RESET_PIN 0x04 /* PORT C */


#define SET_DATA    GPIOC->ODR |=  DC_PIN   // Set the LCD for DATA INPUT mode  (set the D/~C pin to HIGH)
#define SET_COMMAND GPIOC->ODR &= ~DC_PIN   // Set the LCD for COMMAND mode   (set the D/~C pin to LOW)
#define SET_RESET   GPIOC->ODR &= ~RESET_PIN 
#define CLR_RESET   GPIOC->ODR |=  RESET_PIN

volatile int16_t signal[64];
volatile uint8_t LCD_RAM[84][6];
volatile uint8_t LCD_X = 0;
volatile uint8_t LCD_Y = 0;
const    uint8_t init_sequence[] = {0x21,   // Switch to extended commands
                                    0xA9,   // Set value of LCD voltage (contrast) 
                                    0x04,   // Set temperature coefficient
                                    0x15,   // Set bias mode to 1:48 (screen is multiplexed that way)
                                    0x20,   // Switch back to regular commands
                                    0x0C,   // Enable normal display (black on white), set to horizontal addressing
                                    0x00};  // End of initialisation sequence

void initLCD(void)
{
  uint8_t x;
  uint8_t i=0;

  SET_RESET;
  for(x=0;x<254;x++);
  CLR_RESET;
  SET_COMMAND;
  for(x=0;x<254;x++);

  while(init_sequence[i] != 0x00){
    while(SPI->SR & 0x80);  /* Wait while SPI is busy transmitting data */
    SPI->DR = init_sequence[i];
    for(x=0;x<254;x++);
    i++;
  }
}

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
  SPI->DR = Y_address&0x7 | 0x40;
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
  CLK->PCKENR1= (1<<1); /* Enable SPI clock */
  CLK->PCKENR2= (1<<3); /* Enable ADC clock */

  /* SPI config */
  SPI->CR1  = (1<<6)|(1<<2)|(0x1<<3);   /* Enable SPI, set to master mode */
  SPI->CR2  = (1<<7)|(1<<6);            /* Transmit only */
  SPI->CR2 |= (1<<0)|(1<<1);

  /* ADC config */
  ADC1->CSR = (0x7<<4); /* Prescaler fmaster/6 */
  ADC1->CR1 = (1<<0); /* Turn ADC on */
  ADC1->CR2 = (1<<3); /* Data aligned to the right */
  initLCD();

  gotoX(0);
  for(j=0;j<253;j++){}
  gotoY(0);
  for(j=0;j<253;j++){}

  for(x=0;x<(84*6);x++){
    writeData(0);
    for(j=0;j<253;j++);
  }

  while(1){
    GPIOD->ODR ^= LED;

    for(i=0;i<32;i++){
      ADC1->CR1 |= (1<<0);  /* initiate conversion */
      while( !(ADC1->CSR & (1<<7)))
      {}
      ADC1->CSR &= ~(1<<7); /* Clear conversion-done flag */
      for(x=0; x<40; x++);
      signal[i] = ADC1->DRL;
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
    for(x=0; x<20000; x++)
      for(i=0; i<20; i++);
  }
}