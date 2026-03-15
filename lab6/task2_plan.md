# Task 2: Containment Graph - Implementation Plan

## Problem Summary

Create a directed graph where an edge exists from node A to node B if:
- A.x <= B.x **AND** A.y <= B.y (A is "contained" by B)
- A and B are different nodes

---

## Test Cases (from PDF)

| Case | Points | Expected Graph |
|------|--------|----------------|
| 1 | i(0,0), f(2,2), e(7,5), j(12,8) | i->f->e->j (chain) |
| 2 | i(0,0), e(7,5), h(1,7), j(12,8) | i->e, i->h, e->j, h->j |
| 3 | i(0,0), f(2,2), g(9,4), e(7,5), h(1,7), j(12,8) | i->f, f->e, f->g, i->h, etc. |
| 4 | i(0,0), f(3,3), l(7,4), e(5,5), h(10,7), j(12,8) | i->f, f->l, f->e, l->h, h->j |

---

## Implementation Plan

### Step 1: Data Structure Setup
- Store points as pairs of words (x, y) in memory
- Store number of points (n)
- Allocate space for adjacency matrix (n x n)

### Step 2: Nested Loop Algorithm (O(n^2))
```
for i = 0 to n-1:          # outer loop
    for j = 0 to n-1:      # inner loop
        if i != j:
            load point_i (x_i, y_i)
            load point_j (x_j, y_j)
            if x_i <= x_j AND y_i <= y_j:
                mark edge[i][j] = 1
```

### Step 3: Register Allocation
- `s0`: base address of points array
- `s1`: number of points (n)
- `s2`: outer loop counter (i)
- `s3`: inner loop counter (j)
- `s4`: base address of output adjacency matrix
- `t0-t3`: temporary for loading x, y coordinates

### Step 4: Memory Layout
```
.data
n:        .word 4              # number of points
points:   .word 0, 0           # i(0,0)
          .word 2, 2           # f(2,2)
          .word 7, 5           # e(7,5)
          .word 12, 8          # j(12,8)
adj:      .space 64            # n*n*4 bytes for adjacency matrix
```

### Step 5: Core Logic
1. Load addresses and n
2. Outer loop: iterate i from 0 to n-1
3. Inner loop: iterate j from 0 to n-1
4. Skip if i == j
5. Load (x_i, y_i) and (x_j, y_j)
6. Compare: if x_i <= x_j AND y_i <= y_j, set adj[i*n + j] = 1
7. Continue loops

---

## Deliverables (ignoring tournament)

1. `lastname_containment_graph.s` - RISC-V implementation
2. Screenshots of memory for each test case
3. `lastname_t2questions.s` - Answers to:
   - Can the graph become cyclic? **No** (if A contains B, then A.x <= B.x, so B cannot contain A unless they're the same point)
   - Maximum branches per node? **n-1** (a node at origin could connect to all others)

---

## Prompts for Iterative Implementation

Use the following prompts in sequence to complete the assignment step-by-step.

### Prompt 1: Create the Data Section
```
Create the .data section for task2.s with:
- Test Case 1 points: i(0,0), f(2,2), e(7,5), j(12,8)
- A variable for the number of points (n=4)
- Space for a 4x4 adjacency matrix (16 words)
Include comments explaining each section.
```

### Prompt 2: Initialize Registers
```
Write the initialization code in .text section that:
- Loads the base address of the points array into s0
- Loads n (number of points) into s1
- Loads the base address of the adjacency matrix into s4
- Initializes loop counters i (s2) and j (s3) to 0
```

### Prompt 3: Implement the Outer Loop
```
Implement the outer loop structure that:
- Iterates i (s2) from 0 to n-1
- Resets j (s3) to 0 at the start of each iteration
- Includes a label for the loop start and end condition check
- Branches to exit when i >= n
```

### Prompt 4: Implement the Inner Loop
```
Implement the inner loop structure that:
- Iterates j (s3) from 0 to n-1
- Includes a label for the inner loop start
- Branches back to outer loop increment when j >= n
- Skips processing if i == j (no self-loops)
```

### Prompt 5: Load Point Coordinates
```
Inside the inner loop, add code to:
- Calculate the memory offset for point[i]: offset_i = i * 8 (2 words per point)
- Load x_i and y_i from points[i] into t0 and t1
- Calculate the memory offset for point[j]: offset_j = j * 8
- Load x_j and y_j from points[j] into t2 and t3
```

### Prompt 6: Implement the Containment Check
```
Add the containment comparison logic:
- Check if x_i <= x_j (if not, skip to next j)
- Check if y_i <= y_j (if not, skip to next j)
- If both conditions pass, calculate adj[i*n + j] offset
- Store 1 at that adjacency matrix location
```

### Prompt 7: Complete Loop Increments and Termination
```
Add the loop increment and termination code:
- Increment j and jump back to inner loop start
- Increment i and jump back to outer loop start
- Add a proper program end (ebreak or infinite loop)
```

### Prompt 8: Test and Debug
```
Review the complete task2.s implementation for:
- Correct branch conditions (use bge for >=, bgt for >)
- Proper offset calculations (words are 4 bytes, points are 8 bytes)
- Register preservation if needed
- Add any missing labels or fix syntax errors
```

### Prompt 9: Update for Other Test Cases
```
Modify the .data section to test Case X (replace with 2, 3, or 4):
- Case 2: i(0,0), e(7,5), h(1,7), j(12,8) - n=4
- Case 3: i(0,0), f(2,2), g(9,4), e(7,5), h(1,7), j(12,8) - n=6
- Case 4: i(0,0), f(3,3), l(7,4), e(5,5), h(10,7), j(12,8) - n=6
Update the adjacency matrix space allocation accordingly.
```

### Prompt 10: Answer the Questions
```
Create lastname_t2questions.s with comments answering:
1. Can the containment graph become cyclic? Prove or disprove.
2. What is the maximum number of branches that a node can have?
```

---

## Notes

- Each prompt builds on the previous one
- Test after each major step in RARS simulator
- Check the adjacency matrix in memory after running to verify correctness
- Compare output against expected graphs from the PDF

---

## Tournament Round: DFS Traversal

The tournament requires a module to traverse the graph and print nodes in depth-first search order. The implementation that uses the least RAM wins.

### DFS Algorithm
```
DFS(node):
    if visited[node] == 1:
        return
    visited[node] = 1
    print(node)
    for each neighbor j where adj[node][j] == 1:
        DFS(j)
```

### Expected DFS Output (starting from node 0)
- Case 1: 0 -> 1 -> 2 -> 3 (i -> f -> e -> j)
- Case 2: 0 -> 1 -> 3 -> 2 -> 3 or 0 -> 1 -> 3 -> 2 (i -> e -> j, then h -> j)
- Case 3: 0 -> 1 -> 2 -> 5 -> 3 -> 4 (depends on adjacency order)
- Case 4: 0 -> 1 -> 2 -> 4 -> 5 -> 3 (depends on adjacency order)

---

## Prompts for DFS Implementation (Tournament Round)

### Prompt 11: Add Visited Array
```
Add a visited array to the .data section:
- Allocate space for a visited array (n words, one per node)
- For n=4 cases: .space 16 (4 words)
- For n=6 cases: .space 24 (6 words)
- Add a string label for the DFS header output
```

### Prompt 12: Add DFS Header Print
```
After printing the adjacency matrix, add code to:
- Print a header "DFS Traversal:" followed by a newline
- Reset the visited array to all zeros before starting DFS
- Initialize s2 = 0 as the starting node (root)
```

### Prompt 13: Create the DFS Subroutine Structure
```
Create a dfs_visit subroutine that:
- Takes the current node index in s2
- Saves ra to s7 (or stack) since we'll make recursive calls
- Checks if visited[s2] == 1, if so return immediately
- Otherwise marks visited[s2] = 1 and prints the node index
```

### Prompt 14: Print the Current Node in DFS
```
Inside dfs_visit, after marking visited:
- Print the node index (s2) using ecall 1
- Print a space after the node index
- This shows the DFS traversal order
```

### Prompt 15: Iterate Through Neighbors
```
Inside dfs_visit, after printing the node:
- Save the current node to a saved register (s8)
- Loop j from 0 to n-1
- For each j, check if adj[current_node][j] == 1
- If edge exists, set s2 = j and call dfs_visit recursively
- Restore current node from s8 after each recursive call
```

### Prompt 16: Handle Recursive Calls with Stack
```
Update dfs_visit to use the stack for recursion:
- Push ra and any saved registers to the stack at subroutine entry
- Pop them before returning
- This allows proper nested recursive calls
- Use: addi sp, sp, -N to allocate, sw to save, lw to restore, addi sp, sp, N to deallocate
```

### Prompt 17: Call DFS from Main
```
In the print section, after printing the adjacency matrix:
- Call a subroutine to clear the visited array (set all to 0)
- Print the DFS header
- Set s2 = 0 (start from node 0)
- Call dfs_visit
- Print a newline after DFS completes
```

### Prompt 18: Clear Visited Array Subroutine
```
Create a clear_visited subroutine that:
- Loads the base address of the visited array
- Loops from 0 to n-1
- Stores 0 at each visited[i] location
- Returns to caller
```

### Prompt 19: Test DFS Output
```
Run the program and verify DFS output for each test case:
- Case 1: Should print nodes in order following i -> f -> e -> j
- Case 2: Should print nodes following the graph structure
- Case 3 & 4: Verify against expected graph traversal
- Ensure no node is printed twice (visited check working)
```

### Prompt 20: Optimize for Minimum RAM (Tournament)
```
Review the implementation to minimize RAM usage:
- Can we reuse the adjacency matrix space?
- Can we use registers instead of memory where possible?
- Can we eliminate any unnecessary .space allocations?
- Consider using bits instead of words for visited array
- Document total RAM used in bytes
```

---

## RAM Optimization Ideas

1. **Visited array**: Use 1 bit per node instead of 1 word (saves 3 bytes per node)
2. **Reuse registers**: Minimize temporary memory usage
3. **In-place operations**: Avoid duplicate data structures
4. **Smaller data types**: Use .byte or .half where possible
