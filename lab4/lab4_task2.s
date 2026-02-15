.data
movdisk: .string "Move disk:"
to: .string "  to rod:"
newline: .string "\n"

# Input: number of disks
disknum:    .word 8        # Change to demo different disk counts (7-9)

.text
toh:
# find the largest number of moves: 2^n - 1
    lw   a2, disknum         # a2 = n (number of disks)
    li   a3, 1
    sll  a3, a3, a2          # a3 = 2^n
    addi a3, a3, -1          # a3 = total moves (2^n - 1)
    li   a4, 1               # a4 = m (current move counter), starts at 1

movedisk:
    # start the tower of hanoi with 0
    bgt  a4, a3, end         # if m > total_moves, we are done

    # ---- Find disk: count trailing zeros of m ----
    li   a6, 0               # a6 = disk number
    mv   t0, a4              # t0 = scratch copy of m

whichdisk:
    andi t1, t0, 1           # t1 = t0 & 1 (check LSB)
    bne  t1, x0, diskfound   # if LSB is 1, disk index found
    addi a6, a6, 1           # disk_num++
    srli t0, t0, 1           # shift right by 1
    j    whichdisk

diskfound:
    # a6 now holds the disk number

    # ---- Compute source rod: (m & (m-1)) mod 3 + 1 ----
    addi t0, a4, -1          # t0 = m - 1
    and  t0, a4, t0          # t0 = m & (m-1)
    li   t2, 3
modsrc:
    blt  t0, t2, modsrcdone
    sub  t0, t0, t2
    j    modsrc
modsrcdone:
    addi t0, t0, 1           # t0 = source rod (1-indexed)
    mv   a7, t0              # a7 = source rod (saved for potential use)

towhichrod:
    # find the rod to move the disk to using (((x | x - 1) + 1) % 3 + 1), where x is the current count number
    addi t0, a4, -1          # t0 = m - 1
    or   t0, a4, t0          # t0 = m | (m-1)
    addi t0, t0, 1           # t0 = (m | (m-1)) + 1
    li   t2, 3
moddst:
    blt  t0, t2, moddstdone
    sub  t0, t0, t2
    j    moddst
moddstdone:
    addi t0, t0, 1           # t0 = dest rod (1-indexed)
    mv   t3, t0              # t3 = dest rod

    # ---- Print "Move disk:X  to rod:Y\n" ----
    li   a0, 4
    la   a1, movdisk
    ecall

    li   a0, 1
    mv   a1, a6              # print disk number
    ecall

    li   a0, 4
    la   a1, to
    ecall

    li   a0, 1
    mv   a1, t3              # print dest rod
    ecall

    li   a0, 4
    la   a1, newline
    ecall

    # increment move counter and loop back
    addi a4, a4, 1
    j    movedisk

end:
    li   a0, 10
    ecall