# Task 2: Containment Graph
# CS 3210 - Lab 6
#
# A directed graph where edge A -> B exists if:
#   A.x <= B.x AND A.y <= B.y (A is "contained" by B)

.data
# ------------------------------------------------------------------------------
# Test Case 1: i(0,0), f(2,2), e(7,5), j(12,8) - n=4
# ------------------------------------------------------------------------------
n1:         .word 4
points1:    .word 0, 0          # point 0: i(0,0)
            .word 2, 2          # point 1: f(2,2)
            .word 7, 5          # point 2: e(7,5)
            .word 12, 8         # point 3: j(12,8)
adj1:       .space 64           # 4x4 = 16 words = 64 bytes
visited1:   .space 16           # 4 words for visited array

# ------------------------------------------------------------------------------
# Test Case 2: i(0,0), e(7,5), h(1,7), j(12,8) - n=4
# ------------------------------------------------------------------------------
n2:         .word 4
points2:    .word 0, 0          # point 0: i(0,0)
            .word 7, 5          # point 1: e(7,5)
            .word 1, 7          # point 2: h(1,7)
            .word 12, 8         # point 3: j(12,8)
adj2:       .space 64           # 4x4 = 16 words = 64 bytes
visited2:   .space 16           # 4 words for visited array

# ------------------------------------------------------------------------------
# Test Case 3: i(0,0), f(2,2), g(9,4), e(7,5), h(1,7), j(12,8) - n=6
# ------------------------------------------------------------------------------
n3:         .word 6
points3:    .word 0, 0          # point 0: i(0,0)
            .word 2, 2          # point 1: f(2,2)
            .word 9, 4          # point 2: g(9,4)
            .word 7, 5          # point 3: e(7,5)
            .word 1, 7          # point 4: h(1,7)
            .word 12, 8         # point 5: j(12,8)
adj3:       .space 144          # 6x6 = 36 words = 144 bytes
visited3:   .space 24           # 6 words for visited array

# ------------------------------------------------------------------------------
# Test Case 4: i(0,0), f(3,3), l(7,4), e(5,5), h(10,7), j(12,8) - n=6
# ------------------------------------------------------------------------------
n4:         .word 6
points4:    .word 0, 0          # point 0: i(0,0)
            .word 3, 3          # point 1: f(3,3)
            .word 7, 4          # point 2: l(7,4)
            .word 5, 5          # point 3: e(5,5)
            .word 10, 7         # point 4: h(10,7)
            .word 12, 8         # point 5: j(12,8)
adj4:       .space 144          # 6x6 = 36 words = 144 bytes
visited4:   .space 24           # 6 words for visited array

# ------------------------------------------------------------------------------
# Strings for printing
# ------------------------------------------------------------------------------
header1:    .string "Test Case 1: Containment Graph"
header2:    .string "Test Case 2: Containment Graph"
header3:    .string "Test Case 3: Containment Graph"
header4:    .string "Test Case 4: Containment Graph"
node_hdr:   .string "Nodes:"
node_pre:   .string "  Point "
coord_open: .string ": ("
comma:      .string ", "
coord_close:.string ")"
adj_hdr:    .string "Adjacency Matrix:"
dfs_hdr:    .string "DFS Traversal:"
space:      .string " "
newline:    .string "\n"
separator:  .string "=============================="

.text
.globl main

# ==============================================================================
# Register Usage:
#   s0 = base address of points array
#   s1 = n (number of points)
#   s2 = i (outer loop counter)
#   s3 = j (inner loop counter)
#   s4 = base address of adjacency matrix
#   s5 = base address of visited array
#   s6 = address of current header string
# ==============================================================================

main:
    # ==================== TEST CASE 1 ====================
    la      s0, points1
    lw      s1, n1
    la      s4, adj1
    la      s5, visited1
    la      s6, header1
    jal     run_test_case

    # ==================== TEST CASE 2 ====================
    la      s0, points2
    lw      s1, n2
    la      s4, adj2
    la      s5, visited2
    la      s6, header2
    jal     run_test_case

    # ==================== TEST CASE 3 ====================
    la      s0, points3
    lw      s1, n3
    la      s4, adj3
    la      s5, visited3
    la      s6, header3
    jal     run_test_case

    # ==================== TEST CASE 4 ====================
    la      s0, points4
    lw      s1, n4
    la      s4, adj4
    la      s5, visited4
    la      s6, header4
    jal     run_test_case

    # Exit program
    li      a0, 10
    ecall

# ==============================================================================
# Subroutine: run_test_case
# Builds adjacency matrix and prints output for current test case
# ==============================================================================
run_test_case:
    mv      s7, ra              # save return address

    # Build adjacency matrix
    li      s2, 0               # i = 0
outer_loop:
    bge     s2, s1, print_output

    li      s3, 0               # j = 0
inner_loop:
    bge     s3, s1, outer_next

    beq     s2, s3, inner_next  # skip self-loops

    # Load point[i] coordinates
    slli    t4, s2, 3
    add     t4, s0, t4
    lw      t0, 0(t4)           # x_i
    lw      t1, 4(t4)           # y_i

    # Load point[j] coordinates
    slli    t5, s3, 3
    add     t5, s0, t5
    lw      t2, 0(t5)           # x_j
    lw      t3, 4(t5)           # y_j

    # Containment check
    bgt     t0, t2, inner_next
    bgt     t1, t3, inner_next

    # Set adj[i][j] = 1
    mul     t4, s2, s1
    add     t4, t4, s3
    slli    t4, t4, 2
    add     t4, s4, t4
    li      t5, 1
    sw      t5, 0(t4)

inner_next:
    addi    s3, s3, 1
    j       inner_loop

outer_next:
    addi    s2, s2, 1
    j       outer_loop

# ==============================================================================
# Print Output Section
# ==============================================================================
print_output:
    # Print header
    li      a0, 4
    mv      a1, s6
    ecall
    li      a0, 4
    la      a1, newline
    ecall
    li      a0, 4
    la      a1, newline
    ecall

    # Print "Nodes:" header
    li      a0, 4
    la      a1, node_hdr
    ecall
    li      a0, 4
    la      a1, newline
    ecall

    # Print each node
    li      s2, 0
print_nodes_loop:
    bge     s2, s1, print_adj

    li      a0, 4
    la      a1, node_pre
    ecall

    li      a0, 1
    mv      a1, s2
    ecall

    li      a0, 4
    la      a1, coord_open
    ecall

    slli    t4, s2, 3
    add     t4, s0, t4
    li      a0, 1
    lw      a1, 0(t4)
    ecall

    li      a0, 4
    la      a1, comma
    ecall

    slli    t4, s2, 3
    add     t4, s0, t4
    li      a0, 1
    lw      a1, 4(t4)
    ecall

    li      a0, 4
    la      a1, coord_close
    ecall
    li      a0, 4
    la      a1, newline
    ecall

    addi    s2, s2, 1
    j       print_nodes_loop

print_adj:
    # Print adjacency matrix header
    li      a0, 4
    la      a1, newline
    ecall
    li      a0, 4
    la      a1, adj_hdr
    ecall
    li      a0, 4
    la      a1, newline
    ecall

    # Print adjacency matrix
    li      s2, 0
print_row_loop:
    bge     s2, s1, print_dfs

    li      s3, 0
print_col_loop:
    bge     s3, s1, print_row_end

    mul     t4, s2, s1
    add     t4, t4, s3
    slli    t4, t4, 2
    add     t4, s4, t4
    li      a0, 1
    lw      a1, 0(t4)
    ecall

    li      a0, 4
    la      a1, space
    ecall

    addi    s3, s3, 1
    j       print_col_loop

print_row_end:
    li      a0, 4
    la      a1, newline
    ecall

    addi    s2, s2, 1
    j       print_row_loop

# ==============================================================================
# DFS Traversal Section
# ==============================================================================
print_dfs:
    # Print DFS header
    li      a0, 4
    la      a1, newline
    ecall
    li      a0, 4
    la      a1, dfs_hdr
    ecall
    li      a0, 4
    la      a1, newline
    ecall

    # Clear visited array (set all to 0)
    li      s2, 0               # i = 0
clear_visited_loop:
    bge     s2, s1, start_dfs   # if i >= n, done clearing
    slli    t4, s2, 2           # t4 = i * 4 (word offset)
    add     t4, s5, t4          # t4 = address of visited[i]
    sw      zero, 0(t4)         # visited[i] = 0
    addi    s2, s2, 1           # i++
    j       clear_visited_loop

start_dfs:
    # Initialize starting node for DFS and call dfs_visit
    li      a0, 0               # start from node 0
    jal     dfs_visit           # call DFS subroutine

    # Print newline after DFS
    li      a0, 4
    la      a1, newline
    ecall

print_done:
    # Print separator
    li      a0, 4
    la      a1, newline
    ecall
    li      a0, 4
    la      a1, separator
    ecall
    li      a0, 4
    la      a1, newline
    ecall
    li      a0, 4
    la      a1, newline
    ecall

    mv      ra, s7              # restore return address
    jr      ra                  # return

# ==============================================================================
# Subroutine: dfs_visit
# Performs DFS traversal starting from node in a0
# Arguments:
#   a0 = current node index
# Uses:
#   s0 = base address of points array (preserved)
#   s1 = n (preserved)
#   s4 = base address of adjacency matrix (preserved)
#   s5 = base address of visited array (preserved)
# ==============================================================================
dfs_visit:
    # Save ra and s8 to stack (for recursive calls)
    addi    sp, sp, -12
    sw      ra, 0(sp)
    sw      s8, 4(sp)
    sw      s9, 8(sp)

    mv      s8, a0              # s8 = current node

    # Check if visited[node] == 1
    slli    t0, s8, 2           # t0 = node * 4 (word offset)
    add     t0, s5, t0          # t0 = address of visited[node]
    lw      t1, 0(t0)           # t1 = visited[node]
    li      t2, 1
    beq     t1, t2, dfs_return  # if visited[node] == 1, return

    # Mark visited[node] = 1
    sw      t2, 0(t0)           # visited[node] = 1

    # Print current node index
    li      a0, 1               # ecall 1 = print int
    mv      a1, s8              # a1 = node index
    ecall

    # Print space after node
    li      a0, 4               # ecall 4 = print string
    la      a1, space
    ecall

    # Iterate through neighbors: for j = 0 to n-1
    li      s9, 0               # s9 = j = 0
dfs_neighbor_loop:
    bge     s9, s1, dfs_return  # if j >= n, done with neighbors

    # Check if adj[current_node][j] == 1
    # Calculate offset: (current_node * n + j) * 4
    mul     t0, s8, s1          # t0 = current_node * n
    add     t0, t0, s9          # t0 = current_node * n + j
    slli    t0, t0, 2           # t0 = (current_node * n + j) * 4
    add     t0, s4, t0          # t0 = address of adj[current_node][j]
    lw      t1, 0(t0)           # t1 = adj[current_node][j]

    # If no edge, skip to next neighbor
    beqz    t1, dfs_next_neighbor

    # Edge exists: recursively call dfs_visit(j)
    mv      a0, s9              # a0 = j (neighbor node)
    jal     dfs_visit           # recursive call

dfs_next_neighbor:
    addi    s9, s9, 1           # j++
    j       dfs_neighbor_loop

dfs_return:
    # Restore ra and s8 from stack
    lw      ra, 0(sp)
    lw      s8, 4(sp)
    lw      s9, 8(sp)
    addi    sp, sp, 12
    jr      ra                  # return
