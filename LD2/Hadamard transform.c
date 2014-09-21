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
uint16_t FWHT( int16_t *signal_arr, uint16_t stages)
{
  int16_t tempstage, i, k, half; 
  int16_t id, upper, downer;
  int16_t block_amount;
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

int main(void)
{
  uint16_t order = 0;
  uint16_t signal_length = 8;
  int16_t is[8] = {0, 1, 2, 5, -5, -2, -1, 0};
  int16_t result1[8] = {0};
  
  signal_length--;
  while( signal_length ){
    order++;
    signal_length >>= 1;
  }

  int8_t **matrix = HadamarMatrix(order);
  uint16_t x, y, block_edge;
  block_edge = 1<<order;

  printf("Hadamar Matrix to be used (order : %d)\n", order);
  for(y = 0; y<block_edge; y++){
    for(x = 0; x<block_edge; x++)
      printf("% 2d", matrix[x][y]);
    printf("\n");
  }

  FWHT(is, order);
  printf("Coefficients ");
  for(x = 0; x<(1<<order); x++){
    printf("% 4d ", is[x]);
  }
  printf("\n");
  printf("Izeja ");
  for(x = 0; x<8; x++){
    for(y = 0; y<8; y++){
      result1[x] += matrix[x][y]*is[y];
    }
    result1[x] >>= order;
    printf("% 2d,", result1[x]);
  }
  printf("\n");
  //return;
  

  freeHadamarMatrix(matrix, block_edge);
}

