# Endian Swap — Line-by-Line Explanation

## Overview

This RISC-V assembly program performs an **in-place endian swap** on two 32-bit integers stored in memory. It converts each number from little-endian to big-endian byte order (or vice versa) by reversing the order of the four bytes that make up each word.

For example, `0x12345678` stored at address `0x10000000` becomes `0x78563412` at the same address.

---

## `.data` Section

```asm
num1: .word 0x12345678
num2: .word -2
```

- **`num1`** — declares a 32-bit word with the value `0x12345678` and labels its address `num1`.
- **`num2`** — declares a 32-bit word with the value `-2` (i.e., `0xFFFFFFFE`) and labels its address `num2`.

---

## `.text` Section

### Load Addresses

```asm
la t0, num1
la t3, num2
```

- **`la t0, num1`** — loads the memory address of `num1` into register `t0`.
- **`la t3, num2`** — loads the memory address of `num2` into register `t3`.

---

### Swapping `num1`

```asm
lbu t1, 0(t0)   # byte 0 (LSB)
lbu t2, 1(t0)   # byte 1
lbu t4, 2(t0)   # byte 2
lbu t5, 3(t0)   # byte 3 (MSB)
```

- **`lbu`** (load byte unsigned) reads a single byte from the given address into a register, zero-extending it to 32 bits.
- The four `lbu` instructions read each of the four bytes of `num1` into separate registers:
  - `t1` ← byte at offset 0 (the least-significant byte)
  - `t2` ← byte at offset 1
  - `t4` ← byte at offset 2
  - `t5` ← byte at offset 3 (the most-significant byte)

```asm
sb t5, 0(t0)   # write old MSB → byte 0
sb t4, 1(t0)   # write old byte 2 → byte 1
sb t2, 2(t0)   # write old byte 1 → byte 2
sb t1, 3(t0)   # write old LSB → byte 3
```

- **`sb`** (store byte) writes the lowest byte of a register back to the given memory address.
- The four `sb` instructions write the bytes back in **reversed** order, completing the swap in place.

For `0x12345678`:
| Offset | Before | After |
|--------|--------|-------|
| 0      | `0x78` | `0x12` |
| 1      | `0x56` | `0x34` |
| 2      | `0x34` | `0x56` |
| 3      | `0x12` | `0x78` |

Result: `0x78563412` → becomes `0x12345678` at the same address (the swap is its own inverse).

---

### Swapping `num2`

```asm
lbu t1, 0(t3)   # byte 0 (LSB)
lbu t2, 1(t3)   # byte 1
lbu t4, 2(t3)   # byte 2
lbu t5, 3(t3)   # byte 3 (MSB)
sb  t5, 0(t3)   # write old MSB → byte 0
sb  t4, 1(t3)   # write old byte 2 → byte 1
sb  t2, 2(t3)   # write old byte 1 → byte 2
sb  t1, 3(t3)   # write old LSB → byte 3
```

- Identical logic applied to `num2` (value `-2` = `0xFFFFFFFE`).
- After the swap, memory contains `0xFEFFFFFF` at the address of `num2`.

---

### Exit

```asm
li a0, 10
ecall
```

- **`li a0, 10`** — loads the immediate value `10` into register `a0`. In RARS/MARS simulators, syscall `10` is the **exit** call.
- **`ecall`** — triggers the environment call, terminating the program.
