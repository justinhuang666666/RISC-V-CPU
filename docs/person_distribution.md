Person 1:
mod_alu: All arithmetic/bitwise instructions (excl. muldiv)
mod_ex: Multiplexes between the ALU and muldiv units
mod_muldiv: Implements a multi-cycle multiplier and divider (how do we test this is multi cycle?)
mod_mem_load_data_aligner: Shifts a memory value such that it is written to the register file correctly for the chosen byte-offset (unaligned accesses are supported by RISC-V but not us, to avoid overloading the memory person)
mod_mem_store_data_aligner: Shifts a register value such that it is written to memory correctly for the chosen byte-offset (unaligned accesses are supported by RISC-V but not us, to avoid overloading the memory person)

Person 2:
mod_hazard: Hazard control logic
mod_id2ex: Pipeline register
mod_if2id: Pipeline register
mod_ex2mem: Pipeline register
mod_mem2wb: Pipeline register
mod_control: Memory and most branch control signals
mod_instr_decode: ID logic (immediate/funct3/funct7/opcode)
mod_stall_control: Control logic for stall operations

Person 3:
mod_pc: Program counter
mod_reg_file: GPR Register file
mod_csr_reg_file: Register file for CSR registers
mod_trap: Traps and exception

Person 4:
mod_mem_byteenable: Control signals for cache byte-enables
mod_mem_cache: Not required to be implemented by the students. It is a generic cache module which is reused by the data and instruction cache.
mod_mem_ctrl: Bus arbitration logic for IF and MEM cache access to the memory bus (with priority for MEM).
mod_mem_data_cache: Data cache
mod_mem_instruction_cache: Instruction cache

Given:
mod_cpu: Top level diagram
