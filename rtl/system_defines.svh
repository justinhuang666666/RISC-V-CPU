`ifndef SYSTEM_DEFINES_SVH
`define SYSTEM_DEFINES_SVH

// Basic system parameters as outlined in Vol.1 Chap.1 of the RISC-V ISA
// -------------------------------------------------------------------------------------
`define XLEN    32 // width of integer register in bits
`define IALIGN  32 // instruction-address alignment constraint for this implementation
`define ILEN    32 // maximum instruction length supported by implementation
// -------------------------------------------------------------------------------------

// RISC-V Instruction opcode
// -------------------------------------------------------------------------------------
`define OP_LUI          7'b0110111
`define OP_AUIPC        7'b0010111
`define OP_JAL          7'b1101111
`define OP_JALR         7'b1100111
`define OP_BRANCH       7'b1100011
`define OP_LOAD         7'b0000011
`define OP_STORE        7'b0100011
`define OP_IMM          7'b0010011
`define OP_OP           7'b0110011
`define OP_MISC_MEM     7'b0001111
`define OP_MULDIV       7'b0110011
// -------------------------------------------------------------------------------------

// RISC-V Instrcution funct3 
// -------------------------------------------------------------------------------------
`define FUNCT3_ADDI      3'b000 // IMMEDIATE
`define FUNCT3_SLTI      3'b010
`define FUNCT3_SLTIU     3'b011
`define FUNCT3_XORI      3'b100
`define FUNCT3_ORI       3'b110
`define FUNCT3_ANDI      3'b111
`define FUNCT3_SLLI      3'b001
`define FUNCT3_SRLI_SRAI 3'b101
`define FUNCT3_ADD_SUB   3'b000 // REGISTER
`define FUNCT3_SLL       3'b001
`define FUNCT3_SLT       3'b010
`define FUNCT3_SLTU      3'b011
`define FUNCT3_XOR       3'b100
`define FUNCT3_SRL_SRA   3'b101
`define FUNCT3_OR        3'b110
`define FUNCT3_AND       3'b111
`define FUNCT3_LB        3'b000 // LOAD
`define FUNCT3_LH        3'b001
`define FUNCT3_LW        3'b010
`define FUNCT3_LBU       3'b100
`define FUNCT3_LHU       3'b101
`define FUNCT3_SB        3'b000 // STORE
`define FUNCT3_SH        3'b001
`define FUNCT3_SW        3'b010
`define FUNCT3_BEQ       3'b000 // BRANCH
`define FUNCT3_BNE       3'b001
`define FUNCT3_BLT       3'b100
`define FUNCT3_BGE       3'b101
`define FUNCT3_BLTU      3'b110
`define FUNCT3_BGEU      3'b111
`define FUNCT3_JALR      3'b000 // JALR
`define FUNCT3_MUL       3'b000 //MUL
`define FUNCT3_MULH      3'b001
`define FUNCT3_MULHSU    3'b010
`define FUNCT3_MULHU     3'b011
`define FUNCT3_DIV       3'b100  //DIV
`define FUNCT3_DIVU      3'b101
`define FUNCT3_REM       3'b110
`define FUNCT3_REMU      3'b111
// -------------------------------------------------------------------------------------

// RISC-V Instruction funct7 
// -------------------------------------------------------------------------------------
`define FUNCT7_ADD       7'b0000000
`define FUNCT7_SUB       7'b0100000
`define FUNCT7_SLL       7'b0000000
`define FUNCT7_SLT       7'b0000000
`define FUNCT7_SLTU      7'b0000000
`define FUNCT7_XOR       7'b0000000
`define FUNCT7_SRL       7'b0000000
`define FUNCT7_SRA       7'b0100000
`define FUNCT7_OR        7'b0000000
`define FUNCT7_AND       7'b0000000
`define FUNCT7_SRLI      7'b0000000
`define FUNCT7_SRAI      7'b0100000
`define FUNCT7_SLLI      7'b0000000
`define FUNCT7_MULDIV    7'b0000001
// -------------------------------------------------------------------------------------

// Memory bus parameters
// -------------------------------------------------------------------------------------
`define BYTEENABLE_WIDTH 4 // width of the byte-enable field for memory bus operations 
// -------------------------------------------------------------------------------------

// Instruction decode parameters  
// -------------------------------------------------------------------------------------
`define FUNCT7_WIDTH    7 // width of funct7 bit field 
`define FUNCT3_WIDTH    3 // width of funct3 bit field 
`define OPCODE_WIDTH    7 // width of opcode bit field 
// -------------------------------------------------------------------------------------

// Register file parameters
// -------------------------------------------------------------------------------------
`define REG_FILE_SZ     32 // amount of general-purpose registers in register file
`define REG_ADDR_WIDTH  5  // width of register address bus
// -------------------------------------------------------------------------------------

// CSR Register file parameters
// -------------------------------------------------------------------------------------
`define CSR_ADDR_WIDTH  12  // width of CSR register address bus
// -------------------------------------------------------------------------------------

// CSR Register file address defines
// -------------------------------------------------------------------------------------
`define MVENDORID_ADDR `CSR_ADDR_WIDTH'hF11
`define MARCHID_ADDR `CSR_ADDR_WIDTH'hF12
`define MIMPID_ADDR `CSR_ADDR_WIDTH'hF13
`define MHARTID_ADDR `CSR_ADDR_WIDTH'hF14

`define MISA_ADDR `CSR_ADDR_WIDTH'h301
`define MIE_ADDR `CSR_ADDR_WIDTH'h304
`define MTVEC_ADDR `CSR_ADDR_WIDTH'h305

`define MEPC_ADDR `CSR_ADDR_WIDTH'h341
`define MCAUSE_ADDR `CSR_ADDR_WIDTH'h342
`define MTVAL_ADDR `CSR_ADDR_WIDTH'h343
`define MIP_ADDR `CSR_ADDR_WIDTH'h344
// -------------------------------------------------------------------------------------

// PC Reset paramters
// -------------------------------------------------------------------------------------
`define PC_RESET_ADDR `XLEN'hBFC00000
// -------------------------------------------------------------------------------------

`endif
