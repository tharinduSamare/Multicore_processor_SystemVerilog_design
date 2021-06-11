import serial
import math
import struct

values = (20,2,3,4,5,20,234,11,32,233,1,2,3,4,5,0,9,8,7,6,11,22,33,44,55,66,55,44,33,22)*10

string = b''

for i in values:
    string += struct.pack('!B',i)

# read from fpga
# ser = serial.Serial('COM6',19200,bytesize=8)
# ser.write(string)
# print(values)
# print (string)

memoryLength = 4096
cores = 1
memWordLength = cores*12
# byte_count = (memWordLength // 8) + (memWordLength % 8 != 0)
byte_count = math.ceil(memWordLength/8)
full_length = 8*byte_count
extra_length = full_length - memWordLength

ser = serial.Serial('COM6',baudrate = 19200, bytesize = 8, parity='N')

dmem = []

for x in range(memoryLength):
    temp = ''
    for x in range (byte_count):
        in_bin = ser.read()
        temp = '{0:08b}'.format((int.from_bytes(in_bin,byteorder='little'))) + temp
    # print (hex(int("0b"+temp[extra_length:],2)))
    dmem.append(temp)

for x in  (dmem[0:100]):
    # print (hex(int("0b"+x[extra_length:],2)))
    print (x)


