#ifndef defines_H 
#define defines_H

// Basic system parameters as outlined in Vol.1 Chap.1 of the RISC-V ISA
// -------------------------------------------------------------------------------------
#define XLEN    32 // width of integer register in bits
#define IALIGN  32 // instruction-address alignment constraint for this implementation
#define ILEN    32 // maximum instruction length supported by implementation
// -------------------------------------------------------------------------------------

// RISC-V Instruction opcode
// -------------------------------------------------------------------------------------
#define OP_LUI          0b0110111
#define OP_AUIPC        0b0010111
#define OP_JAL          0b1101111
#define OP_JALR         0b1100111
#define OP_BRANCH       0b1100011
#define OP_LOAD         0b0000011
#define OP_STORE        0b0100011
#define OP_IMM          0b0010011
#define OP_OP           0b0110011
#define OP_MISC_MEM     0b0001111
#define OP_MULDIV       0b0110011
// -------------------------------------------------------------------------------------

// RISC-V Instrcution funct3 
// -------------------------------------------------------------------------------------
#define FUNCT3_ADDI      0b000 // IMMEDIATE
#define FUNCT3_SLTI      0b010
#define FUNCT3_SLTIU     0b011
#define FUNCT3_XORI      0b100
#define FUNCT3_ORI       0b110
#define FUNCT3_ANDI      0b111
#define FUNCT3_SLLI      0b001
#define FUNCT3_SRLI_SRAI 0b101
#define FUNCT3_ADD_SUB   0b000 // REGISTER
#define FUNCT3_SLL       0b001
#define FUNCT3_SLT       0b010
#define FUNCT3_SLTU      0b011
#define FUNCT3_XOR       0b100
#define FUNCT3_SRL_SRA   0b101
#define FUNCT3_OR        0b110
#define FUNCT3_AND       0b111
#define FUNCT3_LB        0b000 // LOAD
#define FUNCT3_LH        0b001
#define FUNCT3_LW        0b010
#define FUNCT3_LBU       0b100
#define FUNCT3_LHU       0b101
#define FUNCT3_SB        0b000 // STORE
#define FUNCT3_SH        0b001
#define FUNCT3_SW        0b010
#define FUNCT3_BEQ       0b000 // BRANCH
#define FUNCT3_BNE       0b001
#define FUNCT3_BLT       0b100
#define FUNCT3_BGE       0b101
#define FUNCT3_BLTU      0b110
#define FUNCT3_BGEU      0b111
#define FUNCT3_JALR      0b000 // JALR
#define FUNCT3_MUL       0b000 //MUL
#define FUNCT3_MULH      0b001
#define FUNCT3_MULHSU    0b010
#define FUNCT3_MULHU     0b011
#define FUNCT3_DIV       0b100  //DIV
#define FUNCT3_DIVU      0b101
#define FUNCT3_REM       0b110
#define FUNCT3_REMU      0b111
// -------------------------------------------------------------------------------------

// RISC-V Instruction funct7 
// -------------------------------------------------------------------------------------
#define FUNCT7_ADD       0b0000000
#define FUNCT7_SUB       0b0100000
#define FUNCT7_SLL       0b0000000
#define FUNCT7_SLT       0b0000000
#define FUNCT7_SLTU      0b0000000
#define FUNCT7_XOR       0b0000000
#define FUNCT7_SRL       0b0000000
#define FUNCT7_SRA       0b0100000
#define FUNCT7_OR        0b0000000
#define FUNCT7_AND       0b0000000
#define FUNCT7_SRLI      0b0000000
#define FUNCT7_SRAI      0b0100000
#define FUNCT7_SLLI      0b0000000
#define FUNCT7_MULDIV    0b0000001
// -------------------------------------------------------------------------------------


// Instruction decode parameters  
// -------------------------------------------------------------------------------------
#define FUNCT7_WIDTH    7 // width of funct7 bit field 
#define FUNCT3_WIDTH    3 // width of funct3 bit field 
#define OPCODE_WIDTH    7 // width of opcode bit field 
// -------------------------------------------------------------------------------------

// Register file parameters
// -------------------------------------------------------------------------------------
#define REG_FILE_SZ     32 // amount of general-purpose registers in register file
#define REG_ADDR_WIDTH  5  // width of register address bus
// -------------------------------------------------------------------------------------

#endif 