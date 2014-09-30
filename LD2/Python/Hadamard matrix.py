import math

matrix_size = pow(2,5);

#Allocate array
matrix = [[0 for x in xrange(matrix_size)] for x in xrange(matrix_size)] 

matrix[0][0] = 1

for stage in range(0,int(math.log(matrix_size,2))):
	block_edge = pow(2, stage)
	for x in range(0, block_edge):
		for y in range(0, block_edge):
			matrix[x + block_edge][y] = matrix[x][y]
			matrix[x][y + block_edge] = matrix[x][y]
			matrix[x + block_edge][y + block_edge] = -matrix[x][y]

for y in range(0,matrix_size):
	for x in range(0,matrix_size):
		print '{:>2}'.format(matrix[x][y]),
	print '\n'
