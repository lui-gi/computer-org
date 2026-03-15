# Task 2: Containment Graph
# CS 3210 - Lab 6
#
# A directed graph where edge A -> B exists if:
#   A.x <= B.x AND A.y <= B.y (A is "contained" by B)

.data
# ------------------------------------------------------------------------------
# Number of points in the graph
# ------------------------------------------------------------------------------
n:          .word 4

# ------------------------------------------------------------------------------
# Points array - each point is stored as (x, y) pair (2 words = 8 bytes each)
# Test Case 1: i(0,0), f(2,2), e(7,5), j(12,8)
# ------------------------------------------------------------------------------
points:     .word 0, 0          # point 0: i(0,0)
            .word 2, 2          # point 1: f(2,2)
            .word 7, 5          # point 2: e(7,5)
            .word 12, 8         # point 3: j(12,8)

# ------------------------------------------------------------------------------
# Adjacency matrix - n x n matrix (4 x 4 = 16 words = 64 bytes)
# adj[i][j] = 1 if there is an edge from point i to point j, 0 otherwise
# Matrix layout (row-major order):
#   adj[0][0], adj[0][1], adj[0][2], adj[0][3],
#   adj[1][0], adj[1][1], adj[1][2], adj[1][3],
#   adj[2][0], adj[2][1], adj[2][2], adj[2][3],
#   adj[3][0], adj[3][1], adj[3][2], adj[3][3]
# ------------------------------------------------------------------------------
adj:        .space 64           # 16 words * 4 bytes = 64 bytes

.text
.globl main

# ==============================================================================
# Register Usage:
#   s0 = base address of points array
#   s1 = n (number of points)
#   s2 = i (outer loop counter)
#   s3 = j (inner loop counter)
#   s4 = base address of adjacency matrix
#   t0 = x_i (x coordinate of point i)
#   t1 = y_i (y coordinate of point i)
#   t2 = x_j (x coordinate of point j)
#   t3 = y_j (y coordinate of point j)
#   t4, t5, t6 = temporary values for calculations
# ==============================================================================

main:
    # Initialize registers
    la      s0, points          # s0 = base address of points array
    la      t0, n               # load address of n
    lw      s1, 0(t0)           # s1 = n (number of points)
    la      s4, adj             # s4 = base address of adjacency matrix

    li      s2, 0               # s2 = i = 0 (outer loop counter)

    # Outer loop: for i = 0 to n-1
outer_loop:
    bge     s2, s1, end_program # if i >= n, exit outer loop

    li      s3, 0               # reset j = 0 at start of each outer iteration

    # Inner loop: for j = 0 to n-1
inner_loop:
    bge     s3, s1, outer_next  # if j >= n, exit inner loop (go to outer_next)

    beq     s2, s3, inner_next  # if i == j, skip (no self-loops)

    # Load point[i] coordinates (x_i, y_i)
    slli    t4, s2, 3           # t4 = i * 8 (offset for point[i])
    add     t4, s0, t4          # t4 = address of point[i]
    lw      t0, 0(t4)           # t0 = x_i (first word of point[i])
    lw      t1, 4(t4)           # t1 = y_i (second word of point[i])

    # Load point[j] coordinates (x_j, y_j)
    slli    t5, s3, 3           # t5 = j * 8 (offset for point[j])
    add     t5, s0, t5          # t5 = address of point[j]
    lw      t2, 0(t5)           # t2 = x_j (first word of point[j])
    lw      t3, 4(t5)           # t3 = y_j (second word of point[j])

    # Containment check: if x_i <= x_j AND y_i <= y_j, add edge
    bgt     t0, t2, inner_next  # if x_i > x_j, skip (not contained)
    bgt     t1, t3, inner_next  # if y_i > y_j, skip (not contained)

    # Both conditions passed: set adj[i][j] = 1
    mul     t4, s2, s1          # t4 = i * n
    add     t4, t4, s3          # t4 = i * n + j
    slli    t4, t4, 2           # t4 = (i * n + j) * 4 (byte offset)
    add     t4, s4, t4          # t4 = address of adj[i][j]
    li      t5, 1               # t5 = 1
    sw      t5, 0(t4)           # adj[i][j] = 1

inner_next:
    addi    s3, s3, 1           # j++
    j       inner_loop          # jump back to inner loop start

outer_next:
    addi    s2, s2, 1           # i++
    j       outer_loop          # jump back to outer loop start

    # Program end
end_program:
    li      a7, 10              # ecall 10 = exit program
    ecall                       # terminate program

