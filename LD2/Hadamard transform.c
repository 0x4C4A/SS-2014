#include <stdio.h>
#include <stdint.h>

main()
{
    int8_t s[4] = {0, 1, 2, 5};
    int8_t iresult[4] = {0};
    int8_t result[4] = {0};
    int8_t f[4][4] = {   1,  1,  1,  1,
                         1,  1, -1, -1,
                         1, -1, -1,  1,
                         1, -1,  1, -1};
    
    iresult[0] =  s[0] + s[2];
    iresult[1] =  s[1] + s[3];
    iresult[2] = -s[2] + s[0];
    iresult[3] = -s[3] + s[1];
    
    //printf("%d, %d, %d, %d\n", iresult[0],iresult[1],iresult[2],iresult[3]);
    
    result[0] =  iresult[0] + iresult[1];
    result[3] = -iresult[1] + iresult[0];
    result[1] =  iresult[2] + iresult[3];
    result[2] = -iresult[3] + iresult[2];

    printf("k   %d, %d, %d, %d\n", result[0],result[1],result[2],result[3]);
    int i, j;
    int8_t out_s[4] = {0};
    for(i=0; i<4; i++){
        for(j=0; j<4; j++){
            out_s[i]+=result[j]*f[i][j];
        }
    }
    printf("out %d, %d, %d, %d\n", out_s[0], out_s[1], out_s[2], out_s[3]);
}
