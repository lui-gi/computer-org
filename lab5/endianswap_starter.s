# Endian swap in place. Make the number swap from little endian to big indian without changing its place in memory. For example, 0x12345678 should be changed to 0x78563412 at memory location 0x10000000.
.data
num1: .word 0x12345678
num2: .word -2

.text
la t0, num1
la t3, num2


# # exit program
li a0, 10         # syscall for exit
ecall

