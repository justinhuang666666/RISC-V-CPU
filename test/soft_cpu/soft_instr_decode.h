#include "../defines.h"
#include <stdint.h>

// This is a "soft" isntruction decode module implemented in C++

class Soft_Instr_Decode
{
public:
    uint8_t funct7_o;
    uint8_t rs2_o;
    uint8_t rs1_o;
    uint8_t funct3_o;
    uint8_t rd_o;
    uint8_t opcode_o;
    uint32_t immediate_o;

    // This function is used to extend bits
    // This is equivalent to {size{bit}} in verilog
    // Inputting a number larger than 32 in the "size" parameter might cause an exception in the OS
    uint32_t bit_extend(uint8_t bit, int size)
    {
        // Shift and OR with starting bit to concatenate
        if (bit != 0)
            return (1 << size) - 1;
        else
            return 0;
    }

    // This function is used to select bits
    // If sel_msb = sel_lsb, will output that single bit
    // This is equivalent to bit_src[sel_msb:sel_lsb] in verilog
    uint32_t bit_select(uint32_t bit_src, int sel_msb, int sel_lsb)
    {
        int start = sel_lsb + 1, end = sel_msb + 1;
        // Using Shift and AND to acquire selected bits
        const int mask = (1 << (end - start + 1)) - 1;
        const int shift = start - 1;
        return (bit_src & (mask << shift)) >> shift;
    }

    Soft_Instr_Decode(uint32_t instr_i)
    {

        // Refering to The RISC-V Instruction Set Manual 2.2 page 12
        // Figure 2.3: RISC-V base instruction formats showing immediate variants.
        funct7_o = bit_select(instr_i, 31, 25); // Selecting instr_i[31:25]
        rs2_o = bit_select(instr_i, 24, 20);    // Selecting instr_i[24:20]
        rs1_o = bit_select(instr_i, 19, 15);    // Selecting instr_i[19:15]
        funct3_o = bit_select(instr_i, 14, 12); // Selecting instr_i[14:12]
        rd_o = bit_select(instr_i, 11, 7);      // Selecting instr_i[11:7]
        opcode_o = bit_select(instr_i, 6, 0);   // Selecting instr_i[6:0]

        // The immediates are generated via a switch statement
        // The bits are concatenated with shifts
        // Refering to The RISC-V Instruction Set Manual 2.2 page 12
        // Figure 2.4  Types of immediate produced by RISC-V instructions.
        uint32_t i_immediate = ((bit_extend(bit_select(instr_i, 31, 31), 20) << 12) |
                                bit_select(instr_i, 31, 20));
        uint32_t s_immediate = ((bit_extend(bit_select(instr_i, 31, 31), 20) << 12) |
                                (bit_select(instr_i, 31, 25) << 5) |
                                bit_select(instr_i, 11, 7));
        uint32_t b_immediate = ((bit_extend(bit_select(instr_i, 31, 31), 20) << 12) |
                                (bit_select(instr_i, 7, 7) << 11) |
                                (bit_select(instr_i, 30, 25) << 5) |
                                (bit_select(instr_i, 11, 8) << 1) |
                                0b0);
        uint32_t u_immediate = ((bit_select(instr_i, 31, 20) << 20) |
                                (bit_select(instr_i, 19, 12) << 12) |
                                bit_extend(0, 12));
        uint32_t j_immediate = ((bit_extend(bit_select(instr_i, 31, 31), 12) << 20) |
                                (bit_select(instr_i, 19, 12) << 12) |
                                (bit_select(instr_i, 20, 20) << 11) |
                                (bit_select(instr_i, 30, 21) << 1) |
                                0b0);

        switch (opcode_o)
        {
        case OP_IMM:
        case OP_LOAD:
        case OP_JALR:
            immediate_o = i_immediate;
            break;
        case OP_STORE:
            immediate_o = s_immediate;
            break;
        case OP_BRANCH:
            immediate_o = b_immediate;
            break;
        case OP_LUI:
        case OP_AUIPC:
            immediate_o = u_immediate;
            break;
        case OP_JAL:
            immediate_o = j_immediate;
            break;
        default:
            immediate_o = 0b0;
            break;
        }
    }
};