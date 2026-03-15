# Insertion Sort Implementation Steps

## Step 1: `outer_loop` - Loop Condition
- Compare `a4` (i) with `a1` (n)
- Branch to `exit_outer_loop` if `i >= n`
- Use: `bge a4, a1, exit_outer_loop`

## Step 2: `continue_outer_loop` - Setup Inner Loop
1. Calculate address of A[i]: base + i bytes
2. Load `key = A[i]` into `a6` using `lb`
3. Set `j = i - 1` in `a5`
4. Jump to `inner_loop`

## Step 3: `inner_loop` - Shift Elements
1. Check if `j < 0` -> branch to `exit_inner_loop`
2. Calculate address of A[j]: base + j bytes
3. Load `A[j]` into `a7` using `lb`
4. If `A[j] <= key` -> branch to `exit_inner_loop`
5. Store `A[j]` at `A[j+1]` using `sb` (shift right)
6. Decrement `j`
7. Loop back to `inner_loop`

## Step 4: `exit_inner_loop` - Insert Key
1. Calculate address of A[j+1]: base + (j+1) bytes
2. Store `key` at `A[j+1]` using `sb`
3. Increment `i`
4. Jump back to `outer_loop`

## Key Instructions
- `lb rd, offset(rs)` - Load byte
- `sb rs, offset(rd)` - Store byte
- `bge rs1, rs2, label` - Branch if >=
- `blt rs1, rs2, label` - Branch if <

# Prompts

We will be working on @lab6\insertion_sort_template.s . First, I        
need to complete the outer loop, so let's first tackle the loop 
condition. Compare a4 and a1, then branch to 'exit_outer_loop; if 'a4     
>= a1'

I need to setup the inner loop, so work on 'continue_outer_loop'. We    
  need to calculate the address of A[i], which is just base + i bytes.    
  We need to load key = A[i] into a6 with lb, then set j = i - 1 in a5.   
  Then jump to 'inner_loop' 

──────────────────────────────────────────────────────────────────────────
> I want to shift elements within 'inner_loop'. Implement the following   
  for me: check if j < 0, if true then branch to 'exit_inner_loop'. Now   
  recalculate the address of A[j] (base + j bytes). After, load A[j]      
  into a7 (lb). Then if A[j] <= key true, branch to 'exit_inner_loop'.    
  Lastly let us store A[j] at A[j+1] using sb. Finally decrement j and    
  loop back to 'inner_loop' 

> OK now I need help implementing the 'exit_inner_loop' functionality. I  
  need to calculate the address of A[j+1], then stroe key inside A[j+1]   
  (sb). Lastly, increment i and jump back to 'outer_loop' 

> I read through the program and I am missing the jump to 'continue_outer_loop", a1
  initialization. Fix those. Afterwards, fix line 13 where addi overwrites register a3 

  The jalr x0, x1, 0 instruction tries to return to the address stored in x1 (the return address register). However, main is the entry point of the program - it was never called with jal, so x1 was never initialized with a valid return address.

  This causes the program to jump to an undefined location (likely address 0), which restarts execution from the beginning, creating an infinite loop.

  Fix

  The exit_outer_loop should jump to the exit code instead of trying to return: