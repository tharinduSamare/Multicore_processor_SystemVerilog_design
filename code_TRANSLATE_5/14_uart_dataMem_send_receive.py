import math
import struct
import serial

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

out = b''

a = int(txt_code[0])
b = int(txt_code[1])
c = int(txt_code[2])

cores = int(txt_code[3][0])

d = math.ceil(a/cores)  #(number of raws reduces)

memWordLength = cores*12
byte_count = math.ceil(memWordLength/8)
full_length = 8*byte_count
extra_length = full_length - memWordLength

start_addr_P = 14
start_addr_Q = start_addr_P + d*b
start_addr_R = start_addr_Q + b*c + 1 #with extra space
end_addr_P = start_addr_P + d*b -1
end_addr_Q = start_addr_Q + b*c -1
end_addr_R = start_addr_R + d*c - 1

setup_values = [a, b, c, start_addr_P, start_addr_Q, start_addr_R, end_addr_P, end_addr_Q, end_addr_R, 0, 0, 0, 0, 0]

memLength = 4096
filled_memLength = len(setup_values) + (a//cores + (a % cores != 0))*b + b*c
empty_memLength = memLength-filled_memLength

############################## to send setup values ############################
# print('{0:012b}'.format(start_addr_P))


for i in setup_values:
    # print(i)
    temp = '{0:012b}'.format(i)*cores
    temp = extra_length*'0' + temp
    for x in range(byte_count,0,-1):
        temp2 = int (("0b" + temp[(x-1)*8:x*8]), 2)
        out += struct.pack('!B', temp2)
        

############################## to send matrix A values

i = 4
while (txt_code[i] == '' or  txt_code[i][0] == '/'): #to find the start of matrix A
    i = i+1

A = []
for x in range (i,i+a):
    temp = txt_code[x].strip().split(" ")
    temp = ['{0:012b}'.format(int(j)) for j in temp]
    A.append(temp)

if len(A)%cores!=0:
    for k in range(cores-len(A)%cores):
        temp = ['{0:012b}'.format(int(0)) for i in range(len(A[0]))]
        A.append(temp)

for x in range(0,len(A),cores):
    for y in range(len(A[0])):
        temporary_bin = ''
        for k in range(cores):
            temporary_bin+=A[x+k][y]

        temporary_bin = extra_length*'0' + temporary_bin
        for j in range(byte_count,0,-1):
            temp2 = int (("0b" + temporary_bin[(j-1)*8:j*8]), 2)
            out += struct.pack('!B', temp2)

############ to send matrix B values ##########

i = i + a
while (txt_code[i] == '' or  txt_code[i][0] == '/'): #to find the start of matrix B
    i = i+1

matrix_B = []
for x in range (i,i+b):
    temp = txt_code[x].strip().split(" ")
    matrix_B.append(temp)

for y in range(c):
    # print ("")
    for x in range(b):
        # print ("")
        temporary_bin = ''
        for k in range(cores):
            temporary_bin+='{0:012b}'.format(int(matrix_B[x][y]))
            # print ((int("0b"+'{0:012b}'.format(int(matrix_B[x][y])),2)),end = " ")

        temporary_bin = extra_length*'0' + temporary_bin
        for j in range(byte_count,0,-1):
            temp2 = int (("0b" + temporary_bin[(j-1)*8:j*8]), 2)
            out += struct.pack('!B', temp2)

########### append 0s for last left words

# print (out)
ser = serial.Serial('COM10',115200,bytesize=8)
ser.write(out)

################################# receive dmemory after calculation

DMem = []
R_matrix_lenght = end_addr_R - start_addr_R + 1

for x in range(R_matrix_lenght):
    temp = ''
    for x in range (byte_count):
        in_bin = ser.read()
        temp = '{0:08b}'.format((int.from_bytes(in_bin,byteorder='little'))) + temp
    # print (hex(int("0b"+temp[extra_length:],2)))
    temp = int("0b"+temp[extra_length:],2)
    DMem.append(temp)

# for x in  (DMem[0:100]):
#     print (hex(int(x)))

################################## find R matrix

# matrix_initial = DMem[start_addr_R:end_addr_R+1]
matrix_initial = DMem
matrix_second = []

for x in matrix_initial:
    matrix_second.append(decodeCombinedValues(x, cores))

matrix_R = convertToCorrectForm(matrix_second, cores, a,c,d)

writeFile = open('15_answer_matrix_from_processor(UART).txt', 'w')

for x in (matrix_R):
    for y in (x):
        writeFile.write(y + (6-len(y))*" ")
    writeFile.write('\n')
writeFile.close()
print(matrix_R)

