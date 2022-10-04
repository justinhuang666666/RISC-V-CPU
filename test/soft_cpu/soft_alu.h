#include <stdint.h>
#include "../defines.h"
#include "soft_instr_decode.h"

class Soft_Alu
{
public:
    uint32_t pc_i;
    uint32_t alu_operand_1_i;
    uint32_t alu_operand_2_i;

    uint32_t immediate_i;
    uint8_t funct7_i;
    uint8_t funct3_i;
    uint8_t opcode_i;

    uint32_t alu_result_o;
    uint32_t target_address_o;
    uint8_t b_cond_met_o;

    uint32_t bit_extend(uint8_t bit, int size)
    {
        uint32_t result = 0b0;
        // Shift and OR with starting bit to concatenate
        for (int i = 0; i < size; ++i)
            result = (result << 1) | bit;
        return result;
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

    Soft_Alu(uint32_t instruction, uint32_t pc, uint32_t alu_oprand_1, uint32_t alu_oprand_2)
    {
        pc_i = pc;
        alu_operand_1_i = alu_oprand_1;
        alu_operand_2_i = alu_oprand_2;
        int32_t signed_alu_operand_1_i = alu_oprand_1;
        int32_t signed_alu_operand_2_i = alu_oprand_2;

        Soft_Instr_Decode sinstr_decode(instruction);
        immediate_i = sinstr_decode.immediate_o;
        int32_t signed_immediate_i = sinstr_decode.immediate_o;
        funct7_i = sinstr_decode.funct7_o;
        funct3_i = sinstr_decode.funct3_o;
        opcode_i = sinstr_decode.opcode_o;

        uint32_t immediate_shift_amount = bit_select(immediate_i, 4, 0);
        uint32_t register_shift_amount = bit_select(alu_operand_2_i, 4, 0);

        // alu_result_o
        switch (opcode_i)
        {
        case OP_LUI:
            alu_result_o = immediate_i;
            break;
        case OP_AUIPC:
            alu_result_o = immediate_i + pc;
            break;
        case OP_JAL:
            alu_result_o = pc_i + 0x00000004;
            break;
        case OP_JALR:
            alu_result_o = pc_i + 0x00000004;
            break;
        // case OP_BRANCH:
        case OP_LOAD:
            alu_result_o = alu_operand_1_i + immediate_i;
            break;
        case OP_STORE:
            alu_result_o = alu_operand_1_i + immediate_i;
            break;
        case OP_IMM:
            switch (funct3_i)
            {
            case FUNCT3_ADDI:
                alu_result_o = alu_operand_1_i + immediate_i;
                break;
            case FUNCT3_SLTI:
                alu_result_o = (signed_alu_operand_1_i < signed_immediate_i) ? 0b1 : 0b0;
                break;
            case FUNCT3_SLTIU:
                alu_result_o = (alu_operand_1_i < immediate_i) ? 0b1 : 0b0;
                break;
            case FUNCT3_XORI:
                alu_result_o = alu_operand_1_i ^ immediate_i;
                break;
            case FUNCT3_ORI:
                alu_result_o = alu_operand_1_i | immediate_i;
                break;
            case FUNCT3_ANDI:
                alu_result_o = alu_operand_1_i & immediate_i;
                break;
            case FUNCT3_SLLI:
                alu_result_o = alu_operand_1_i << immediate_shift_amount;
                break;
            case FUNCT3_SRLI_SRAI:
                switch (funct7_i)
                {
                case FUNCT7_SRLI:
                    alu_result_o = alu_operand_1_i >> immediate_shift_amount;
                    break;
                case FUNCT7_SRAI:
                    alu_result_o = signed_alu_operand_1_i >> immediate_shift_amount;
                    break;
                default:
                    alu_result_o = 0x00000000;
                    break;
                }
                break;
            default:
                alu_result_o = 0x00000000;
                break;
            }
            break;
        case OP_OP:
            switch (funct3_i)
            {
            case FUNCT3_ADD_SUB:
                switch (funct7_i)
                {
                case FUNCT7_ADD:
                    alu_result_o = alu_operand_1_i + alu_operand_2_i;
                    break;
                case FUNCT7_SUB:
                    alu_result_o = alu_operand_1_i - alu_operand_2_i;
                    break;
                default:
                    alu_result_o = 0x00000000;
                    break;
                }
                break;
            case FUNCT3_SLL:
                alu_result_o = alu_operand_1_i << register_shift_amount;
                break;
            case FUNCT3_SLT:
                alu_result_o = (signed_alu_operand_1_i < signed_alu_operand_2_i) ? 0b1 : 0b0;
                break;
            case FUNCT3_SLTU:
                alu_result_o = (alu_operand_1_i < alu_operand_2_i) ? 0b1 : 0b0;
                break;
            case FUNCT3_XOR:
                alu_result_o = alu_operand_1_i ^ alu_operand_2_i;
                break;
            case FUNCT3_SRL_SRA:
                switch (funct7_i)
                {
                case FUNCT7_SRL:
                    alu_result_o = alu_operand_1_i >> register_shift_amount;
                    break;
                case FUNCT7_SRA:
                    alu_result_o = signed_alu_operand_1_i >> register_shift_amount;
                    break;
                default:
                    alu_result_o = 0x00000000;
                    break;
                }
                break;
            case FUNCT3_OR:
                alu_result_o = alu_operand_1_i | alu_operand_2_i;
                break;
            case FUNCT3_AND:
                alu_result_o = alu_operand_1_i & alu_operand_2_i;
                break;
            default:
                alu_result_o = 0x00000000;
                break;
            }
            break;
        // case OP_MISC_MEM:
        default:
            alu_result_o = 0x00000000;
            break;
        }

        // target_address
        uint32_t pc_plus_immediate = pc_i + immediate_i;
        switch (opcode_i)
        {
        case OP_JAL:
            target_address_o = pc_plus_immediate;
            break;
        case OP_JALR:
            target_address_o = pc_plus_immediate & 0xFFFFFFFE;
            break;
        case OP_BRANCH:
            target_address_o = pc_plus_immediate;
            break;
        default:
            target_address_o = 0x00000000;
        }
        // b_cond_met_o
        switch (opcode_i)
        {
        case OP_JAL:
            b_cond_met_o = 0x1;
            break;
        case OP_JALR:
            b_cond_met_o = 0x1;
            break;
        case OP_BRANCH:
            switch (funct3_i)
            {
            case FUNCT3_BEQ:
                b_cond_met_o = (alu_operand_1_i == alu_operand_2_i) ? 0x1 : 0x0;
                break;
            case FUNCT3_BNE:
                b_cond_met_o = (alu_operand_1_i != alu_operand_2_i) ? 0x1 : 0x0;
                break;
            case FUNCT3_BLT:
                b_cond_met_o = (signed_alu_operand_1_i < signed_alu_operand_2_i) ? 0x1 : 0x0;
                break;
            case FUNCT3_BGE:
                b_cond_met_o = (signed_alu_operand_1_i >= signed_alu_operand_2_i) ? 0x1 : 0x0;
                break;
            case FUNCT3_BLTU:
                b_cond_met_o = (alu_operand_1_i < alu_operand_2_i) ? 0x1 : 0x0;
                break;
            case FUNCT3_BGEU:
                b_cond_met_o = (alu_operand_1_i >= alu_operand_2_i) ? 0x1 : 0x0;
                break;
            default:
                b_cond_met_o = 0x0;
                break;
            }
            break;
        default:
            b_cond_met_o = 0x0;
        }
    }
};