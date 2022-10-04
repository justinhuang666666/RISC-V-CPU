# Entity: mod_mem_store_data_aligner

While the RISC-V ISA allows for unaligned memory access (e.g. loading data from a non-word-aligned address), this adds extra complexity to the memory and cache modules. As such, you are not expected to implement this, nor should you.

However, it is still the case that all loads and stores must be aligned to their respective operation.

This means that:

- All LW/SW instructions must comply with the following condition: (address % 4) == 0
- All LH/SH/etc. instructions must comply with the following condition: (address % 2) == 0

In the case that the instruction under execution provides an address that does not satisfy these conditions, your CPU is allowed to exhibit undefined behaviour. In otherwords, it is allowed to do anything reasonable (e.g. terminate the simulation).

While word-aligned address must be passed to the Wishbone memory bus, the instruction being executed may request a load-byte operation at a non-word aligned address.

For example:

- `lb t0, 3(zero)` would load the byte at address 0x3 `($zero + 3 = 0x3)` into the register t0
- The word-aligned address that should be passed to the Wishbone interface is 0x0, with a byte-enable (Wishboine sel) signal of 0b1000.
- As such, the data would be returned in the top 8 bits of the Wishbone bus data input; however, the `lb` instruction requires this value to be loaded into the lower 8 bits of register `t0`, as well as sign-extended.

This module implements similar behaviour, however for store operations instead of loads.

Hint: read the specification for `mod_mem_load_data_aligner` aligner and implement that first, then consider how the opposite applies for store operations.

- **File**: mod_mem_store_data_aligner.sv

## Diagram

![Diagram](mod_mem_store_data_aligner.svg "Diagram")

## Ports

| Port name                  | Direction | Type                | Description |
| -------------------------- | --------- | ------------------- | ----------- |
| funct3_i                   | input     | [`FUNCT3_WIDTH-1:0] | The funct3 part of the instruction being executed. This indicates the type of load, such as `sb/sh/sw`. |
| memory_address_unaligned_i | input     | [`XLEN-1:0]         | An unaligned memory address to store to, generally computed from a register plus an immediate value. |
| register_value_i           | input     | [`XLEN-1:0]         | The register value to be written to the word-aligned address corresponding to memory_address_unaligned_i. |
| aligned_value_o            | output    | [`XLEN-1:0]         | The corrected (shifted plus masked) value that can be passed to the memory controller, with an appropriate byte-enable / `sel` signal to indicate what bytes should be written to. |
