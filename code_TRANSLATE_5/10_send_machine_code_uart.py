import serial

def decode(instruction):
    isa = {
        'NOP': '00000000',
        'ENDOP': '00000001',
        'CLAC': '00000010',
        'LDIAC': '00000011',
        'LDAC': '00000100',
        'STR': '00000101',
        'STIR': '00000110',
        'JUMP': '00000111',
        'JMPNZ': '00001000',
        'JMPZ': '00001001',
        'MUL': '00001010',
        'ADD': '00001011',
        'SUB': '00001100',
        'INCAC': '00001101',
        'MV_RL_AC': '00011111',
        'MV_RP_AC': '00101111',
        'MV_RQ_AC': '00111111',
        'MV_RC_AC': '01001111',
        'MV_R_AC': '01011111',
        'MV_R1_AC': '01101111',
        'MV_AC_RP': '01111111',
        'MV_AC_RQ': '10001111',
        'MV_AC_RL': '10011111',
    }
    if instruction in isa:
        return isa[instruction]
    else:
        return instruction

code = open('7_assembly_code.txt','r')
txt_code = code.read().strip().split('\n')

decoded_code = []
i = 0
while(i<len(txt_code)):
    if txt_code[i][0]=='/':
        i+=1
        continue
    codewithoutcomments = ''
    for j in txt_code[i]:
        if j!='/':
            codewithoutcomments+=j
        else:
            break
    assert codewithoutcomments[-1]==';','Error! missing ; at the end of the line'
    temp = codewithoutcomments[:-1]
    decoded_int = decode(temp)
    if(temp=='LDIAC'or temp=='STIR' or temp=='JMPNZ' or temp=='JUMP' or temp == 'JMPZ'):
        decoded_code.append(decoded_int)
        address = txt_code[i+1]
        addresswithoutcomments = ''
        for j in address:
            if j!='/':
                addresswithoutcomments+=j
            else:
                break
        assert addresswithoutcomments[-1]==';','Error! missing ; at the end of the line'
        decoded_code.append('{0:08b}'.format(int(addresswithoutcomments[:-1])))
        i+=1
    else:
        decoded_code.append(decoded_int)
    i+=1

####################### SEND THROUGH UART ###########################
uart_list = []
for i in range(255,-1,-1):
    if (i<len(decoded_code)):
        # print ("    "+str(i)+" :   "+decoded_code[i]+";") #for checking
        value = (128)*int(decoded_code[i][0]) + (64)*int(decoded_code[i][1]) + (32)*int(decoded_code[i][2]) + (16)*int(decoded_code[i][3]) + (8)*int(decoded_code[i][4]) + (4)*int(decoded_code[i][5]) + (2)*int(decoded_code[i][6]) + (1)*int(decoded_code[i][7])
        uart_list.append(value)
    else:
        # print ("    "+str(i)+" :   "+ "XXXXXXXX"+";") #for checking
        uart_list.append(0)

# for i in range (len(uart_list)-1,-1,-1): #for checking
#     print (255-i, " " ,hex(uart_list[i])),

ser = serial.Serial('COM10',115200,bytesize=8)
ser.write(uart_list[::-1])