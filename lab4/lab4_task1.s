.data
num6: .word 6
num7: .word 7
num12: .word 12
num20: .word 20
num3: .word 3
newline: .asciiz "\n"
case1: .string "6 mod 7 = "
case2: .string "12 mod 3 = "
case3: .string "20 mod 3 = "


.text
# Case 1
lw a2, num6
lw a3, num7

li a0, 4
la a1, case1
ecall

div:
    bge a2, a3, loop
    j loop_done
loop:
    sub a2, a2, a3
    j div
loop_done:
    add a1, x0, a2
    li a0, 1
    ecall

    li a0, 4
    la a1, newline
    ecall

# Case 2
lw a2, num12
lw a3, num3
li a0, 4
la a1, case2
ecall

div2:
    bge a2, a3, loop2
    j loop_done2
loop2:
    sub a2, a2, a3
    j div2
loop_done2:
    mv a1, a2
    li a0, 1
    ecall
    li a0, 4
    la a1, newline
    ecall

# Case 3
lw a2, num20
lw a3, num3
li a0, 4
la a1, case3
ecall

div3:
    bge a2, a3, loop3
    j loop_done3
loop3:
    sub a2, a2, a3
    j div3
loop_done3:
    mv a1, a2
    li a0, 1
    ecall
    li a0, 4
    la a1, newline
    ecall

li a0, 10
ecall