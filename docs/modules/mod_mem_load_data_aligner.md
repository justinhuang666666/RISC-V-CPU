# Entity: mod_mem_load_data_aligner

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
- This module performs the shifting and sign-extension required for the above statement to be satisfied.
- In this example, `memory_address_unaligned_i = 0x3`, `memory_readdata_i = 0x8F000000`, `aligned_value_o = 0xFFFFFF8F`

Hint: remember that data inputs and outputs from the memory controller are in little-endian format.

- **File**: mod_mem_load_data_aligner.sv

## Diagram

![Diagram](mod_mem_load_data_aligner.svg "Diagram")

## Ports

| Port name                  | Direction | Type                | Description |
| -------------------------- | --------- | ------------------- | ----------- |
| funct3_i                   | input     | [`FUNCT3_WIDTH-1:0] | The funct3 part of the instruction being executed. This indicates the type of load, such as `lb/lbu/lh/lhu/lw`. |
| memory_address_unaligned_i | input     | [`XLEN-1:0]         | An unaligned memory address to load from, generally computed from a register plus an immediate value. |
| memory_readdata_i          | input     | [`XLEN-1:0]         | The data read from the word-aligned address corresponding to memory_address_unaligned_i.  |
| aligned_value_o            | output    | [`XLEN-1:0]         | The corrected (shifted plus potentially sign-extended) value that can be directly loaded into the destination register. See the above example for more information. |
