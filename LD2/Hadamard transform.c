#include <stdio.h>
#include <stdint.h>

// Reverses the bits of a number (1101 -> 1011; 1010 -> 0101 etc.)
// num - the number to be converted
// length - the amount of bits in the number
uint16_t binRev( uint16_t num, uint8_t length )
{
  uint16_t rev_num = 0, count = length;

  while(num){
    rev_num  |= num & 0x01;
    rev_num <<= 1;
    num >>= 1;
    count--;
  }

  return rev_num << count;
}

// Converts regular number to it's correlating Gray code value
uint16_t binToGray( uint16_t num )
{
  return (num >> 1) ^ num;
}

// For rearranging coefficients from the Hadamar order to the Walsh order
uint16_t HadamarToWalsh( uint16_t num, uint8_t length )
{
  return binToGray(binRev(num, length));
}

int main(void)
{
  int8_t is[4] = {0, 1, 2, 5};
  int8_t iresult[4] = {0};
  int8_t result[4] = {0};
  int8_t f[4][4] = {  1,  1,  1,  1,
                      1,  1, -1, -1,
                      1, -1, -1,  1,
                      1, -1,  1, -1};
  int8_t i, j;
  int8_t out_s[4] = {0};
  
  iresult[0] =  is[0] + is[2];
  iresult[1] =  is[1] + is[3];
  iresult[2] = -is[2] + is[0];
  iresult[3] = -is[3] + is[1];
  
  result[HadamarToWalsh(0, 2)] =  iresult[0] + iresult[1];
  result[HadamarToWalsh(1, 2)] = -iresult[1] + iresult[0];
  result[HadamarToWalsh(2, 2)] =  iresult[2] + iresult[3];
  result[HadamarToWalsh(3, 2)] = -iresult[3] + iresult[2];

  printf("k   %d, %d, %d, %d\n", result[0],result[1],result[2],result[3]);
  
  for(i=0; i<4; i++){
    for(j=0; j<4; j++)
      out_s[i] += result[j]*f[i][j];
    out_s[i] /= 4;
  }

  printf("out %d, %d, %d, %d\n", out_s[0], out_s[1], out_s[2], out_s[3]);
  return;
}

