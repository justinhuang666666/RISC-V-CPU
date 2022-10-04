#include <verilated.h>     // Defines common routines
#include <iostream>        // Need std::cout
#include "Vinstr_decode.h" // From Verilating "top.v"
#include <verilated_vcd_c.h>
#include <stdint.h>
#include <stdio.h>
#include "../test/soft_cpu/soft_instr_decode.h"
#include "../test/instruction_bank/instruction_bank.hpp"

Vinstr_decode *instr_decode; // Instantiation of model
VerilatedVcdC *m_trace;

#define BOLDRED "\033[1m\033[31m"   /* Bold Red */
#define BOLDGREEN "\033[1m\033[32m" /* Bold Green */
#define BOLDBLUE "\033[1m\033[34m"  /* Bold Blue */
#define RESET "\033[0m"

vluint64_t sim_time = 0;

void test_r_instruction(uint32_t instruction)
{
    printf("\nTesting R-type Instruction: 0x%08x \n", instruction);

    // Set input to module
    instr_decode->instr_i = instruction;
    instr_decode->eval();
    sim_time++;
    m_trace->dump(sim_time);

    // Create Soft_instr_decode object
    Soft_Instr_Decode sinstr_decode(instruction);

    // Verify outputs
    if (instr_decode->opcode_o == sinstr_decode.opcode_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Opcode is correct: 0x%x\n", instr_decode->opcode_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Opcode is incorrect: 0x%x, expected: 0x%x\n", instr_decode->opcode_o, sinstr_decode.opcode_o);

    if (instr_decode->rs1_o == sinstr_decode.rs1_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Rs1 is correct: 0x%x\n", instr_decode->rs1_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Rs1 is incorrect: 0x%x, expected: 0x%x\n", instr_decode->rs1_o, sinstr_decode.rs1_o);

    if (instr_decode->rs2_o == sinstr_decode.rs2_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Rs2 is correct: 0x%x\n", instr_decode->rs2_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Rs2 is incorrect: 0x%x, expected: 0x%x\n", instr_decode->rs2_o, sinstr_decode.rs2_o);

    if (instr_decode->rd_o == sinstr_decode.rd_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Rd is correct: 0x%x\n", instr_decode->rd_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Rd is incorrect: 0x%x, expected: 0x%x\n", instr_decode->rd_o, sinstr_decode.rd_o);

    if (instr_decode->funct3_o == sinstr_decode.funct3_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Funct3 is correct: 0x%x\n", instr_decode->funct3_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Funct3 is incorrect: 0x%x, expected: 0x%x\n", instr_decode->funct3_o, sinstr_decode.funct3_o);

    if (instr_decode->funct7_o == sinstr_decode.funct7_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Funct7 is correct: 0x%x\n", instr_decode->funct7_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Funct7 is incorrect: 0x%x, expected: 0x%x\n", instr_decode->funct3_o, sinstr_decode.funct7_o);
}

void test_i_instruction(uint32_t instruction)
{
    printf("\nTesting I-type Instruction: 0x%08x \n", instruction);

    // Set input to module
    instr_decode->instr_i = instruction;
    instr_decode->eval();
    sim_time++;
    m_trace->dump(sim_time);

    // Create Soft_instr_decode object
    Soft_Instr_Decode sinstr_decode(instruction);

    // Verify outputs
    if (instr_decode->opcode_o == sinstr_decode.opcode_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Opcode is correct: 0x%x\n", instr_decode->opcode_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Opcode is incorrect: 0x%x, expected: 0x%x\n", instr_decode->opcode_o, sinstr_decode.opcode_o);

    if (instr_decode->rs1_o == sinstr_decode.rs1_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Rs1 is correct: 0x%x\n", instr_decode->rs1_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Rs1 is incorrect: 0x%x, expected: 0x%x\n", instr_decode->rs1_o, sinstr_decode.rs1_o);

    if (instr_decode->rd_o == sinstr_decode.rd_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Rd is correct: 0x%x\n", instr_decode->rd_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Rd is incorrect: 0x%x, expected: 0x%x\n", instr_decode->rd_o, sinstr_decode.rd_o);

    if (instr_decode->funct3_o == sinstr_decode.funct3_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Funct3 is correct: 0x%x\n", instr_decode->funct3_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Funct3 is incorrect: 0x%x, expected: 0x%x\n", instr_decode->funct3_o, sinstr_decode.funct3_o);

    if (instr_decode->immediate_o == sinstr_decode.immediate_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Immediate is correct: 0x%x\n", instr_decode->immediate_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Immediate is incorrect: 0x%x, expected: 0x%x\n", instr_decode->immediate_o, sinstr_decode.immediate_o);
}

void test_s_instruction(uint32_t instruction)
{
    printf("\nTesting S-type Instruction: 0x%08x \n", instruction);

    // Set input to module
    instr_decode->instr_i = instruction;
    instr_decode->eval();
    sim_time++;
    m_trace->dump(sim_time);

    // Create Soft_instr_decode object
    Soft_Instr_Decode sinstr_decode(instruction);

    // Verify outputs
    if (instr_decode->opcode_o == sinstr_decode.opcode_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Opcode is correct: 0x%x\n", instr_decode->opcode_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Opcode is incorrect: 0x%x, expected: 0x%x\n", instr_decode->opcode_o, sinstr_decode.opcode_o);

    if (instr_decode->rs1_o == sinstr_decode.rs1_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Rs1 is correct: 0x%x\n", instr_decode->rs1_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Rs1 is incorrect: 0x%x, expected: 0x%x\n", instr_decode->rs1_o, sinstr_decode.rs1_o);

    if (instr_decode->rs2_o == sinstr_decode.rs2_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Rs2 is correct: 0x%x\n", instr_decode->rs2_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Rs2 is incorrect: 0x%x, expected: 0x%x\n", instr_decode->rs2_o, sinstr_decode.rs2_o);

    if (instr_decode->funct3_o == sinstr_decode.funct3_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Funct3 is correct: 0x%x\n", instr_decode->funct3_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Funct3 is incorrect: 0x%x, expected: 0x%x\n", instr_decode->funct3_o, sinstr_decode.funct3_o);

    if (instr_decode->immediate_o == sinstr_decode.immediate_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Immediate is correct: 0x%x\n", instr_decode->immediate_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Immediate is incorrect: 0x%x, expected: 0x%x\n", instr_decode->immediate_o, sinstr_decode.immediate_o);
}

void test_b_instruction(uint32_t instruction)
{
    printf("\nTesting B-type Instruction: 0x%08x \n", instruction);

    // Set input to module
    instr_decode->instr_i = instruction;
    instr_decode->eval();
    sim_time++;
    m_trace->dump(sim_time);

    // Create Soft_instr_decode object
    Soft_Instr_Decode sinstr_decode(instruction);

    // Verify outputs
    if (instr_decode->opcode_o == sinstr_decode.opcode_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Opcode is correct: 0x%x\n", instr_decode->opcode_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Opcode is incorrect: 0x%x, expected: 0x%x\n", instr_decode->opcode_o, sinstr_decode.opcode_o);

    if (instr_decode->rs1_o == sinstr_decode.rs1_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Rs1 is correct: 0x%x\n", instr_decode->rs1_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Rs1 is incorrect: 0x%x, expected: 0x%x\n", instr_decode->rs1_o, sinstr_decode.rs1_o);

    if (instr_decode->rs2_o == sinstr_decode.rs2_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Rs2 is correct: 0x%x\n", instr_decode->rs2_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Rs2 is incorrect: 0x%x, expected: 0x%x\n", instr_decode->rs2_o, sinstr_decode.rs2_o);

    if (instr_decode->funct3_o == sinstr_decode.funct3_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Funct3 is correct: 0x%x\n", instr_decode->funct3_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Funct3 is incorrect: 0x%x, expected: 0x%x\n", instr_decode->funct3_o, sinstr_decode.funct3_o);

    if (instr_decode->immediate_o == sinstr_decode.immediate_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Immediate is correct: 0x%x\n", instr_decode->immediate_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Immediate is incorrect: 0x%x, expected: 0x%x\n", instr_decode->immediate_o, sinstr_decode.immediate_o);
}

void test_u_instruction(uint32_t instruction)
{
    printf("\nTesting U-type Instruction: 0x%08x \n", instruction);

    // Set input to module
    instr_decode->instr_i = instruction;
    instr_decode->eval();
    sim_time++;
    m_trace->dump(sim_time);

    // Create Soft_instr_decode object
    Soft_Instr_Decode sinstr_decode(instruction);

    // Verify outputs
    if (instr_decode->opcode_o == sinstr_decode.opcode_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Opcode is correct: 0x%x\n", instr_decode->opcode_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Opcode is incorrect: 0x%x, expected: 0x%x\n", instr_decode->opcode_o, sinstr_decode.opcode_o);

    if (instr_decode->rd_o == sinstr_decode.rd_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Rd is correct: 0x%x\n", instr_decode->rd_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Rd is incorrect: 0x%x, expected: 0x%x\n", instr_decode->rd_o, sinstr_decode.rd_o);

    if (instr_decode->immediate_o == sinstr_decode.immediate_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Immediate is correct: 0x%x\n", instr_decode->immediate_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Immediate is incorrect: 0x%x, expected: 0x%x\n", instr_decode->immediate_o, sinstr_decode.immediate_o);
}

void test_j_instruction(uint32_t instruction)
{
    printf("\nTesting J-type Instruction: 0x%08x \n", instruction);

    // Set input to module
    instr_decode->instr_i = instruction;
    instr_decode->eval();
    sim_time++;
    m_trace->dump(sim_time);

    // Create Soft_instr_decode object
    Soft_Instr_Decode sinstr_decode(instruction);

    // Verify outputs
    if (instr_decode->opcode_o == sinstr_decode.opcode_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Opcode is correct: 0x%x\n", instr_decode->opcode_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Opcode is incorrect: 0x%x, expected: 0x%x\n", instr_decode->opcode_o, sinstr_decode.opcode_o);

    if (instr_decode->rd_o == sinstr_decode.rd_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Rd is correct: 0x%x\n", instr_decode->rd_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Rd is incorrect: 0x%x, expected: 0x%x\n", instr_decode->rd_o, sinstr_decode.rd_o);

    if (instr_decode->immediate_o == sinstr_decode.immediate_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Immediate is correct: 0x%x\n", instr_decode->immediate_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Immediate is incorrect: 0x%x, expected: 0x%x\n", instr_decode->immediate_o, sinstr_decode.immediate_o);
}

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    std::cout << "Beginning simulation :> \n";

    // Initialization sequence
    instr_decode = new Vinstr_decode;
    m_trace = new VerilatedVcdC;
    instr_decode->trace(m_trace, 5); // Setting waveform to trace to 5 levels
    m_trace->open("waveform.vcd");   // Setting output file

    printf("\nGenerating waveforms... \n");

    // Testing Sequence
    for (auto x : r_instruction)
    {
        printf("\nCurrent Instruction:" BOLDBLUE "%s" RESET, x.first.c_str());
        test_r_instruction(x.second);
    }

    for (auto x : i_instruction)
    {
        printf("\nCurrent Instruction:" BOLDBLUE "%s" RESET, x.first.c_str());
        test_i_instruction(x.second);
    }

    for (auto x : s_instruction)
    {
        printf("\nCurrent Instruction:" BOLDBLUE "%s" RESET, x.first.c_str());
        test_s_instruction(x.second);
    }

    for (auto x : b_instruction)
    {
        printf("\nCurrent Instruction:" BOLDBLUE "%s" RESET, x.first.c_str());
        test_b_instruction(x.second);
    }

    for (auto x : u_instruction)
    {
        printf("\nCurrent Instruction:" BOLDBLUE "%s" RESET, x.first.c_str());
        test_u_instruction(x.second);
    }

    for (auto x : j_instruction)
    {
        printf("\nCurrent Instruction:" BOLDBLUE "%s" RESET, x.first.c_str());
        test_j_instruction(x.second);
    }

    // Ending sequence
    instr_decode->final();
    m_trace->close();

    printf("\nOutputing waveform... \n");

    delete instr_decode;
    delete m_trace;

    std::cout << "\nEnding simulation :< \n";
    exit(EXIT_SUCCESS);
}
