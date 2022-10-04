# Entity: mod_mem_byteenable

When writing to memory, it is obviously important to make sure you are only writing to the exact bytes specified by the instruction.

For example, if you had a `sh` (store half-word) instruction, you should only be writing to exactly two bytes of memory.

However, the memory controller requires a word-aligned address to be provided to it. As such, a byte-enable or Wishbone compliant `sel` signal can be used to target the specific bytes that should be affected by the operation.

While this example just considers writes, it is also important to consider reads. But why would a read ever modify data? In our case, we mainly only think about using the memory bus to access RAM, however in real-world configurations it is the case that several MMIO peripherals (memory-mapped input-output) will also accessible via the memory bus. Consider the case of a MMIO network card which can be acccessed at addresss `0x7F000000`. Let's say that if you read from this address, the network card will return up-to the next four bytes of the current raw ethernet packet buffer. However, once this address is read from, the network card will discard the data and present the next few bytes of the packet buffer for subsequent read requests. If your program was to perform a `load byte` instruction instead of a `load word`, this would mean that you would be potentially losing three bytes of data per request, if the select/byte-enable signal was incorrect. In this example, the network card uses the select signal to determine which bytes to read and hence is only allowed to discard those bytes.

This module takes an unaligned address, word-aligns it and then produces the correct byte-enable or Wishbone `sel` signal to read from or write to the correct bytes, offset from the aligned address.

Hint: remember that the data returned over the Wishbone interface is in little-endian. Hence the least signficant byte of a word (offset 3) is in the top 8 bits of the data input/output. Each bit of the select signal corresponds to each byte in the word-value: for example, the topmost bit in the select signal corresponds to the leftmost byte of the data input/output of the memory controller.

- **File**: mod_mem_byteenable.sv

## Diagram

![Diagram](mod_mem_byteenable.svg "Diagram")

## Ports

| Port name                  | Direction | Type                    | Description |
| -------------------------- | --------- | ----------------------- | ----------- |
| funct3_i                   | input     | [`FUNCT3_WIDTH-1:0]     | The funct3 part of the instruction being executed. This indicates the type of load or store. |
| memory_address_unaligned_i | input     | [`XLEN-1:0]             | An unaligned memory address to store to load from or store to, generally computed from a register plus an immediate value. |
| memory_address_aligned_o   | output    | [`XLEN-1:0]             | The word-aligned address to load from or store to. Computed directly from `memory_address_unaligned_i`. |
| memory_byteenable_o        | output    | [`BYTEENABLE_WIDTH-1:0] | The byte-enable or Wishbone compliant select signal used to choose which bytes of the word at the aligned address to load from or store to. |
