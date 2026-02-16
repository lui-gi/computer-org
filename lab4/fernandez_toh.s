.data
movdisk: .string "Move disk:"
to: .string "  to rod:"
newline: .string "\n"

# Input: number of disks
disknum:    .word 8

# For reference so I don't forget
# s0 = number of disks
# s1 = largest number of moves
# s2 = move counter
# s3 = disk id
# s4 = remainder of rod formula; ((x | x - 1) + 1) % 3

.text
toh:
# find the largest number of moves: 2^n - 1
    la t0, disknum
    lw s0, 0(t0)

    # calculating 2^n - 1
    li t0, 1
    sll s1, t0, s0
    addi s1, s1, -1

    li s2, 1 # we start at move #1


movedisk:
    # start the tower of hanoi with 0

    # we can end program IF number of moves reaches maximum number of possible moves that we calculated
    bgt s2, s1, end_program


whichdisk:
    # we have to count the trailing zeros
    mv t0, s2
    li s3, 0 # start disk id count at 0

count_zeros:
    andi t1, t0, 1 # t1 = t0 and 1,  check if t1 is odd/even
    bnez t1, towhichrod # (t1 =/ 0, then jump towhichrod)

    # if t1 is even
    srli t0, t0, 1
    addi s3, s3, 1
    j count_zeros




towhichrod:
    # find the rod to move the disk to using (((x | x - 1) + 1) % 3 + 1), where x is the current count number
    addi t0, s2, -1
    or t1, s2, t0 # t1 = m OR (m - 1)
    addi t1, t1, 1

    li t2, 3 
    remu s4, t1, t2 # s4 = t1 % 3
    addi s4, s4, 1 # s4 = remainder ^ + 1 = (the rod)

    # Print move disk string movdisk
    li a0, 4
    la a1, movdisk
    ecall

    # Print disk # s3
    li a0, 1
    mv a1, s3
    ecall

    # Print to rod string
    li a0, 4
    la a1, to
    ecall

    # Print rod num s4
    li a0, 1
    mv a1, s4
    ecall

    # Print newline 
    li a0, 4
    la a1, newline
    ecall

    # Increment and jump back
    addi s2, s2, 1      # increment m by 1
    j movedisk          # j to start of loop

end_program:
    # Exit 
    li a0, 10
    ecall