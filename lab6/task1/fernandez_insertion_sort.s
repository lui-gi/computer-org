.data

myarr:   .byte 40, 50, 10, 20, 30, 60

.text
# a1 is number of elements in myarr, n, a3 is the address of myarr
# a4: i - index of the outer loop, a5: j - index of the inner loop
# a6: current element in the outer loop, a7: current element in the inner loop

main:
    # load address of myarr into a3
    la a3, myarr
    addi a1, x0, 6 # n = 6 (number of elements in myarr)

    # Print starting memory address of array (this is just for me so I know where to look in memory)
    addi a0, x0, 1         # a0 = 1 (print int syscall)
    mv a1, a3              # a1 = array address
    ecall

    addi a1, x0, 6         # restore a1 = n = 6
    addi a4, x0, 1         # i = 1

outer_loop:  # if i < n, continue outer loop
    bge a4, a1, exit_outer_loop
    j continue_outer_loop

exit_outer_loop:
    j exit_program

continue_outer_loop:
    add t0, a3, a4       # t0 = address of A[i] (base + i)
    lb a6, 0(t0)         # key = A[i]
    addi a5, a4, -1      # j = i - 1
    j inner_loop

inner_loop:
    bltz a5, exit_inner_loop    # if j < 0, exit inner loop
    add t0, a3, a5              # t0 = address of A[j] (base + j)
    lb a7, 0(t0)                # a7 = A[j]
    ble a7, a6, exit_inner_loop # if A[j] <= key, exit inner loop
    sb a7, 1(t0)                # A[j+1] = A[j]
    addi a5, a5, -1             # j = j - 1
    j inner_loop

exit_inner_loop:
    addi t1, a5, 1        # t1 = j + 1
    add t0, a3, t1        # t0 = address of A[j+1] (base + j + 1)
    sb a6, 0(t0)          # A[j+1] = key
    addi a4, a4, 1        # i = i + 1
    j outer_loop

exit_program:
    addi a0, x0, 10
    ecall
