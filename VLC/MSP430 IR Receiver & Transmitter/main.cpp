//#include <msp430g2553.h>
#include <msp430.h>
#include <stdint.h>

/* Use these defines to flash the correct program version to the correct MCU */
#define TRANSMITTER 0   
#define RECEIVER    1

//------------------------------------------------------------------------------
// Hardware-related definitions
//------------------------------------------------------------------------------
#define UART_TXD   0x02                     // TXD on P1.1 (Timer0_A.OUT0)
#define UART_RXD   0x04                     // RXD on P1.2 (Timer0_A.CCI1A)

//------------------------------------------------------------------------------
// Conditions for 2000 Baud SW UART, SMCLK = 1MHz
//------------------------------------------------------------------------------
#define UART_FREQ           1000    /* 2kHz is a bit overclockish. 1kHz is pretty sure to work */
#define UART_TBIT_DIV_2     (1000000 / (UART_FREQ * 2))
#define UART_TBIT           (1000000 / UART_FREQ)

//------------------------------------------------------------------------------
// Global variables used for full-duplex UART communication
//------------------------------------------------------------------------------
unsigned int txData;                        // UART internal variable for TX
unsigned char rxBuffer;                     // Received UART character
volatile uint8_t catchNextFrame = 0;        // Set after receiving the preamble

void initADC(void)
{
  ADC10CTL0 = ADC10SHT_2 + ADC10ON;         // ADC10ON, interrupt enabled
  ADC10CTL1 = INCH_4;                       // input A4
  ADC10AE0 |= 0x10;                         // PA.4 ADC option select
}

uint16_t convertADCSample(void)
{
    ADC10CTL0 |= ENC + ADC10SC;             // Sampling and conversion start
    while(ADC10CTL1 & ADC10BUSY)
        __delay_cycles(10);
    return ADC10MEM;
}

void TimerA_UART_init(void)
{
    TA0CCTL0 = OUT;                          // Set TXD Idle as Mark = '1'
    TA0CCTL1 = SCS + CM1 + CAP + CCIE;       // Sync, Neg Edge, Capture, Intb
    TA0CTL = TASSEL_2 + MC_2;                // SMCLK, start in continuous mode
}
//------------------------------------------------------------------------------
// Outputs one byte using the Timer_A UART
//------------------------------------------------------------------------------
void TimerA_UART_tx(unsigned char byte)
{
    while (TACCTL0 & CCIE);                 // Ensure last char got TX'd
    TA0CCR0 = TAR;                           // Current state of TA counter
    TA0CCR0 += UART_TBIT;                    // One bit time till first bit
    TA0CCTL0 = OUTMOD0 + CCIE;               // Set TXD on EQU0, Int
    txData = byte;                          // Load global variable
    txData |= 0x100;                        // Add mark stop bit to TXData
    txData <<= 1;                           // Add space start bit
}
uint8_t makeCRC(uint8_t payload)
{
    uint8_t temp = payload & 0x7F;
    uint8_t i = 0;
    while(temp){
        if(temp & 0x01)
            i++;
        temp >>= 1;
    }
    if(i & 0x01)
        payload |= 0x80;
    else
        payload &= ~0x80;

    return payload;
}
uint8_t unmakeCode(uint16_t code)
{
    uint8_t i;
    uint8_t tmp;
    for(i = 0; i < 8; i++){
        tmp <<= 1;
        switch(code & 0x0003){
            case 0x01: tmp |= 0x01; break;
            case 0x02: break;
            default: tmp = 0x1; goto exit;  /* Makes it fail CRC */
        }
        code >>= 2;
    }
exit:
    return tmp;
}

uint16_t makeCode(uint8_t data)
{
    uint16_t i;
    uint16_t tmp;
    data = makeCRC(data);
    for(i = 0; i < 8; i++){
        tmp <<= 2;
        if(data&0x01)
            tmp |= 0x0001;
        else
            tmp |= 0x0002;
        data >>= 1;
    }
    return tmp;
}

uint8_t checkCRC(uint8_t byte)
{
    uint8_t temp = byte & 0x7F;
    uint8_t i = 0;
    while(temp){
        if(temp & 0x01)
            i++;
        temp >>= 1;
    }
    if( !(byte & 0x80) == !(i & 0x1))
        return 1;
    else
        return 0;
}

int main(void)
{
    WDTCTL = WDTPW | WDTHOLD;	// Stop watchdog timer

    DCOCTL = 0x00;                          // Set DCOCLK to 1MHz
	BCSCTL1 = CALBC1_1MHZ;
	DCOCTL = CALDCO_1MHZ;

	P1OUT = 0x00;                           // Initialize all GPIO
	P1SEL = UART_TXD + UART_RXD;            // Timer function for TXD/RXD pins
	P1DIR = 0xFF & ~UART_RXD & ~0x10;       // Set all pins but RXD and A.4 to output
	P2OUT = 0x00;
	P2SEL = 0x00;
	P2DIR = 0xFF;

	__enable_interrupt();

	TimerA_UART_init();
    uint16_t i;
    uint8_t data;
    uint16_t payload;
    #if TRANSMITTER
    initADC();
	while(1){
        __delay_cycles(10000);
		TimerA_UART_tx(0x33); // preamble
        
        payload = makeCode(0x70 + (convertADCSample() >> 6));

        __delay_cycles(10000);
        TimerA_UART_tx( payload & 0xFF ); // payload 1
        
        __delay_cycles(10000);
        TimerA_UART_tx( payload >> 8);  // payload 2
    }
    #elif RECEIVER
    while(1){
        __delay_cycles(2000);
        P2OUT &= ~0x30;
        if(rxBuffer == 0x33 && !catchNextFrame){
            //P2OUT |= 0x20;
            catchNextFrame = 1;
        }
        else if(rxBuffer != 0x33 && catchNextFrame == 1){
            
            payload = rxBuffer;
                
            //P2OUT = (P2OUT & 0xF0) | (rxBuffer & 0x0F);
            
            catchNextFrame = 2;
        }
        else if(rxBuffer != 0x33 && catchNextFrame == 2 && rxBuffer != payload){
             P2OUT |= 0x10;
            payload |= (uint16_t)rxBuffer << 8; 
            data = unmakeCode(payload);
            if(checkCRC(data)){
                P2OUT |= 0x20;
                P2OUT &=~ 0x0F;
                P2OUT |= data & 0x0F;             
            }
            catchNextFrame = 0;
            payload = 0;
        }
        //if(rxBuffer > 0x70)
        //   TimerA_UART_tx(rxBuffer);
    }
    #endif
	return 0;
}

//------------------------------------------------------------------------------
// Timer_A UART - Transmit Interrupt Handler
//------------------------------------------------------------------------------
#pragma vector = TIMER0_A0_VECTOR
__interrupt void Timer_A0_ISR(void)
{
    static unsigned char txBitCnt = 10;

    TACCR0 += UART_TBIT;                    // Add Offset to CCRx
    if (txBitCnt == 0) {                    // All bits TXed?
        TACCTL0 &= ~CCIE;                   // All bits TXed, disable interrupt
        txBitCnt = 10;                      // Re-load bit counter
    }
    else {
        if (txData & 0x01) {
          TACCTL0 &= ~OUTMOD2;              // TX Mark '1'
        }
        else {
          TACCTL0 |= OUTMOD2;               // TX Space '0'
        }
        txData >>= 1;
        txBitCnt--;
    }
}

#pragma vector = TIMER0_A1_VECTOR
__interrupt void Timer_A1_ISR(void)
{
    static unsigned char rxBitCnt = 8;
    static unsigned char rxData = 0;
    P2OUT ^= 0x10;
    if(TA0IV == 0x02){                        // TACCR1 CCIFG - UART RX
        TACCR1 += UART_TBIT;                 // Add Offset to CCRx
        if (TACCTL1 & CAP) {                 // Capture mode = start bit edge
            TACCTL1 &= ~CAP;                 // Switch capture to compare mode
            TACCR1 += UART_TBIT_DIV_2;       // Point CCRx to middle of D0
        }
        else {
            rxData >>= 1;
            if (TACCTL1 & SCCI) {            // Get bit waiting in receive latch
                rxData |= 0x80;
            }
            rxBitCnt--;
            if (rxBitCnt == 0) {             // All bits RXed?
                rxBuffer = rxData;           // Store in global variable
                rxBitCnt = 8;                // Re-load bit counter
                TACCTL1 |= CAP;              // Switch compare to capture mode
                __bic_SR_register_on_exit(LPM0_bits);  // Clear LPM0 bits from 0(SR)
            }
        }
    }
}