# Lab 5 Walkthrough

## Simple Explanation

### Endian Swap

Think of a number like `0x12345678` as four separate bytes: `12`, `34`, `56`, `78`. RISC-V stores them in memory backwards (little-endian), so they appear as `78 56 34 12`. This program just reverses that order so they read `12 34 56 78` instead. It reads each byte one at a time, then writes them back in the opposite positions — byte 0 goes to position 3, byte 1 to position 2, and so on.

### Stretchy Array

This program does two things to an array of numbers:

1. **Shrink it** — Every number in the array starts as a 4-byte word, but small numbers like 10 or 40 only need 1 byte, and medium numbers like 512 only need 2 bytes. The program figures out the smallest size that fits every number in the array, then rewrites the array in place using that smaller size. This saves memory.

2. **Stretch it** — After shrinking, it reads the compacted data back out and writes each number into a new location as an 8-byte doubleword (the value in the first 4 bytes, zeros in the upper 4 bytes). This is stored in a separate output buffer so the shrunk data isn't overwritten.

For example, `{10, 20, 30, 40}` all fit in 1 byte each, so the array gets packed from 16 bytes down to 4 bytes, then expanded out to 32 bytes of doublewords in the output buffer.

---

## Program 1: Endian Swap (`endianswap_starter.s`)

This program swaps a 32-bit word from little-endian to big-endian byte order, in place in memory.

### Data

- `num1`: `0x12345678`
- `num2`: `-2` (which is `0xFFFFFFFE` in two's complement)

### How it works

RISC-V stores words in little-endian order, so `0x12345678` sits in memory as bytes `78 56 34 12` (least-significant byte first). The goal is to reverse the byte order so the memory reads `12 34 56 78` instead.

1. **Load the base addresses** of `num1` and `num2` into `t0` and `t3`.
2. **Read all four bytes individually** using `lbu` (load byte unsigned) at offsets 0, 1, 2, and 3.
   - `t1` = byte 0 (LSB), `t2` = byte 1, `t4` = byte 2, `t5` = byte 3 (MSB)
3. **Write them back in reversed positions** using `sb` (store byte):
   - Byte 3 (MSB) goes to offset 0
   - Byte 2 goes to offset 1
   - Byte 1 goes to offset 2
   - Byte 0 (LSB) goes to offset 3
4. Repeat the same process for `num2`.

### Expected results

| Value | Before (in memory) | After (in memory) |
|-------|--------------------|--------------------|
| `num1 = 0x12345678` | `78 56 34 12` | `12 34 56 78` |
| `num2 = 0xFFFFFFFE` | `FE FF FF FF` | `FF FF FF FE` |

After the swap, loading `num1` as a word gives `0x78563412`, and loading `num2` gives `0xFEFFFFFF`.

---

## Program 2: Stretch and Shrink Array (`stretchy_array_starter.s`)

This program takes an array of 32-bit words, determines the smallest data type that can hold every value, shrinks the array in place, and then stretches it out into a 64-bit (doubleword) array in a separate output buffer.

### Data

- `myarr`: `{10, 20, 30, 40}` (4 elements)
- `myarr2`: `{1, 2, 4, 8, 16, 32, 64, 128, 256, 512}` (10 elements)
- `output`: 80 bytes of reserved space for the stretched doubleword output

By default, the program runs on `myarr`. To test `myarr2`, uncomment lines 12-13.

### Register map

| Register | Purpose |
|----------|---------|
| `a3` | Read pointer (walks through the array) |
| `a4` | Array length (constant) |
| `a5` | Saved original base address of the array |
| `a6` | Current element / temporary |
| `t0` | Loop counter |
| `t1` | Smallest data size: 1 = byte, 2 = halfword, 4 = word |
| `t2` | Write pointer (shrink phase) / read pointer (stretch phase) |
| `t3` | Write pointer into the output buffer (stretch phase) |
| `a7` | Temporary used in shrink dispatch |

### Phase 1: Determine smallest data size

The loop at `iterate_array` walks through every word in the array and classifies each value:

1. **Load the word** and right-shift it by 8 bits (`srli a6, a6, 8`).
   - If the result is zero, the original value fit in 8 bits (0-255), so it's a **byte** (`fit_byte`).
2. **Shift another 8 bits** (16 total from the original).
   - If zero, the value fit in 16 bits (0-65535), so it's a **halfword** (`fit_half`).
3. Otherwise, it needs a full **word** (`fit_word`).

`t1` only ever increases. Each `fit_*` handler checks whether `t1` is already large enough before upgrading it. This ensures `t1` holds the size needed by the *largest* element after the loop finishes.

- `myarr` max = 40, fits in a byte, so `t1 = 1`
- `myarr2` max = 512, needs a halfword, so `t1 = 2`

### Phase 2: Shrink in place

The `shrink` phase re-reads the original words and writes them back to the same memory location using the smaller data type:

- If `t1 = 1` (byte): each word is stored as 1 byte with `sb`, write pointer advances by 1.
- If `t1 = 2` (halfword): each word is stored as 2 bytes with `sh`, write pointer advances by 2.
- If `t1 = 4` (word): no shrinking needed, this phase is skipped entirely.

This in-place shrink is safe because the read pointer (`a3`) advances by 4 bytes per element while the write pointer (`t2`) advances by only 1 or 2, so reads always stay ahead of writes.

**Example with `myarr` (t1=1, byte):**

| Before (words) | After (bytes at same address) |
|----------------|-------------------------------|
| `0A 00 00 00 \| 14 00 00 00 \| 1E 00 00 00 \| 28 00 00 00` | `0A 14 1E 28` (first 4 bytes) |

### Phase 3: Stretch to doublewords

The `stretch` phase reads from the shrunk data and writes each value as a 64-bit doubleword to the `output` buffer:

- If `t1 = 1`: reads with `lbu` (load byte unsigned), advances read pointer by 1.
- If `t1 = 2`: reads with `lhu` (load halfword unsigned), advances by 2.
- If `t1 = 4`: reads with `lw` (load word), advances by 4.

Each value is stored as a doubleword by writing the value to the low 4 bytes (`sw a6, 0(t3)`) and zero to the high 4 bytes (`sw x0, 4(t3)`), then advancing the write pointer by 8.

**Example with `myarr` (t1=1):**

The output buffer contains 4 doublewords (32 bytes):

| Element | Low word | High word |
|---------|----------|-----------|
| 10 | `0x0000000A` | `0x00000000` |
| 20 | `0x00000014` | `0x00000000` |
| 30 | `0x0000001E` | `0x00000000` |
| 40 | `0x00000028` | `0x00000000` |

### Verification steps

1. Open the file in the Venus simulator.
2. Note the data memory layout at `myarr`/`myarr2` and `output` addresses before running.
3. Run with `myarr` (default) and inspect:
   - `t1` should be `1`.
   - The first 4 bytes at `myarr`'s address should be `0A 14 1E 28`.
   - The `output` buffer should contain the 4 doublewords above.
4. Uncomment lines 12-13 to switch to `myarr2`, run again, and inspect:
   - `t1` should be `2`.
   - 10 halfwords (20 bytes) stored at `myarr2`'s address.
   - 10 doublewords (80 bytes) in the `output` buffer.
