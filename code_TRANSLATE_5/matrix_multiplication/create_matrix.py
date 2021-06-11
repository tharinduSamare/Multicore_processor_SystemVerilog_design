import random
# matrix A - a x b  
# matrix B - b x c
a = int(input("give a: ")) 
b = int(input("give b: "))
c = int(input("give c: "))

writeFile  = open('matrix_in.txt','w')

writeFile.write(str(a)+"\n"+str(b)+"\n"+str(c)+"\n")

writeFile.write("\n//matrix A\n")
out = ""
for x in range(a):
    temp = ""
    for y in range (b):
        temp+=(str(random.randint(0,10))+" ")
    out+=(temp+"\n")

print (out)
writeFile.write(out)

writeFile.write("\n//matrix B\n")

out = ""
for x in range(b):
    temp = ""
    for y in range (c):
        temp+=(str(random.randint(0,10))+" ")
    out+=(temp+"\n")

print (out)
writeFile.write(out)
