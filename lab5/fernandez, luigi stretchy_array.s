.data
myarr:   .word 10, 20, 30, 40
myarr2: .word 1,2,4,8,16,32,64,128,256,512
output: .space 80    # 10 elements * 8 bytes per doubleword


.text
# This code will read in an array, first shrink it down to the smallest data size it requires, then stretch it to a doubleword array. Make sure to save the new array in a save memeory location so you don't overwrite the original array.
    #la a3, myarr
    #li a4, 4      # length of the array

    la a3, myarr2 # switch to myarr2 to test with more test cases
    li a4, 10      # length of the array

    mv a5, a3 # saving original base address
    mv t0, a4
    addi t1, x0, 0 # store the smallest data size required for the array (1 for byte, 2 for halfword, 4 for word)

iterate_array:
    beq t0, x0, shrink  # if length of array is 0, end iteration
    lw a6, 0(a3)
    addi a3, a3, 4
    addi t0, t0, -1

check_size:
    # check if the number can fit in a byte, halfword, or word
    li a7, 1
    li t3, 256
    bltu a6, t3, update_max # value < 256 means fits in byte
    li a7, 2
    lui t3, 16 # t3 = 65536
    bltu a6, t3, update_max # value < 65536 means fits in halfword
    li a7, 4 # otherwise needs full word
update_max:
    bge t1, a7, iterate_array  # current max already covers this element
    mv t1, a7
    j iterate_array

shrink:
    # at this point, t1 should have the smallest data size required for the array. We can now shrink the array in place.
    mv a3, a5 # reset read pointer
    mv t2, a5 # write pointer = base (in-place)
    mv t0, a4 # reset counter
    li a6, 4
    beq t1, a6, stretch # skip if already word-sized
shrink_loop:
    beq t0, x0, stretch
    lw a6, 0(a3)
    addi a3, a3, 4
    addi t0, t0, -1
    li a7, 1
    beq t1, a7, store_byte
    sh a6, 0(t2) # halfword case
    addi t2, t2, 2
    j shrink_loop
store_byte:
    sb a6, 0(t2)
    addi t2, t2, 1
    j shrink_loop

stretch:
    mv t2, a5 # read from base of shrunk data
    la t3, output # write to output buffer
    mv t0, a4 # reset counter
stretch_loop:
    beq t0, x0, end
    li a7, 1
    beq t1, a7, load_byte
    li a7, 2
    beq t1, a7, load_half
    lw a6, 0(t2) # word case (fall-through)
    addi t2, t2, 4
    j store_dword
load_byte:
    lbu a6, 0(t2)
    addi t2, t2, 1
    j store_dword
load_half:
    lhu a6, 0(t2)
    addi t2, t2, 2
store_dword:
    sw a6, 0(t3) # low word = value
    sw x0, 4(t3) # high word = 0
    addi t3, t3, 8
    addi t0, t0, -1
    j stretch_loop

end:    # exit program
    addi a0, x0, 10
    ecall
