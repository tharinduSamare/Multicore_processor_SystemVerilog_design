
def getDataMemory(array_in):
    DMem = []
    for temp in (array_in):
        if  (temp[1] != '['):
            DMem.append(int(( "0b" + temp[11:-1]),2)) 
        else:
            begin = int (("0x" + temp[2:6]) , 16)
            end = int(( "0x" + temp[8:12]),16)
            value = int(( "0b" + temp[19:-1]),2)
            no_of_values = end-begin + 1
            DMem.extend([value]*no_of_values)
    return DMem

##############################################################
def decodeCombinedValues(valueIn,no_of_cores):
    if (no_of_cores == 1):
        return [valueIn]
    
    out = []
    temp = bin(valueIn)[2:]
    temp = format(int(temp), ('0'+str(12*no_of_cores)+'d'))
    for x in range(no_of_cores):
        out.append(int(('0b' + temp[x*12:x*12+12]), 2))
    return out

##################################################################
def convertToCorrectForm(inputMatrix, no_of_cores, a,c,d):

    OutputMatrix = [[0 for x in range(c)] for y in range(a)]

    for x in range(d):
        for y in range(c):
            for z in range(no_of_cores):
                if (x*no_of_cores+z) < a:
                        OutputMatrix[x*no_of_cores+z][y] = hex(inputMatrix[x*c+y][z])[2:]
    return (OutputMatrix)

###############################################################
data = open('2_matrix_in.txt','r')
txt_code = data.read().strip().split('\n')

a = int(txt_code[0])
b = int(txt_code[1])
c = int(txt_code[2])
cores = int(txt_code[3][0])

data.close()

if (a%cores == 0):
    d = a//cores
else:
    d = a//cores + 1

size_P = d*b
size_Q = b*c
size_R = d*c

#to find the start of answer matrix
raw_data_size = 14  #data not belongs to matrix values
start_R = raw_data_size + size_P + size_Q + 1  # extra 1 word space is given 
end_R = start_R + size_R-1                     #in assembly code before answer matrix

data = open('11_data_mem_output.mif', 'r')
data_in = data.read().strip().split('\n')[23:-1]   #first 23 lines contains unnecessary data
data.close()  

DMem = getDataMemory(data_in)  # get all the matrix entries into a array
matrix_initial = DMem[start_R:end_R+1]
matrix_second = []

for x in matrix_initial:
    matrix_second.append(decodeCombinedValues(x, cores))

matrix_R = convertToCorrectForm(matrix_second, cores, a,c,d)

writeFile = open('13_answer_matrix_from_processor.txt', 'w')

for x in (matrix_R):
    for y in (x):
        writeFile.write(y + (6-len(y))*" ")
    writeFile.write('\n')
writeFile.close()
print(matrix_R)
                


