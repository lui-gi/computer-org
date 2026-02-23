# Endian swap in place. Make the number swap from little endian to big indian without changing its place in memory. For example, 0x12345678 should be changed to 0x78563412 at memory location 0x10000000.
.data
num1: .word 0x12345678
num2: .word -2

.text
la t0, num1
la t3, num2

# Swapping num1
lbu t1, 0(t0) # starting with LSB byte 0
lbu t2, 1(t0)
lbu t4, 2(t0)
lbu t5, 3(t0) # ends with MSB
sb  t5, 0(t0) # now I store MSB at byte 0
sb  t4, 1(t0)
sb  t2, 2(t0)
sb  t1, 3(t0) # lastly store LSB at byte 3

# Swapping num2
lbu t1, 0(t3) # start with LSB byte 0
lbu t2, 1(t3)
lbu t4, 2(t3)
lbu t5, 3(t3) # ends with MSB byte 3
sb  t5, 0(t3) # store MSB at byte 0
sb  t4, 1(t3)
sb  t2, 2(t3)
sb  t1, 3(t3) # finally store LSB at byte 3

# # exit program
li a0, 10         # syscall for exit
ecall

