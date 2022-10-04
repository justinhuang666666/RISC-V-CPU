#include <stdint.h>
#include "../test/defines.h"

// This is a "soft" control module implemented in C++

class Soft_Control
{
public:
    uint8_t reg_write_en_o;
    uint8_t mem_to_reg_o;
    uint8_t mem_write_en_o;
    uint8_t mem_read_en_o;
    uint8_t alu_op2_src_o;
    uint8_t b_instr_o;
    uint8_t j_instr_o;

    Soft_Control(uint8_t opcode_i)
    {
        reg_write_en_o = 0;
        mem_to_reg_o = 0;
        mem_write_en_o = 0;
        mem_read_en_o = 0;
        alu_op2_src_o = 0;
        b_instr_o = 0;
        j_instr_o = 0;

        switch (opcode_i)
        {
        case OP_AUIPC:
        case OP_LUI:
            reg_write_en_o = 1;
            alu_op2_src_o = 1;
            break;
        case OP_IMM:
            reg_write_en_o = 1;
            alu_op2_src_o = 1;
            break;
        case OP_OP:
            reg_write_en_o = 1;
            break;
        case OP_LOAD:
            reg_write_en_o = 1;
            mem_to_reg_o = 1;
            mem_read_en_o = 1;
            alu_op2_src_o = 1;
            break;
        case OP_STORE:
            mem_write_en_o = 1;
            alu_op2_src_o = 1;
            break;
        case OP_JAL:
        case OP_JALR:
            reg_write_en_o = 1;
            alu_op2_src_o = 1;
            j_instr_o = 1;
            break;
        case OP_BRANCH:
            b_instr_o = 1;
            break;
        default:
            break;
        }
    }
};