# Entity: mod_mem_instruction_cache 

- **File**: mod_mem_instruction_cache.sv

## Diagram

![Diagram](mod_mem_instruction_cache.svg "Diagram")

## Ports

| Port name              | Direction | Type        | Description |
| ---------------------- | --------- | ----------- | ----------- |
| clk_i                  | input     |             | Global clock |
| rst_i                  | input     |             | Global reset signal |
| abort_i                | input     |             | Cancels the current instruction load. For this to have any effect, a read transaction must be in-progress. Once cancelled, `busy_o` should remain LOW until the next transaction, such that another transaction can be made. Hint: there is no mechanism to cancel a on-going memory transaction; as such, if a memory bus transaction is taking place, `busy_o` must remain HIGH until the next clock edge where `memory_operation_stb_i` is HIGH, as this signals the end of the memory bus transaction. At this point, the result can be discarded by never setting `stb_o` to HIGH. |
| address_i              | input     | [`XLEN-1:0] | The word-aligned address of the instruction to perform a load/store operation on. Once busy_o goes HIGH, this input is allowed to change with no effect the on-going transaction. |
| read_i                 | input     |             | Starts a read operation from the cache. If the cache does contain the data for that address, then this module must request the data from the memory bus. Once busy_o goes HIGH, this input is allowed to change with no effect to the on-going transaction. |
| readdata_o             | output    | [`XLEN-1:0] | The word-aligned instruction, retrieved from the data located at instruction_address_i. |
| stb_o                  | output    |             | HIGH if readdata_o is valid, hence an instruction load is complete. |
| address_o              | output    | [`XLEN-1:0] | The address that readdata_o corresponds to. Only valid when stb_o is HIGH. |
| busy_o                 | output    |             | Indicates that a read is in progress. A transaction will not be accepted while this signal is HIGH. |
| memory_readdata_i      | input     | [`XLEN-1:0] | Used for reading from the memory bus if the value is not in the cache. This is the Wishbone 4B compliant signal for... |
| memory_operation_stb_i | input     |             | Used for reading from the memory bus if the value is not in the cache. This is the Wishbone 4B compliant signal for... |
| memory_address_o       | output    | [`XLEN-1:0] | Used for reading from the memory bus if the value is not in the cache. This is the Wishbone 4B compliant signal for... |
| memory_read_o          | output    |             | Used for reading from the memory bus if the value is not in the cache. This is the Wishbone 4B compliant signal for... |
