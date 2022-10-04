#include <verilated.h> // Defines common routines
#include <iostream>    // Need std::cout
#include "Vcontrol.h"  // From Verilating "top.v"
#include <verilated_vcd_c.h>
#include <stdint.h>
#include <stdio.h>
#include "../test/soft_cpu/soft_control.h"
#include "../test/soft_cpu/soft_instr_decode.h"
#include "../test/instruction_bank/instruction_bank.hpp"

Vcontrol *control; // Instantiation of model
VerilatedVcdC *m_trace;

#define BOLDRED "\033[1m\033[31m"   /* Bold Red */
#define BOLDGREEN "\033[1m\033[32m" /* Bold Green */
#define BOLDBLUE "\033[1m\033[34m"  /* Bold Blue */
#define RESET "\033[0m"

vluint64_t sim_time = 0;

void test_control(uint32_t instruction)
{
    printf("\nTesting control siganls for Instruction: 0x%08x \n", instruction);

    // Create Soft_Instr_Decode block to decode instruction
    Soft_Instr_Decode sinstr_decode(instruction);

    // Input decoded opcode into control block
    Soft_Control scontrol(sinstr_decode.opcode_o);

    // Set input to module
    control->opcode_i = sinstr_decode.opcode_o;
    control->eval();
    sim_time++;
    m_trace->dump(sim_time);

    // Verify outputs
    // The printed prompt simply tells whether the test passed or not to prevent stuedents
    // from working out the outputs through the debugging text
    if (control->reg_write_en_o == scontrol.reg_write_en_o &&
        control->mem_to_reg_o == scontrol.mem_to_reg_o &&
        control->mem_write_en_o == scontrol.mem_write_en_o &&
        control->mem_read_en_o == scontrol.mem_read_en_o &&
        control->alu_op2_src_o == scontrol.alu_op2_src_o &&
        control->b_instr_o == scontrol.b_instr_o &&
        control->j_instr_o == scontrol.j_instr_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Control signals correct\n");
    else
        printf(BOLDRED "  FAIL" RESET ": Control signals inorrect\n");
}

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    std::cout << "Beginning simulation :> \n";

    // Initialization sequence
    control = new Vcontrol;
    m_trace = new VerilatedVcdC;
    control->trace(m_trace, 5);    // Setting waveform to trace to 5 levels
    m_trace->open("waveform.vcd"); // Setting output file

    printf("\nGenerating waveforms... \n");

    for (auto x : r_instruction)
    {
        printf("\nCurrent Instruction:" BOLDBLUE "%s" RESET, x.first.c_str());
        test_control(x.second);
    }

    for (auto x : i_instruction)
    {
        printf("\nCurrent Instruction:" BOLDBLUE "%s" RESET, x.first.c_str());
        test_control(x.second);
    }

    for (auto x : s_instruction)
    {
        printf("\nCurrent Instruction:" BOLDBLUE "%s" RESET, x.first.c_str());
        test_control(x.second);
    }

    for (auto x : b_instruction)
    {
        printf("\nCurrent Instruction:" BOLDBLUE "%s" RESET, x.first.c_str());
        test_control(x.second);
    }

    for (auto x : u_instruction)
    {
        printf("\nCurrent Instruction:" BOLDBLUE "%s" RESET, x.first.c_str());
        test_control(x.second);
    }

    for (auto x : j_instruction)
    {
        printf("\nCurrent Instruction:" BOLDBLUE "%s" RESET, x.first.c_str());
        test_control(x.second);
    }

    // Ending sequence
    control->final();
    m_trace->close();

    printf("\nOutputing waveform... \n");

    delete control;
    delete m_trace;

    std::cout << "\nEnding simulation :< \n";
    exit(EXIT_SUCCESS);
}
