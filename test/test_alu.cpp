#include <verilated.h> // Defines common routines
#include <iostream>    // Need std::cout
#include "Valu.h"      // From Verilating "top.v"
#include <verilated_vcd_c.h>
#include <stdint.h>
#include <stdio.h>
#include <typeinfo> //for debugging
#include "defines.h"
#include "../test/soft_cpu/soft_alu.h"

Valu *alu; // Instantiation of model
VerilatedVcdC *m_trace;

#define BOLDRED "\033[1m\033[31m"   /* Bold Red */
#define BOLDGREEN "\033[1m\033[32m" /* Bold Green */
#define BOLDBLUE "\033[1m\033[34m"  /* Bold Blue */
#define RESET "\033[0m"

vluint64_t sim_time = 0;

// This is a "soft" isntruction decode module implemented in C++
// This function is used to extend bits
// This is equivalent to {size{bit}} in verilog

void test_alu(uint32_t test_instruction, uint32_t test_pc, uint32_t test_alu_operand_1, uint32_t test_alu_operand_2)
{
    printf("\nTesting alu_result with instruction: 0x%08x \n", test_instruction);
    printf("pc: 0x%08x  alu_operand_1: 0x%08x  alu_operand_2: 0x%08x\n", test_pc, test_alu_operand_1, test_alu_operand_2);

    Soft_Alu salu(test_instruction, test_pc, test_alu_operand_1, test_alu_operand_2);
    Soft_Instr_Decode sid(test_instruction);

    // Set input to module
    alu->pc_i = test_pc;
    alu->alu_operand_1_i = test_alu_operand_1;
    alu->alu_operand_2_i = test_alu_operand_2;

    alu->opcode_i = sid.opcode_o;
    alu->funct3_i = sid.funct3_o;
    alu->funct7_i = sid.funct7_o;
    alu->immediate_i = sid.immediate_o;

    alu->eval();
    sim_time++;
    m_trace->dump(sim_time);

    // test alu_result_o
    if (alu->alu_result_o == salu.alu_result_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Alu result is correct: 0x%x\n", alu->alu_result_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Alu result is incorrect: 0x%x, expected: 0x%x\n", alu->alu_result_o, salu.alu_result_o);

    // test target_address_o
    if (alu->target_address_o == salu.target_address_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Target address is correct: 0x%x\n", alu->target_address_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Target address is incorrect: 0x%x, expected: 0x%x\n", alu->target_address_o, salu.target_address_o);

    // test b_cond_met_o
    if (alu->b_cond_met_o == salu.b_cond_met_o)
        printf(BOLDGREEN "  SUCCESS" RESET ": Branch condition is correct: 0x%x\n", alu->b_cond_met_o);
    else
        printf(BOLDRED "  FAIL" RESET ": Branch condition is incorrect: 0x%x, expected: 0x%x\n", alu->b_cond_met_o, salu.b_cond_met_o);
}

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    std::cout << "Beginning simulation :> \n";

    // Initialization sequence
    alu = new Valu;
    m_trace = new VerilatedVcdC;
    alu->trace(m_trace, 5);        // Setting waveform to trace to 5 levels
    m_trace->open("waveform.vcd"); // Setting output file

    printf("\nGenerating waveforms... \n");

    // Testing sequence
    printf("\n---------- Testing Sequence ----------");
    printf("\nCurrent Instruction:" BOLDBLUE "lui x1 , 1000" RESET);
    test_alu(0x003e80b7, 0x00000000, 0x00000000, 0x00000000); // lui x1 , 1000

    printf("\nCurrent Instruction:" BOLDBLUE "auipc x1 , 1000" RESET);
    test_alu(0x003e8097, 0x00000001, 0x00000000, 0x00000000); // auipc x1 , 1000

    printf("\nCurrent Instruction:" BOLDBLUE "jal x1 , 16" RESET);
    test_alu(0x010000ef, 0x00000001, 0x00000000, 0x00000000); // auipc x1 , 1000

    printf("\nCurrent Instruction:" BOLDBLUE "jalr x1, 1000" RESET);
    test_alu(0x3e8080e7, 0x00000001, 0x00000000, 0x00000000); // jalr x1, 1000

    // branch
    printf("\n---------- Branch Instruction ----------");
    // beq true
    printf("\nCurrent Instruction:" BOLDBLUE "beq x2,  x4, 1000" RESET);
    test_alu(0x00410663, 0x00000001, 0x00000000, 0x00000000); // beq x2,  x4, 1000
    // beq false
    printf("\nCurrent Instruction:" BOLDBLUE "beq x2,  x4, 1000" RESET);
    test_alu(0x00410663, 0x00000001, 0x00000001, 0x00000000); // beq x2,  x4, 1000

    // bne true
    printf("\nCurrent Instruction:" BOLDBLUE "bne x2,  x4, 1000" RESET);
    test_alu(0x00411863, 0x00000001, 0x00000001, 0x00000000); // bne x2,  x4, 1000
    // bne false
    printf("\nCurrent Instruction:" BOLDBLUE "bne x2,  x4, 1000" RESET);
    test_alu(0x00411863, 0x00000001, 0x00000000, 0x00000000); // bne x2,  x4, 1000

    // blt true
    printf("\nCurrent Instruction:" BOLDBLUE "blt x2,  x4, 1000" RESET);
    test_alu(0x00414a63, 0x00000001, 0xF000000E, 0xFFFFFFFF); // blt x2,  x4, 1000
    // blt false
    printf("\nCurrent Instruction:" BOLDBLUE "blt x2,  x4, 1000" RESET);
    test_alu(0x00414a63, 0x00000001, 0xFFFFFFFF, 0xFFFFFFFF); // blt x2,  x4, 1000
    printf("\nCurrent Instruction:" BOLDBLUE "blt x2,  x4, 1000" RESET);
    test_alu(0x00414a63, 0x00000001, 0xFFFFFFFF, 0xFFFFFFFE); // blt x2,  x4, 1000

    // bltu true
    printf("\nCurrent Instruction:" BOLDBLUE "bltu x2,  x4, 1000" RESET);
    test_alu(0x02416263, 0x00000001, 0x00000000, 0xFFFFFFFF); // bltu x2,  x4, 1000
    // bltu false
    printf("\nCurrent Instruction:" BOLDBLUE "bltu x2,  x4, 1000" RESET);
    test_alu(0x02416263, 0x00000001, 0xFFFFFFFF, 0xFFFFFFFE); // bltu x2,  x4, 1000
    printf("\nCurrent Instruction:" BOLDBLUE "bltu x2,  x4, 1000" RESET);
    test_alu(0x02416263, 0x00000001, 0xFFFFFFFF, 0xFFFFFFFF); // bltu x2,  x4, 1000

    // bge true
    printf("\nCurrent Instruction:" BOLDBLUE "bge x2,  x4, 1000" RESET);
    test_alu(0x02415263, 0x00000001, 0xFFFFFFFF, 0xFFFFFFFE); // bge x2,  x4, 1000
    printf("\nCurrent Instruction:" BOLDBLUE "bge x2,  x4, 1000" RESET);
    test_alu(0x02415263, 0x00000001, 0xFFFFFFFF, 0xFFFFFFFF); // bge x2,  x4, 1000
    // bge false
    printf("\nCurrent Instruction:" BOLDBLUE "bge x2,  x4, 1000" RESET);
    test_alu(0x02415263, 0x00000001, 0xF000000F, 0xFFFFFFFE); // bge x2,  x4, 1000

    // bgeu true
    printf("\nCurrent Instruction:" BOLDBLUE "bgeu x2,  x4, 1000" RESET);
    test_alu(0x02417263, 0x00000001, 0xFFFFFFFF, 0x00000000); // bgeu x2,  x4, 1000
    printf("\nCurrent Instruction:" BOLDBLUE "bgeu x2,  x4, 1000" RESET);
    test_alu(0x02417263, 0x00000001, 0x00000001, 0x00000001); // bgeu x2,  x4, 1000
    // bgeu false
    printf("\nCurrent Instruction:" BOLDBLUE "bgeu x2,  x4, 1000" RESET);
    test_alu(0x02417263, 0x00000001, 0x00000000, 0xF0000000); // bgeu x2,  x4, 1000

    // load and store
    printf("\n---------- Load Store Instruction ----------");
    printf("\nCurrent Instruction:" BOLDBLUE "lw x1, 1000(x2)" RESET);
    test_alu(0x3e812083, 0x00000001, 0x00000011, 0x00000000); // lw x1, 1000(x2)

    printf("\nCurrent Instruction:" BOLDBLUE "sw x1, 1000(x2)" RESET);
    test_alu(0x3e112423, 0x00000001, 0x00000011, 0x00000000); // sw x1, 1000(x1)

    // immediate
    printf("\n---------- Immediate Instruction ----------");
    printf("\nCurrent Instruction:" BOLDBLUE "addi x3 , x2,  -1000" RESET);
    test_alu(0xc1810193, 0x00000001, 0x00000011, 0x00000000); // addi x3 , x2,  -1000

    // slti when true
    printf("\nCurrent Instruction:" BOLDBLUE "slti x3 , x2,  0" RESET);
    test_alu(0x00012193, 0x00000001, 0xFFFFFFFF, 0x00000000); // slti x3 , x2,  0
    // slti when false
    printf("\nCurrent Instruction:" BOLDBLUE "slti x3 , x2,  0" RESET);
    test_alu(0x00012193, 0x00000001, 0x1, 0x00000000); // slti x3 , x2,  0

    // sltiu when true
    printf("\nCurrent Instruction:" BOLDBLUE "sltiu x3 , x2,  1000" RESET);
    test_alu(0x3e813193, 0x00000001, 0x3e7, 0x00000000); // sltiu x3 , x2,  1000
    // sltiu when false
    printf("\nCurrent Instruction:" BOLDBLUE "sltiu x3 , x2,  1000" RESET);
    test_alu(0x3e813193, 0x00000001, 0x3e8, 0x00000000); // sltiu x3 , x2,  1000
    printf("\nCurrent Instruction:" BOLDBLUE "sltiu x3 , x2,  0" RESET);
    test_alu(0x00013193, 0x00000001, 0x1, 0x00000000); // sltiu x3 , x2,  0

    printf("\nCurrent Instruction:" BOLDBLUE "xori x3 , x2,  -1" RESET);
    test_alu(0xfff14193, 0x00000001, 0x555, 0x00000000); // xori x3 , x2,  -1

    printf("\nCurrent Instruction:" BOLDBLUE "ori x3 , x2,  -1" RESET);
    test_alu(0xfff16193, 0x00000001, 0xFFFFFFFF, 0x00000000); // ori x3 , x2,  -1

    printf("\nCurrent Instruction:" BOLDBLUE "andi x3 , x2,  -1" RESET);
    test_alu(0xfff17193, 0x00000001, 0x55555555, 0x00000000); // andi x3 , x2,  -1

    printf("\nCurrent Instruction:" BOLDBLUE "slli x3 , x2,  3" RESET);
    test_alu(0x00311193, 0x00000001, 0x1, 0x00000000); // slli x3 , x2,  3

    printf("\nCurrent Instruction:" BOLDBLUE "srli x3 , x2,  3" RESET);
    test_alu(0x00315193, 0x00000001, 0xFFFFFFFF, 0x00000000); // srli x3 , x2,  3

    // srai with msb set to 1
    printf("\nCurrent Instruction:" BOLDBLUE "srai x3 , x2,  3" RESET);
    test_alu(0x40315193, 0x00000001, 0xFFFFFFF0, 0x00000000); // srai x3 , x2,  3
    // srai with msb set to 0
    printf("\nCurrent Instruction:" BOLDBLUE "srai x3 , x2,  3" RESET);
    test_alu(0x40315193, 0x00000001, 0x0FFFFFF0, 0x00000000); // srai x3 , x2,  3

    // op_op
    printf("\n---------- Register Instruction ----------");
    printf("\nCurrent Instruction:" BOLDBLUE "add x3 , x2,  x4" RESET);
    test_alu(0x004101b3, 0x00000001, 0x555, 0x555); // add x3 , x2,  x4
    // add with overflow
    printf("\nCurrent Instruction:" BOLDBLUE "add x3 , x2,  x4" RESET);
    test_alu(0x004101b3, 0x00000001, 0xFFFFFFFF, 0x1); // add x3 , x2,  x4

    // sub negative number
    printf("\nCurrent Instruction:" BOLDBLUE "sub x3 , x2,  x4" RESET);
    test_alu(0x404101b3, 0x00000001, 0x1, 0xFFFFFFFF); // sub x3 , x2,  x4
    // sub to zero
    printf("\nCurrent Instruction:" BOLDBLUE "sub x3 , x2,  x4" RESET);
    test_alu(0x404101b3, 0x00000001, 0x00000001, 0x1); // sub x3 , x2,  x4
    // sub to produce positive number
    printf("\nCurrent Instruction:" BOLDBLUE "sub  x3 , x2,  x4" RESET);
    test_alu(0x404101b3, 0x00000001, 0x555, 0x444); // sub x3 , x2,  x4
    // sub to produce negative number
    printf("\nCurrent Instruction:" BOLDBLUE "sub x3 , x2,  x4" RESET);
    test_alu(0x404101b3, 0x00000001, 0x444, 0x555); // sub x3 , x2,  x4

    printf("\nCurrent Instruction:" BOLDBLUE "sll x3 , x2,  x4" RESET);
    test_alu(0x004111b3, 0x00000001, 0x444, 0x3); // sll x3 , x2,  x4

    // slt when true
    printf("\nCurrent Instruction:" BOLDBLUE "slt x3 , x2,  x4" RESET);
    test_alu(0x004121b3, 0x00000001, 0xFFFFFFFF, 0x0); // slt x3 , x2,  x4
    // slt when false
    printf("\nCurrent Instruction:" BOLDBLUE "slt x3 , x2,  x4" RESET);
    test_alu(0x004121b3, 0x00000001, 0xFFFFFFFF, 0xFFFFFFFE); // slt x3 , x2,  x4
    printf("\nCurrent Instruction:" BOLDBLUE "slt x3 , x2,  x4" RESET);
    test_alu(0x004121b3, 0x00000001, 0xFFFFFFFF, 0xFFFFFFFF); // slt x3 , x2,  x4

    // sltu when true
    printf("\nCurrent Instruction:" BOLDBLUE "sltu x3 , x2,  x4" RESET);
    test_alu(0x004131b3, 0x00000001, 0x0, 0x1); // sltu x3 , x2,  x4
    // sltu when false
    printf("\nCurrent Instruction:" BOLDBLUE "sltu x3 , x2,  x4" RESET);
    test_alu(0x004131b3, 0x00000001, 0x1, 0x1); // sltu x3 , x2,  x4
    printf("\nCurrent Instruction:" BOLDBLUE "sltu x3 , x2,  x4" RESET);
    test_alu(0x004131b3, 0x00000001, 0x2, 0x1); // sltu x3 , x2,  x4

    printf("\nCurrent Instruction:" BOLDBLUE "and x3 , x2,  x4" RESET);
    test_alu(0x004171b3, 0x00000001, 0x10111010, 0xFFFFFFFF); // add x3 , x2,  x4

    printf("\nCurrent Instruction:" BOLDBLUE "xor x3 , x2,  x4" RESET);
    test_alu(0x004141b3, 0x00000001, 0x10011101, 0x0000FFFF); // xor x3 , x2,  x4

    printf("\nCurrent Instruction:" BOLDBLUE "or x3 , x2,  x4" RESET);
    test_alu(0x004161b3, 0x00000001, 0x01100111, 0x0000FFFF); // or x3 , x2,  x4

    printf("\nCurrent Instruction:" BOLDBLUE "srl x3 , x2,  x4" RESET);
    test_alu(0x004151b3, 0x00000001, 0x01010101, 0x3); // srl x3 , x2,  x4

    // sra with msb set to 1
    printf("\nCurrent Instruction:" BOLDBLUE "sra x3 , x2,  3" RESET);
    test_alu(0x404151b3, 0x00000001, 0xFFFFFFF0, 0x3); // sra x3 , x2,  3
    // sra with msb set to 0
    printf("\nCurrent Instruction:" BOLDBLUE "sra x3 , x2,  3" RESET);
    test_alu(0x404151b3, 0x00000001, 0x0FFFFFF0, 0x3); // sra x3 , x2,  3

    // Ending sequence
    alu->final();
    m_trace->close();

    printf("\nOutputing waveform... \n");

    delete alu;
    delete m_trace;

    std::cout << "\nEnding simulation :< \n";
    exit(EXIT_SUCCESS);
}