#include <verilated.h> // Defines common routines
#include <iostream>    // Need std::cout
#include "Vif2id.h"    // From Verilating "top.v"
#include <verilated_vcd_c.h>
#include <stdint.h>
#include <stdio.h>
#include <random> // For generating random bits

Vif2id *if2id; // Instantiation of model
VerilatedVcdC *m_trace;
std::mt19937 mt; // Instantiate a 32-bit Mersenne Twister (for random bit generation)

#define BOLDRED "\033[1m\033[31m"   /* Bold Red */
#define BOLDGREEN "\033[1m\033[32m" /* Bold Green */
#define RESET "\033[0m"

vluint64_t sim_time = 0;

// Generates bits of length equal to the size inputted
// Input size cannot exceed 32
uint32_t random_generate(int size)
{
    int result = 0b0;
    std::uniform_int_distribution<> bit{0, 1}; // Generates uniform numbers of 0 and 1
    for (int i = 0; i < size; ++i)
        result = (result << 1) | bit(mt);
    return result;
}

void test_if2id_propagate()
{
    printf("\nTesting if2id Register Propagation\n");
    uint32_t pc_i = random_generate(32);
    uint32_t instr_i = random_generate(32);

    // Set clock to low
    if2id->clk = 0;
    if2id->eval();
    m_trace->dump(sim_time);
    sim_time++;

    // Set input of registers
    if2id->pc_i = pc_i;
    if2id->instr_i = instr_i;
    if2id->eval();

    // Toggle clock
    if2id->clk = 1;
    if2id->eval();
    m_trace->dump(sim_time);
    sim_time++;

    // Evaluating at the positive clk edge
    if (if2id->pc_o == pc_i && if2id->instr_o == instr_i)
        printf(BOLDGREEN "  SUCCESS" RESET ": if2id Register inputs successfully propagated\n");
    else
        printf(BOLDRED "  FAIL" RESET ": if2id Register fail to propagate: pc expected 0x%x, got 0x%x ; isntr expected 0x%x, got 0x%x\n", pc_i, if2id->pc_o, instr_i, if2id->instr_o);
}

void test_if2id_flush()
{
    printf("\nTesting if2id Register Flush\n");
    uint32_t pc_i = random_generate(32);
    uint32_t instr_i = random_generate(32);

    bool flush_success = false;

    // Set clock to low
    if2id->clk = 0;
    if2id->eval();
    m_trace->dump(sim_time);
    sim_time++;

    // Set input of registers
    if2id->pc_i = pc_i;
    if2id->instr_i = instr_i;
    if2id->eval();

    // Toggle clock
    if2id->clk = 1;
    if2id->eval();
    m_trace->dump(sim_time);
    sim_time++;

    // Toggle clock
    // At this point the outputs of the module are pc_i and instr_i
    if2id->clk = 0;
    if2id->eval();
    m_trace->dump(sim_time);
    sim_time++;

    // Set flush to high
    if2id->flush = 0b1;
    if2id->eval();

    // Toggle clock
    if2id->clk = 1;
    if2id->eval();
    m_trace->dump(sim_time);
    sim_time++;

    // Toggle clock
    if2id->clk = 0;
    if2id->eval();
    m_trace->dump(sim_time);
    sim_time++;

    // Set flush to low
    if2id->flush = 0b0;
    if2id->eval();

    // Evaluating at the positive clk edge
    if (if2id->pc_o == 0 && if2id->instr_o == 0)
        printf(BOLDGREEN "  SUCCESS" RESET ": if2id Register flush success\n");
    else
        printf(BOLDRED "  FAIL" RESET ": if2id Register failed to flush: pc expected 0x0, got 0x%x ; isntr expected 0x0, got 0x%x\n", pc_i, if2id->pc_o, instr_i, if2id->instr_o);

    // Toggle clock
    if2id->clk = 1;
    if2id->eval();
    m_trace->dump(sim_time);
    sim_time++;
}

void test_if2id_stall()
{
    printf("\nTesting if2id Register Stalling\n");
    uint32_t pc_i = random_generate(32);
    uint32_t instr_i = random_generate(32);

    bool stall_success = false;

    // Set clock to low
    if2id->clk = 0;
    if2id->eval();
    m_trace->dump(sim_time);
    sim_time++;

    // Set input of registers
    if2id->pc_i = pc_i;
    if2id->instr_i = instr_i;
    if2id->eval();

    // Toggle clock
    if2id->clk = 1;
    if2id->eval();
    m_trace->dump(sim_time);
    sim_time++;

    // Toggle clock
    // At this point the outputs of the module are pc_i and instr_i
    if2id->clk = 0;
    if2id->eval();
    m_trace->dump(sim_time);
    sim_time++;

    // Set stall to high
    if2id->stall = 0b1;
    if2id->eval();

    // Set input of registers to other value
    if2id->pc_i = ~pc_i;
    if2id->instr_i = ~instr_i;
    if2id->eval();

    // Toggle clock
    if2id->clk = 1;
    if2id->eval();
    m_trace->dump(sim_time);
    sim_time++;

    // Toggle clock
    if2id->clk = 0;
    if2id->eval();
    m_trace->dump(sim_time);
    sim_time++;

    // Toggle clock
    if2id->clk = 1;
    if2id->eval();
    m_trace->dump(sim_time);
    sim_time++;

    // Evaluating outputs after another clk edge to ensure it holds its value
    // Output should be original value
    if (if2id->pc_o == pc_i && if2id->instr_o == instr_i)
        stall_success = true;

    // Toggle clock
    if2id->clk = 0;
    if2id->eval();
    m_trace->dump(sim_time);
    sim_time++;

    // Set stall input to low to test if the register still propagates
    if2id->stall = 0b0;
    if2id->eval();

    // Set input of registers to other value
    if2id->pc_i = ~pc_i;
    if2id->instr_i = ~instr_i;
    if2id->eval();

    // Toggle clock
    if2id->clk = 1;
    if2id->eval();
    m_trace->dump(sim_time);
    sim_time++;

    // This is too check if the register functions correctly after the stall
    if (if2id->pc_o == ~pc_i && if2id->instr_o == ~instr_i && stall_success)
        printf(BOLDGREEN "  SUCCESS" RESET ": if2id Register stall success\n");
    else if (stall_success)
        printf(BOLDRED "  FAIL" RESET ": if2id Register did not propagate after stall\n");
    else
        printf(BOLDRED "  FAIL" RESET ": if2id Register did not stall\n");
}

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    // Initialization Sequence
    std::cout << "Beginning simulation :> \n";
    if2id = new Vif2id;
    m_trace = new VerilatedVcdC;
    if2id->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    // Each test is repeated 3 times with its own pseudo-random 32bit numbers

    test_if2id_propagate();
    test_if2id_propagate();
    test_if2id_propagate();

    test_if2id_flush();
    test_if2id_flush();
    test_if2id_flush();

    test_if2id_stall();
    test_if2id_stall();
    test_if2id_stall();

    // Ending Sequence
    if2id->final();
    m_trace->close();
    delete if2id;
    delete m_trace;

    std::cout << "\nEnding simulation :< \n";
    exit(EXIT_SUCCESS);
}