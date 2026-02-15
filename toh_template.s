.data
movdisk: .string "Move disk:"
to: .string "  to rod:"
newline: .string "\n"

# Input: number of disks
disknum:    .word 4

.text
toh:
# find the largest number of moves: 2^n - 1


movedisk:
    # start the tower of hanoi with 0


whichdisk:





towhichrod:
    # find the rod to move the disk to using (((x | x - 1) + 1) % 3 + 1), where x is the current count number
