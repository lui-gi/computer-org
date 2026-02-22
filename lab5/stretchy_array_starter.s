.data
myarr:   .word 10, 20, 30, 40
myarr2: .word 1,2,4,8,16,32,64,128,256,512
output: .space 80    # 10 elements * 8 bytes per doubleword


.text
# This code will read in an array, first shrink it down to the smallest data size it requires, then stretch it to a doubleword array. Make sure to save the new array in a save memeory location so you don't overwrite the original array.
    la a3, myarr
    li a4, 4      # length of the array

    # la a3, myarr2 # switch to myarr2 to test with more test cases
    # li a4, 10      # length of the array

    mv a5, a3          # save original base address
    mv t0, a4
    addi t1, x0, 0 # store the smallest data size required for the array (1 for byte, 2 for halfword, 4 for word)

iterate_array:
    beq t0, x0, shrink  # if length of array is 0, end iteration
    lw a6, 0(a3)
    addi a3, a3, 4
    addi t0, t0, -1

check_size:
    # check if the number can fit in a byte, halfword, or word
    srli a6, a6, 8
    beq a6, x0, fit_byte
    srli a6, a6, 8          # shift another 8 (total 16 from original)
    beq a6, x0, fit_half
    j fit_word

fit_byte:
    li a6, 1
    bge t1, a6, iterate_array
    li t1, 1
    j iterate_array

fit_half:
    li a6, 2
    bge t1, a6, iterate_array
    li t1, 2
    j iterate_array

fit_word:
    li t1, 4
    j iterate_array

shrink:
    # at this point, t1 should have the smallest data size required for the array. We can now shrink the array in place.
    mv a3, a5               # reset read pointer
    mv t2, a5               # write pointer = base (in-place)
    mv t0, a4               # reset counter
    li a6, 4
    beq t1, a6, stretch     # skip if already word-sized

shrink_loop:
    beq t0, x0, stretch
    lw a6, 0(a3)
    addi a3, a3, 4
    addi t0, t0, -1
    li a7, 1
    beq t1, a7, store_byte
    j store_half

store_byte:
    sb a6, 0(t2)
    addi t2, t2, 1
    j shrink_loop

store_half:
    sh a6, 0(t2)
    addi t2, t2, 2
    j shrink_loop

stretch:
    mv t2, a5               # read from base of shrunk data
    la t3, output            # write to output buffer
    mv t0, a4               # reset counter

stretch_loop:
    beq t0, x0, end
    li a6, 1
    beq t1, a6, load_byte
    li a6, 2
    beq t1, a6, load_half
    j load_word

load_byte:
    lbu a6, 0(t2)
    addi t2, t2, 1
    j store_dword

load_half:
    lhu a6, 0(t2)
    addi t2, t2, 2
    j store_dword

load_word:
    lw a6, 0(t2)
    addi t2, t2, 4
    j store_dword

store_dword:
    sw a6, 0(t3)            # low word = value
    sw x0, 4(t3)            # high word = 0
    addi t3, t3, 8
    addi t0, t0, -1
    j stretch_loop

end:    # exit program
    addi a0, x0, 10
    ecall
