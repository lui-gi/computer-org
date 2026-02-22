.data
myarr:   .word 10, 20, 30, 40
myarr2: .word 1,2,4,8,16,32,64,128,256,512


.text
# This code will read in an array, first shrink it down to the smallest data size it requires, then stretch it to a doubleword array. Make sure to save the new array in a save memeory location so you don't overwrite the original array.
    la a3, myarr
    li a4, 4      # length of the array

    # la a3, myarr2 # switch to myarr2 to test with more test cases
    # li a4, 10      # length of the array

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


shrink:
    # at this point, t1 should have the smallest data size required for the array. We can now shrink the array in place.



stretch:

end:    # exit program
    addi a0, x0, 10
    ecall
