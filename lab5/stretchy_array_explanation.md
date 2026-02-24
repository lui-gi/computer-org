# Stretchy Array — Line-by-Line Explanation

## Overview

This RISC-V assembly program reads an integer array, determines the **smallest data type** that can hold all values (byte, halfword, or word), **shrinks** the array in place to that smaller size, then **stretches** it back out into a new array of doublewords (64-bit values stored as two 32-bit words) saved in a separate output buffer.

---

## `.data` Section

```asm
myarr:   .word 10, 20, 30, 40
myarr2: .word 1,2,4,8,16,32,64,128,256,512
output: .space 80    # 10 elements * 8 bytes per doubleword
```

- **`myarr`** — a 4-element word array for testing (all values fit in a byte).
- **`myarr2`** — a 10-element word array used as the active test input (values up to 512, which requires a halfword).
- **`output`** — 80 bytes of reserved space to hold the final doubleword-expanded array (10 elements × 8 bytes each).

---

## `.text` Section

### Initialization

```asm
la a3, myarr2     # base address of input array → a3
li a4, 10         # array length → a4
mv a5, a3         # save original base address in a5
mv t0, a4         # iteration counter → t0
addi t1, x0, 0   # t1 = current max element size (0 = unknown)
```

- `a3` is the **read pointer** into the array.
- `a4` holds the **array length** (10).
- `a5` permanently holds the **original base address** so it can be restored later.
- `t0` is a **countdown counter** used in loops.
- `t1` tracks the **minimum required data size** across all elements: `1` = byte, `2` = halfword, `4` = word.

---

### Phase 1 — Iterate and Determine Minimum Size

#### `iterate_array` loop

```asm
iterate_array:
    beq t0, x0, shrink    # if counter == 0, all elements checked → go to shrink
    lw a6, 0(a3)          # load current element (word) into a6
    addi a3, a3, 4        # advance read pointer by 4 bytes (next word)
    addi t0, t0, -1       # decrement counter
```

- Reads one word at a time from the array.
- Falls through into `check_size` for each element.

#### `check_size`

```asm
check_size:
    li a7, 1
    li t3, 256
    bltu a6, t3, update_max   # if value < 256, fits in a byte → a7 = 1
    li a7, 2
    lui t3, 16                # t3 = 65536 (0x10000)
    bltu a6, t3, update_max   # if value < 65536, fits in a halfword → a7 = 2
    li a7, 4                  # otherwise needs a full word → a7 = 4
```

- Tests the current element against thresholds using **unsigned** comparisons (`bltu`):
  - `< 256` → fits in 1 byte
  - `< 65536` → fits in a halfword (2 bytes)
  - Otherwise → needs a full word (4 bytes)
- `a7` holds the size classification for this element.

#### `update_max`

```asm
update_max:
    bge t1, a7, iterate_array   # if current max already >= this element's size, skip update
    mv t1, a7                   # otherwise update max required size
    j iterate_array
```

- Only updates `t1` if the current element requires a **larger** size than previously seen.
- After the loop completes, `t1` holds the minimum data size required for the **entire** array.

---

### Phase 2 — Shrink the Array In Place

```asm
shrink:
    mv a3, a5         # reset read pointer to base
    mv t2, a5         # write pointer also starts at base (in-place shrink)
    mv t0, a4         # reset element counter
    li a6, 4
    beq t1, a6, stretch   # if min size is already word (4), skip shrinking
```

- Resets pointers and counter.
- If all elements require a full word, there is nothing to shrink — jumps straight to stretch.

#### `shrink_loop`

```asm
shrink_loop:
    beq t0, x0, stretch   # if counter == 0, done shrinking
    lw a6, 0(a3)          # load element as word
    addi a3, a3, 4        # advance read pointer
    addi t0, t0, -1       # decrement counter
    li a7, 1
    beq t1, a7, store_byte    # if min size is byte, store as byte
    sh a6, 0(t2)          # halfword case: store lower 2 bytes
    addi t2, t2, 2        # advance write pointer by 2
    j shrink_loop
```

- Reads each element as a full word.
- If `t1 == 1` (byte), branches to `store_byte`.
- If `t1 == 2` (halfword), stores the lower 2 bytes with `sh` and advances write pointer by 2.

#### `store_byte`

```asm
store_byte:
    sb a6, 0(t2)      # store lowest byte of element
    addi t2, t2, 1    # advance write pointer by 1
    j shrink_loop
```

- Stores only the lowest byte of each element.
- After this loop, the data starting at `a5` is packed tightly in the smallest format.

---

### Phase 3 — Stretch to Doubleword Array

```asm
stretch:
    mv t2, a5         # read pointer = base of shrunk data
    la t3, output     # write pointer = output buffer
    mv t0, a4         # reset element counter
```

- `t2` reads from the packed (shrunk) data.
- `t3` writes into the `output` buffer.

#### `stretch_loop`

```asm
stretch_loop:
    beq t0, x0, end       # if counter == 0, done
    li a7, 1
    beq t1, a7, load_byte     # if byte size, branch to load_byte
    li a7, 2
    beq t1, a7, load_half     # if halfword size, branch to load_half
    lw a6, 0(t2)          # word case: load 4 bytes
    addi t2, t2, 4        # advance read pointer by 4
    j store_dword
```

- Dispatches to the appropriate load instruction based on the minimum size `t1`.

#### `load_byte`

```asm
load_byte:
    lbu a6, 0(t2)     # load 1 byte, zero-extended
    addi t2, t2, 1
    j store_dword
```

#### `load_half`

```asm
load_half:
    lhu a6, 0(t2)     # load 2 bytes, zero-extended
    addi t2, t2, 2
```

- Falls through into `store_dword`.

#### `store_dword`

```asm
store_dword:
    sw a6, 0(t3)      # store value as lower 32-bit word
    sw x0, 4(t3)      # store 0 as upper 32-bit word
    addi t3, t3, 8    # advance write pointer by 8 bytes (one doubleword)
    addi t0, t0, -1   # decrement counter
    j stretch_loop
```

- Each element is zero-extended to a 64-bit doubleword by writing the value in the low word and `0` in the high word.
- The output buffer advances by 8 bytes per element.

---

### Exit

```asm
end:
    addi a0, x0, 10
    ecall
```

- **`addi a0, x0, 10`** — sets `a0` to `10`, the syscall number for **exit** in RARS/MARS.
- **`ecall`** — terminates the program.

---

## Summary of Data Flow

```
myarr2 (words)
    ↓  iterate_array / check_size
  Determine min element size (t1 = 2 for myarr2, since max value is 512)
    ↓  shrink_loop
  Pack array in place as halfwords: [1,2,4,8,16,32,64,128,256,512] → 20 bytes
    ↓  stretch_loop / store_dword
  Expand each halfword to a doubleword in output buffer: 10 × 8 = 80 bytes
```
