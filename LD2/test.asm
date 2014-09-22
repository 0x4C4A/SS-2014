;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.0 #8981 (Apr  5 2014) (Linux)
; This file was generated Tue Sep 23 01:16:16 2014
;--------------------------------------------------------
	.module test
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _init_sequence
	.globl _main
	.globl _HadamardToWalsh
	.globl _binToGray
	.globl _binRev
	.globl _FWHT
	.globl _adcToLCD
	.globl _writeData
	.globl _gotoY
	.globl _gotoX
	.globl _initLCD
	.globl _LCD_Y
	.globl _LCD_X
	.globl _LCD_RAM
	.globl _signal
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area DATA
_signal::
	.ds 128
_LCD_RAM::
	.ds 504
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area INITIALIZED
_LCD_X::
	.ds 1
_LCD_Y::
	.ds 1
;--------------------------------------------------------
; Stack segment in internal ram 
;--------------------------------------------------------
	.area	SSEG
__start__stack:
	.ds	1

;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area DABS (ABS)
;--------------------------------------------------------
; interrupt vector 
;--------------------------------------------------------
	.area HOME
__interrupt_vect:
	int s_GSINIT ;reset
	int 0x0000 ;trap
	int 0x0000 ;int0
	int 0x0000 ;int1
	int 0x0000 ;int2
	int 0x0000 ;int3
	int 0x0000 ;int4
	int 0x0000 ;int5
	int 0x0000 ;int6
	int 0x0000 ;int7
	int 0x0000 ;int8
	int 0x0000 ;int9
	int 0x0000 ;int10
	int 0x0000 ;int11
	int 0x0000 ;int12
	int 0x0000 ;int13
	int 0x0000 ;int14
	int 0x0000 ;int15
	int 0x0000 ;int16
	int 0x0000 ;int17
	int 0x0000 ;int18
	int 0x0000 ;int19
	int 0x0000 ;int20
	int 0x0000 ;int21
	int 0x0000 ;int22
	int 0x0000 ;int23
	int 0x0000 ;int24
	int 0x0000 ;int25
	int 0x0000 ;int26
	int 0x0000 ;int27
	int 0x0000 ;int28
	int 0x0000 ;int29
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area HOME
	.area GSINIT
	.area GSFINAL
	.area GSINIT
__sdcc_gs_init_startup:
__sdcc_init_data:
; stm8_genXINIT() start
	ldw x, #l_DATA
	jreq	00002$
00001$:
	clr (s_DATA - 1, x)
	decw x
	jrne	00001$
00002$:
	ldw	x, #l_INITIALIZER
	jreq	00004$
00003$:
	ld	a, (s_INITIALIZER - 1, x)
	ld	(s_INITIALIZED - 1, x), a
	decw	x
	jrne	00003$
00004$:
; stm8_genXINIT() end
	.area GSFINAL
	jp	__sdcc_program_startup
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area HOME
	.area HOME
__sdcc_program_startup:
	jp	_main
;	return from main will return to caller
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area CODE
;	test.c: 28: void initLCD(void)
;	-----------------------------------------
;	 function initLCD
;	-----------------------------------------
_initLCD:
	sub	sp, #3
;	test.c: 33: SET_RESET;
	ldw	x, #0x500a
	ld	a, (x)
	and	a, #0xfb
	ld	(x), a
;	test.c: 34: for(x=0;x<254;x++);
	ld	a, #0xfe
00112$:
	dec	a
	tnz	a
	jrne	00112$
;	test.c: 35: CLR_RESET;
	ldw	x, #0x500a
	ld	a, (x)
	or	a, #0x04
	ld	(x), a
;	test.c: 36: SET_COMMAND;
	ldw	x, #0x500a
	ld	a, (x)
	and	a, #0xef
	ld	(x), a
;	test.c: 37: for(x=0;x<254;x++);
	ld	a, #0xfe
00115$:
	dec	a
	tnz	a
	jrne	00115$
;	test.c: 39: while(init_sequence[i] != 0x00){
	ldw	x, #_init_sequence+0
	ldw	(0x02, sp), x
	clr	(0x01, sp)
00107$:
	clrw	x
	ld	a, (0x01, sp)
	ld	xl, a
	addw	x, (0x02, sp)
	ld	a, (x)
	tnz	a
	jreq	00119$
;	test.c: 40: while(SPI->SR & 0x80);  /* Wait while SPI is busy transmitting data */
00103$:
	ldw	y, #0x5203
	ld	a, (y)
	sll	a
	jrc	00103$
;	test.c: 41: SPI->DR = init_sequence[i];
	ld	a, (x)
	ldw	x, #0x5204
	ld	(x), a
;	test.c: 42: for(x=0;x<254;x++);
	ld	a, #0xfe
00118$:
	dec	a
	tnz	a
	jrne	00118$
;	test.c: 43: i++;
	inc	(0x01, sp)
	jra	00107$
00119$:
	addw	sp, #3
	ret
;	test.c: 47: void gotoX(uint8_t X_address)
;	-----------------------------------------
;	 function gotoX
;	-----------------------------------------
_gotoX:
;	test.c: 49: LCD_X = X_address;
	ld	a, (0x03, sp)
	ld	_LCD_X+0, a
;	test.c: 50: while(SPI->SR & 0x80);  /* Wait while SPI is busy transmitting data */
00101$:
	ldw	x, #0x5203
	ld	a, (x)
	sll	a
	jrc	00101$
;	test.c: 51: SET_COMMAND;
	ldw	x, #0x500a
	ld	a, (x)
	and	a, #0xef
	ld	(x), a
;	test.c: 52: SPI->DR = X_address | 0x80;
	ld	a, (0x03, sp)
	or	a, #0x80
	ldw	x, #0x5204
	ld	(x), a
	ret
;	test.c: 55: void gotoY(uint8_t Y_address)
;	-----------------------------------------
;	 function gotoY
;	-----------------------------------------
_gotoY:
;	test.c: 57: LCD_Y = Y_address;
	ld	a, (0x03, sp)
	ld	_LCD_Y+0, a
;	test.c: 58: while(SPI->SR & 0x80);  /* Wait while SPI is busy transmitting data */
00101$:
	ldw	x, #0x5203
	ld	a, (x)
	sll	a
	jrc	00101$
;	test.c: 59: SET_COMMAND;
	ldw	x, #0x500a
	ld	a, (x)
	and	a, #0xef
	ld	(x), a
;	test.c: 60: SPI->DR = Y_address&0x7 | 0x40;
	ld	a, (0x03, sp)
	and	a, #0x07
	or	a, #0x40
	ldw	x, #0x5204
	ld	(x), a
	ret
;	test.c: 63: void writeData(uint8_t data)
;	-----------------------------------------
;	 function writeData
;	-----------------------------------------
_writeData:
	sub	sp, #4
;	test.c: 65: LCD_RAM[LCD_X++][LCD_Y] = data;
	ldw	x, #_LCD_RAM+0
	ldw	(0x03, sp), x
	ld	a, _LCD_X+0
	ld	xl, a
	inc	_LCD_X+0
	ld	a, #0x06
	mul	x, a
	addw	x, (0x03, sp)
	ldw	(0x01, sp), x
	ld	a, _LCD_Y+0
	clrw	x
	ld	xl, a
	addw	x, (0x01, sp)
	ld	a, (0x07, sp)
	ld	(x), a
;	test.c: 66: if(LCD_X>84){
	ld	a, _LCD_X+0
	cp	a, #0x54
	jrule	00105$
;	test.c: 67: LCD_X -= 84;
	ld	a, _LCD_X+0
	sub	a, #0x54
	ld	_LCD_X+0, a
;	test.c: 68: LCD_Y = LCD_Y + 1;
	inc	_LCD_Y+0
;	test.c: 69: if(LCD_Y > 5)
	ld	a, _LCD_Y+0
	cp	a, #0x05
	jrule	00105$
;	test.c: 70: LCD_Y - 5;
	ld	a, _LCD_Y+0
;	test.c: 72: while(SPI->SR & 0x80);  /* Wait while SPI is busy transmitting data */
00105$:
	ldw	x, #0x5203
	ld	a, (x)
	sll	a
	jrc	00105$
;	test.c: 73: SET_DATA;
	ldw	x, #0x500a
	ld	a, (x)
	or	a, #0x10
	ld	(x), a
;	test.c: 74: SPI->DR = data;
	ldw	x, #0x5204
	ld	a, (0x07, sp)
	ld	(x), a
	addw	sp, #4
	ret
;	test.c: 77: uint32_t adcToLCD(uint16_t value)
;	-----------------------------------------
;	 function adcToLCD
;	-----------------------------------------
_adcToLCD:
	sub	sp, #2
;	test.c: 79: return (uint32_t)1<<((value>>0)&0x1F);
	ldw	x, (0x05, sp)
	ld	a, xl
	and	a, #0x1f
	ld	(0x02, sp), a
	clr	a
	ldw	x, #0x0001
	clrw	y
	ld	a, (0x02, sp)
	tnz	a
	jreq	00104$
00103$:
	sllw	x
	rlcw	y
	dec	a
	jrne	00103$
00104$:
	addw	sp, #2
	ret
;	test.c: 83: uint16_t FWHT( int16_t signal_arr[64])
;	-----------------------------------------
;	 function FWHT
;	-----------------------------------------
_FWHT:
	sub	sp, #17
;	test.c: 90: for(tempstage = stages; tempstage>0; tempstage--){
	ld	a, #0x05
	ld	(0x09, sp), a
00111$:
	tnz	(0x09, sp)
	jrne	00144$
	jp	00103$
00144$:
;	test.c: 91: half = 1 << (tempstage - 1);            // Half of the block length   
	ld	a, (0x09, sp)
	dec	a
	ld	(0x0e, sp), a
	ld	a, #0x01
	ld	(0x07, sp), a
	ld	a, (0x0e, sp)
	tnz	a
	jreq	00146$
00145$:
	sll	(0x07, sp)
	dec	a
	jrne	00145$
00146$:
;	test.c: 92: block_amount = 1<<(stages - tempstage); // The amount of blocks
	ld	a, #0x05
	sub	a, (0x09, sp)
	ld	xh, a
	ld	a, #0x01
	ld	(0x05, sp), a
	ld	a, xh
	tnz	a
	jreq	00148$
00147$:
	sll	(0x05, sp)
	dec	a
	jrne	00147$
00148$:
;	test.c: 93: for(k=0; k<block_amount; k++)
	clr	(0x08, sp)
00108$:
	ld	a, (0x08, sp)
	cp	a, (0x05, sp)
	jrnc	00112$
;	test.c: 94: for(i=0; i<half; i++){
	ld	a, (0x08, sp)
	ld	xl, a
	ld	a, (0x07, sp)
	mul	x, a
	ld	a, xl
	sll	a
	ld	(0x0f, sp), a
	clr	a
00105$:
	cp	a, (0x07, sp)
	jrnc	00109$
;	test.c: 95: id = i + k*half*2;
	push	a
	ld	a, (1, sp)
	add	a, (0x10, sp)
	ld	(0x07, sp), a
	ld	a, (0x07, sp)
	ld	(0x0e, sp), a
	pop	a
	clr	(0x0c, sp)
	ldw	y, (0x0c, sp)
	sllw	y
	addw	y, (0x14, sp)
	ldw	x, y
	ldw	x, (x)
	ldw	(0x03, sp), x
;	test.c: 97: downer = signal_arr[id+half];
	push	a
	ld	a, (0x08, sp)
	ld	(0x0c, sp), a
	pop	a
	clr	(0x0a, sp)
	ldw	x, (0x0c, sp)
	addw	x, (0x0a, sp)
	sllw	x
	addw	x, (0x14, sp)
	ldw	(0x10, sp), x
	ldw	x, (0x10, sp)
	ldw	x, (x)
	ldw	(0x01, sp), x
;	test.c: 98: signal_arr[id] = upper + downer;
	ldw	x, (0x03, sp)
	addw	x, (0x01, sp)
	ldw	(y), x
;	test.c: 99: signal_arr[id+half] = upper - downer;
	ldw	y, (0x03, sp)
	subw	y, (0x01, sp)
	ldw	x, (0x10, sp)
	ldw	(x), y
;	test.c: 94: for(i=0; i<half; i++){
	inc	a
	jra	00105$
00109$:
;	test.c: 93: for(k=0; k<block_amount; k++)
	inc	(0x08, sp)
	jra	00108$
00112$:
;	test.c: 90: for(tempstage = stages; tempstage>0; tempstage--){
	ld	a, (0x0e, sp)
	ld	(0x09, sp), a
	jp	00111$
00103$:
;	test.c: 102: return 0;
	clrw	x
	addw	sp, #17
	ret
;	test.c: 105: uint16_t binRev(uint16_t num, uint8_t length)
;	-----------------------------------------
;	 function binRev
;	-----------------------------------------
_binRev:
	sub	sp, #6
;	test.c: 107: uint16_t rev_num = 0, count = length;
	clrw	x
	ld	a, (0x0b, sp)
	clr	(0x01, sp)
;	test.c: 108: while(num){
	ld	(0x06, sp), a
	ld	a, (0x01, sp)
	ld	(0x05, sp), a
00101$:
	ldw	y, (0x09, sp)
	jreq	00103$
;	test.c: 109: rev_num <<= 1;
	sllw	x
;	test.c: 110: rev_num  |= num & 0x01;
	ld	a, (0x0a, sp)
	and	a, #0x01
	ld	(0x04, sp), a
	clr	a
	pushw	x
	or	a, (1, sp)
	popw	x
	ld	xh, a
	ld	a, xl
	or	a, (0x04, sp)
	ld	xl, a
;	test.c: 111: num >>= 1;
	ldw	y, (0x09, sp)
	srlw	y
	ldw	(0x09, sp), y
;	test.c: 112: count--;
	ldw	y, (0x05, sp)
	decw	y
	ldw	(0x05, sp), y
	jra	00101$
00103$:
;	test.c: 114: return rev_num << count;
	ld	a, (0x06, sp)
	tnz	a
	jreq	00117$
00116$:
	sllw	x
	dec	a
	jrne	00116$
00117$:
	addw	sp, #6
	ret
;	test.c: 118: uint16_t binToGray(uint16_t num)
;	-----------------------------------------
;	 function binToGray
;	-----------------------------------------
_binToGray:
;	test.c: 120: return (num >> 1) ^ num;
	ldw	x, (0x03, sp)
	srlw	x
	ld	a, xl
	xor	a, (0x04, sp)
	ld	xl, a
	ld	a, xh
	xor	a, (0x03, sp)
	ld	xh, a
	ret
;	test.c: 124: uint16_t HadamardToWalsh(uint16_t num, uint8_t length)
;	-----------------------------------------
;	 function HadamardToWalsh
;	-----------------------------------------
_HadamardToWalsh:
;	test.c: 126: return binToGray(binRev(num, length));
	ld	a, (0x05, sp)
	push	a
	ldw	x, (0x04, sp)
	pushw	x
	call	_binRev
	addw	sp, #3
	pushw	x
	call	_binToGray
	addw	sp, #2
	ret
;	test.c: 129: int main(void){
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
	sub	sp, #41
;	test.c: 135: GPIOD->DDR |= LED;	  /* Pin directions */
	bset	0x5011, #0
;	test.c: 136: GPIOD->CR1 |= LED;    /* Set pin to high speed push-pull */
	bset	0x5012, #0
;	test.c: 137: GPIOD->CR2 |= LED;
	bset	0x5013, #0
;	test.c: 138: GPIOC->DDR |= (1<<6)|(1<<5)|DC_PIN|RESET_PIN;  /* SPI MOSI and SPI CLK */
	ldw	x, #0x500c
	ld	a, (x)
	or	a, #0x74
	ld	(x), a
;	test.c: 139: GPIOC->CR1 |= (1<<6)|(1<<5)|DC_PIN|RESET_PIN;  /* Fast push pull for quick SPI transmissions */
	ldw	x, #0x500d
	ld	a, (x)
	or	a, #0x74
	ld	(x), a
;	test.c: 140: GPIOC->CR2 |= (1<<6)|(1<<5)|DC_PIN|RESET_PIN;
	ldw	x, #0x500e
	ld	a, (x)
	or	a, #0x74
	ld	(x), a
;	test.c: 144: CLK->SWCR  |= 1<<1;	  /* Enable clock source switch */
	ldw	x, #0x50c5
	ld	a, (x)
	or	a, #0x02
	ld	(x), a
;	test.c: 145: CLK->SWR  	= 0xE1;	  /* Switch to high speed internal clock */
	ldw	x, #0x50c4
	ld	a, #0xe1
	ld	(x), a
;	test.c: 146: CLK->CKDIVR = 0x00;	  /* Set CPU and HSI prescalers to 1 */
	ldw	x, #0x50c6
	clr	(x)
;	test.c: 147: CLK->PCKENR1= (1<<1); /* Enable SPI clock */
	ldw	x, #0x50c7
	ld	a, #0x02
	ld	(x), a
;	test.c: 148: CLK->PCKENR2= (1<<3); /* Enable ADC clock */
	ldw	x, #0x50ca
	ld	a, #0x08
	ld	(x), a
;	test.c: 151: SPI->CR1  = (1<<6)|(1<<2)|(0x1<<3);   /* Enable SPI, set to master mode */
	ldw	x, #0x5200
	ld	a, #0x4c
	ld	(x), a
;	test.c: 152: SPI->CR2  = (1<<7)|(1<<6);            /* Transmit only */
	ldw	x, #0x5201
	ld	a, #0xc0
	ld	(x), a
;	test.c: 153: SPI->CR2 |= (1<<0)|(1<<1);
	ldw	x, #0x5201
	ld	a, (x)
	or	a, #0x03
	ld	(x), a
;	test.c: 156: ADC1->CSR = (0x7<<4); /* Prescaler fmaster/6 */
	ldw	x, #0x5400
	ld	a, #0x70
	ld	(x), a
;	test.c: 157: ADC1->CR1 = (1<<0); /* Turn ADC on */
	ldw	x, #0x5401
	ld	a, #0x01
	ld	(x), a
;	test.c: 158: ADC1->CR2 = (1<<3); /* Data aligned to the right */
	ldw	x, #0x5402
	ld	a, #0x08
	ld	(x), a
;	test.c: 159: initLCD();
	call	_initLCD
;	test.c: 161: gotoX(0);
	push	#0x00
	call	_gotoX
	pop	a
;	test.c: 162: for(j=0;j<253;j++){}
	ldw	x, #0x00fd
00118$:
	decw	x
	tnzw	x
	jrne	00118$
;	test.c: 163: gotoY(0);
	push	#0x00
	call	_gotoY
	pop	a
;	test.c: 164: for(j=0;j<253;j++){}
	ldw	x, #0x00fd
00121$:
	decw	x
	tnzw	x
	jrne	00121$
;	test.c: 166: for(x=0;x<(84*6);x++){
	clrw	x
00125$:
;	test.c: 167: writeData(0);
	pushw	x
	push	#0x00
	call	_writeData
	pop	a
	popw	x
;	test.c: 168: for(j=0;j<253;j++);
	ldw	y, #0x00fd
00124$:
	decw	y
	tnzw	y
	jrne	00124$
;	test.c: 166: for(x=0;x<(84*6);x++){
	incw	x
	cpw	x, #0x01f8
	jrc	00125$
;	test.c: 171: while(1){
00114$:
;	test.c: 172: GPIOD->ODR ^= LED;
	ldw	x, #0x500f
	ld	a, (x)
	xor	a, #0x01
	ld	(x), a
;	test.c: 174: for(i=0;i<32;i++){
	clrw	x
	ldw	(0x01, sp), x
00130$:
;	test.c: 175: ADC1->CR1 |= (1<<0);  /* initiate conversion */
	bset	0x5401, #0
;	test.c: 176: while( !(ADC1->CSR & (1<<7)))
00105$:
	ldw	x, #0x5400
	ld	a, (x)
	sll	a
	jrnc	00105$
;	test.c: 178: ADC1->CSR &= ~(1<<7); /* Clear conversion-done flag */
	bres	0x5400, #7
;	test.c: 179: for(x=0; x<40; x++);
	ldw	x, #0x0028
00129$:
	decw	x
	tnzw	x
	jrne	00129$
;	test.c: 180: signal[i] = ADC1->DRL;
	ldw	y, #_signal+0
	ldw	x, (0x01, sp)
	sllw	x
	ldw	(0x23, sp), x
	addw	y, (0x23, sp)
	ldw	x, #0x5405
	ld	a, (x)
	clrw	x
	ld	xl, a
	ldw	(y), x
;	test.c: 181: signal[i+32] = signal[i];
	ldw	y, #_signal+0
	ld	a, (0x02, sp)
	ld	(0x0b, sp), a
	ld	a, (0x0b, sp)
	add	a, #0x20
	clrw	x
	ld	xl, a
	sllw	x
	ldw	(0x0e, sp), x
	addw	y, (0x0e, sp)
	ldw	x, #_signal+0
	addw	x, (0x23, sp)
	ldw	x, (x)
	ldw	(y), x
;	test.c: 174: for(i=0;i<32;i++){
	ldw	x, (0x01, sp)
	incw	x
	ldw	(0x01, sp), x
	ldw	x, (0x01, sp)
	cpw	x, #0x0020
	jrc	00130$
;	test.c: 184: FWHT(signal);
	ldw	x, #_signal+0
	pushw	x
	call	_FWHT
	addw	sp, #2
;	test.c: 186: for(i=0; i<64; i++){
	clrw	x
	ldw	(0x01, sp), x
00132$:
;	test.c: 187: data = adcToLCD(signal[i]);
	ldw	x, #_signal+0
	ldw	(0x0c, sp), x
	ldw	x, (0x01, sp)
	sllw	x
	addw	x, (0x0c, sp)
	ldw	x, (x)
	pushw	x
	call	_adcToLCD
	addw	sp, #2
	ldw	(0x05, sp), x
	ldw	(0x03, sp), y
;	test.c: 189: gotoX(i);
	ld	a, (0x02, sp)
	ld	(0x29, sp), a
	ld	a, (0x29, sp)
	push	a
	call	_gotoX
	pop	a
;	test.c: 190: gotoY(1);
	push	#0x01
	call	_gotoY
	pop	a
;	test.c: 191: writeData( data & 0xFF );
	ld	a, (0x06, sp)
	ld	xh, a
	clr	(0x27, sp)
	clr	(0x26, sp)
	clr	a
	ld	a, xh
	push	a
	call	_writeData
	pop	a
;	test.c: 193: gotoX(i);
	ld	a, (0x29, sp)
	push	a
	call	_gotoX
	pop	a
;	test.c: 194: gotoY(2);
	push	#0x02
	call	_gotoY
	pop	a
;	test.c: 195: writeData( (data>>8)  & 0xFF);
	ldw	y, (0x04, sp)
	ldw	(0x09, sp), y
	ld	a, (0x03, sp)
	ld	(0x08, sp), a
	clr	a
	ld	xh, a
	ldw	y, (0x08, sp)
	ldw	(0x08, sp), y
	ld	a, (0x0a, sp)
	ld	(0x14, sp), a
	clr	(0x13, sp)
	clr	(0x12, sp)
	clr	(0x11, sp)
	ld	a, (0x14, sp)
	ld	(0x10, sp), a
	ld	a, (0x10, sp)
	push	a
	call	_writeData
	pop	a
;	test.c: 197: gotoX(i);
	ld	a, (0x29, sp)
	push	a
	call	_gotoX
	pop	a
;	test.c: 198: gotoY(3);
	push	#0x03
	call	_gotoY
	pop	a
;	test.c: 199: writeData( (data>>16) & 0xFF);
	ldw	y, (0x03, sp)
	ldw	(0x21, sp), y
	clr	(0x20, sp)
	clr	a
	ld	xh, a
	ldw	y, (0x20, sp)
	ldw	(0x20, sp), y
	ld	a, (0x22, sp)
	ld	(0x1e, sp), a
	clr	(0x1d, sp)
	clr	(0x1c, sp)
	clr	(0x1b, sp)
	ld	a, (0x1e, sp)
	ld	(0x1a, sp), a
	ld	a, (0x1a, sp)
	push	a
	call	_writeData
	pop	a
;	test.c: 201: gotoX(i);
	ld	a, (0x29, sp)
	push	a
	call	_gotoX
	pop	a
;	test.c: 202: gotoY(4);
	push	#0x04
	call	_gotoY
	pop	a
;	test.c: 203: writeData( data>>24 );
	ld	a, (0x03, sp)
	ld	(0x19, sp), a
	clr	(0x18, sp)
	clr	(0x17, sp)
	clr	(0x16, sp)
	ldw	y, (0x17, sp)
	ldw	(0x17, sp), y
	ld	a, (0x19, sp)
	ld	(0x15, sp), a
	ld	a, (0x15, sp)
	push	a
	call	_writeData
	pop	a
;	test.c: 186: for(i=0; i<64; i++){
	ldw	x, (0x01, sp)
	incw	x
	ldw	(0x01, sp), x
	ldw	x, (0x01, sp)
	cpw	x, #0x0040
	jrnc	00237$
	jp	00132$
00237$:
;	test.c: 205: for(x=0; x<20000; x++)
	clrw	y
;	test.c: 206: for(i=0; i<20; i++);
00156$:
	ldw	x, #0x0014
00136$:
	decw	x
	tnzw	x
	jrne	00136$
;	test.c: 205: for(x=0; x<20000; x++)
	incw	y
	cpw	y, #0x4e20
	jrc	00156$
	jp	00114$
	addw	sp, #41
	ret
	.area CODE
_init_sequence:
	.db #0x21	; 33
	.db #0xA9	; 169
	.db #0x04	; 4
	.db #0x15	; 21
	.db #0x20	; 32
	.db #0x0C	; 12
	.db #0x00	; 0
	.area INITIALIZER
__xinit__LCD_X:
	.db #0x00	; 0
__xinit__LCD_Y:
	.db #0x00	; 0
	.area CABS (ABS)
