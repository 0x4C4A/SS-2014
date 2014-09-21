#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

// Reverses the bits of a number (1101 -> 1011; 1010 -> 0101 etc.)
// num - the number to be converted
// length - the amount of bits in the number
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
uint16_t HadamarToWalsh(uint16_t num, uint8_t length)
{
  return binToGray(binRev(num, length));
}

// Create a Hadamar matrix
int8_t **HadamarMatrix(uint16_t order)
{
  int8_t **matrix = calloc(1<<order, sizeof(int8_t*));
  uint8_t i, stage, block_size, block_edge, x, y;
  for(i = 0; i<(1<<order); i++)
    matrix[i] = calloc(1<<order, sizeof(int8_t));
  matrix[0][0] = 1;
  for(stage = 0; stage<order; stage++){
    block_edge = (1<<stage);
    for(x = 0; x<block_edge; x++)
      for(y = 0; y<block_edge; y++){
        matrix[x+block_edge][y] = matrix[x][y];
        matrix[x][y+block_edge] = matrix[x][y];
        matrix[x+block_edge][y+block_edge] = -matrix[x][y]; 
      }
  }
  return matrix;
}

// Free a Hadamar Matrix memory
void freeHadamarMatrix(int8_t **matrix, uint16_t block_edge)
{
  uint16_t x;
  for(x = 0; x<block_edge; x++)
    free(matrix[x]);
  free(matrix);
}


// WORKS ONLY WITH 2^N LONG SIGNALS!!!!
uint16_t FWHT( int16_t *signal_arr, uint16_t signal_length)
{
  uint8_t stages = 0;
  signal_length--;
  while( signal_length ){
    stages++;
    signal_length >>= 1;
  }

  int16_t tempstage, i, k, half, id, upper, downer;
  int16_t block_amount;
  for(tempstage = stages; tempstage>0; tempstage--){
      half = 1 << (tempstage - 1);            // Half of the block length   
      block_amount = 1<<(stages - tempstage); // The amount of blocks
      printf("Half: %d, block_amount: %d\n", half, block_amount);
      for(k=0; k<block_amount; k++){
        for(i=0; i<half; i++){
          id = i + k*half*2;
          upper  = signal_arr[id];
          downer = signal_arr[id+half];
          printf("upper: %d, downer: %d, id: %d\n", upper, downer, id);
          int8_t iter;
          signal_arr[id] = upper + downer;
          signal_arr[id+half] = upper - downer;
        }
        int8_t iter;
        for(iter = 0; iter<(4); iter++)
          printf("% 2d", signal_arr[iter]);
        printf("\n");
      }
   }
   return 0;
}

int main(void)
{
  int16_t is[4] = {0, 1, 2, 5};
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
  
  result[0] =  iresult[0] + iresult[1];
  result[1] = -iresult[1] + iresult[0];
  result[2] =  iresult[2] + iresult[3];
  result[3] = -iresult[3] + iresult[2];

  printf("k   %d, %d, %d, %d\n", result[0],result[1],result[2],result[3]);
  
  for(i=0; i<4; i++){
    for(j=0; j<4; j++)
      out_s[i] += result[j]*f[i][j];
    out_s[i] /= 4;
  }

  printf("out %d, %d, %d, %d\n", out_s[0], out_s[1], out_s[2], out_s[3]);

  

  uint8_t order = 2; 
  int8_t **matrix = HadamarMatrix(order);
  uint16_t x, y, block_edge;
  int16_t result1[4] = {0};
  block_edge = 1<<order;
  for(y = 0; y<block_edge; y++){
    for(x = 0; x<block_edge; x++)
      printf("% 2d", matrix[x][y]);
    printf("\n");
  }

  FWHT(is, 4);
  printf("out %d, %d, %d, %d\n", is[0], is[1], is[2], is[3]);
  for(x = 0; x<4; x++)
    for(y = 0; y<4; y++)
      result1[x] += matrix[x][y]*is[y];
  printf("out %d, %d, %d, %d\n", result1[0], result1[1], result1[2], result1[3]);
  //return;
  

  freeHadamarMatrix(matrix, block_edge);
}

