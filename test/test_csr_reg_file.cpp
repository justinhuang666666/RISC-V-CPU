#include <bits/stdint-uintn.h>
#include <cstdlib>
#include <verilated.h>          // Defines common routines
#include <iostream>             // Need std::cout
#include "Vcsr_reg_file.h"   
#include <verilated_vcd_c.h>

#include <stdint.h>
#include <stdio.h>

Vcsr_reg_file* csr_reg_file;                      // Instantiation of model
VerilatedVcdC *m_trace;

#define MVENDORID_ADDR  0xF11 
#define MARCHID_ADDR    0xF12 
#define MIMPID_ADDR     0xF13 
#define MHARTID_ADDR    0xF14 

#define MISA_ADDR       0x301
#define MIE_ADDR        0x304
#define MTVEC_ADDR      0x305 

#define MEPC_ADDR       0x341
#define MCAUSE_ADDR     0x342
#define MTVAL_ADDR      0x343
#define MIP_ADDR        0x344

#define NON_EXIST_CSR_ADDR_1 0x000
#define NON_EXIST_CSR_ADDR_2 0x314
#define NON_EXIST_CSR_ADDR_3 0xFFF

#define BOLDRED     "\033[1m\033[31m"      /* Bold Red */
#define BOLDGREEN   "\033[1m\033[32m"      /* Bold Green */
#define RESET   "\033[0m"

#define MAX_SIM_TIME 5
vluint64_t sim_time = 0;

// TODO: This testbench needs refactoring to make it more readable.

// This functions assumes CLK is set low, and last step of model was evaluated before calling
void attempt_write_to_read_only_CSR(uint16_t addr, uint32_t val)
{

    // printf("======== Beginning WRITE TO READ ONLY CSR test =======================================\n");
    printf("\nAttempting write to read-only register at address 0x%03x with value 0x%08x\n", addr, val);
    
    // Set read parameters to the CSR we are about to write, so we can check result
    csr_reg_file->read_enable_i = 1;
    csr_reg_file->read_addr_i = addr;

    // Set write inputs to write to given CSR with given value
    csr_reg_file->write_enable_i = 1;
    csr_reg_file->write_addr_i = addr;
    csr_reg_file->write_val_i = val;

    csr_reg_file->clk_i = 1;
    csr_reg_file->eval();
    m_trace->dump(sim_time);
    sim_time++; 

    csr_reg_file->clk_i = 0;
    csr_reg_file->eval();
    m_trace->dump(sim_time);
    sim_time++; 

    // csr_reg_file->read_enable_i = 0;
    // csr_reg_file->write_enable_i = 0;

    // Eval next posedge, and THEN check for output changes from prev. posedge
    csr_reg_file->clk_i = 1;
    csr_reg_file->eval();
    m_trace->dump(sim_time);
    sim_time++;

    // Now let us verify that the outputs are as expected
    if (csr_reg_file->csr_reg_read_o == 0)  printf(BOLDGREEN "  SUCCESS" RESET ": Register value remained 0x00\n");
    else                                    printf(BOLDRED "  FAILED" RESET ":  Register value changed... New value is %08x \n", csr_reg_file->csr_reg_read_o);

    if (csr_reg_file->except_read_non_existent_CSR_o == 0)  printf(BOLDGREEN "  SUCCESS" RESET ": except_read_non_existent_CSR_o is LOW\n");
    else                                                    printf(BOLDRED "  FAILED" RESET ":  except_read_non_existent_CSR_o is HIGH\n");

    if (csr_reg_file->except_write_non_existent_CSR_o == 0)  printf(BOLDGREEN "  SUCCESS" RESET ": except_write_non_existent_CSR_o is LOW\n");
    else                                                    printf(BOLDRED "  FAILED" RESET ":  except_write_non_existent_CSR_o is HIGH\n");

    if (csr_reg_file->except_write_to_read_only_CSR_o == 1)  printf(BOLDGREEN"  SUCCESS" RESET ": except_write_to_read_only_CSR_o is HIGH\n");
    else                                                    printf(BOLDRED "  FAILED" RESET ":  except_write_to_read_only_CSR_o is LOW\n");

    // We now evaluate the low clock cycle before returning
    csr_reg_file->clk_i = 0;
    csr_reg_file->eval();
    m_trace->dump(sim_time);
    sim_time++; 
    // printf("======================================================================================\n");
}

// This functions assumes CLK is set low, and last step of model was evaluated before calling
void attempt_read_and_write_to_non_existent_CSR(uint16_t addr, uint32_t val)
{

    // printf("======== Beginning WRITE TO READ ONLY CSR test =======================================\n");
    printf("\nAttempting write to non-existent CSR at address 0x%03x with value 0x%08x\n", addr, val);
    
    // Set read parameters to the CSR we are about to write, so we can check result
    csr_reg_file->read_enable_i = 1;
    csr_reg_file->read_addr_i = addr;

    // Set write inputs to write to given CSR with given value
    csr_reg_file->write_enable_i = 1;
    csr_reg_file->write_addr_i = addr;
    csr_reg_file->write_val_i = val;

    csr_reg_file->clk_i = 1;
    csr_reg_file->eval();
    m_trace->dump(sim_time);
    sim_time++;

    csr_reg_file->clk_i = 0;
    csr_reg_file->eval();
    m_trace->dump(sim_time);
    sim_time++; 

    // csr_reg_file->read_enable_i = 0;
    // csr_reg_file->write_enable_i = 0;

    // Eval next posedge, and THEN check for output changes from prev. posedge
    csr_reg_file->clk_i = 1;
    csr_reg_file->eval();
    m_trace->dump(sim_time);
    sim_time++; 

    // Now let us verify that the outputs are as expected
    if (csr_reg_file->csr_reg_read_o == 0)  printf(BOLDGREEN "  SUCCESS" RESET ": Default value of 0x00 observed\n");
    else                                    printf(BOLDRED "  FAILED" RESET ":  Non-default value observed for non-existent CSR: %08x \n", csr_reg_file->csr_reg_read_o);

    if (csr_reg_file->except_read_non_existent_CSR_o == 1)  printf(BOLDGREEN "  SUCCESS" RESET ": except_read_non_existent_CSR_o is HIGH\n");
    else                                                    printf(BOLDRED "  FAILED" RESET ":  except_read_non_existent_CSR_o is LOW\n");

    if (csr_reg_file->except_write_non_existent_CSR_o == 1)  printf(BOLDGREEN "  SUCCESS" RESET ": except_write_non_existent_CSR_o is HIGH\n");
    else                                                    printf(BOLDRED "  FAILED" RESET ":  except_write_non_existent_CSR_o is LOW\n");

    if (csr_reg_file->except_write_to_read_only_CSR_o == 0)  printf(BOLDGREEN"  SUCCESS" RESET ": except_write_to_read_only_CSR_o is LOW\n");
    else                                                    printf(BOLDRED "  FAILED" RESET ":  except_write_to_read_only_CSR_o is HIGH\n");

    // We now evaluate the low clock cycle before returning
    csr_reg_file->clk_i = 0;
    csr_reg_file->eval();
    m_trace->dump(sim_time);
    sim_time++; 
    // printf("======================================================================================\n");
}

// This functions assumes CLK is set low, and last step of model was evaluated before calling
void attempt_read_and_write_to_RW_CSR(uint16_t addr, uint32_t val)
{

    // printf("======== Beginning WRITE TO READ ONLY CSR test =======================================\n");
    printf("\nAttempting write to CSR at address 0x%03x with value 0x%08x\n", addr, val);
    
    // Set read parameters to the CSR we are about to write, so we can check result
    csr_reg_file->read_enable_i = 1;
    csr_reg_file->read_addr_i = addr;

    // Set write inputs to write to given CSR with given value
    csr_reg_file->write_enable_i = 1;
    csr_reg_file->write_addr_i = addr;
    csr_reg_file->write_val_i = val;

    csr_reg_file->clk_i = 1;
    csr_reg_file->eval();
    m_trace->dump(sim_time);
    sim_time++; 

    csr_reg_file->clk_i = 0;
    csr_reg_file->eval();
    m_trace->dump(sim_time);
    sim_time++; 

    // csr_reg_file->read_enable_i = 0;
    // csr_reg_file->write_enable_i = 0;

    // Eval next posedge, and THEN check for output changes from prev. posedge
    csr_reg_file->clk_i = 1;
    csr_reg_file->eval();
    m_trace->dump(sim_time);
    sim_time++; 

    // Now let us verify that the outputs are as expected
    if (csr_reg_file->csr_reg_read_o == val)  printf(BOLDGREEN "  SUCCESS" RESET ": Value was correctly written as %08x \n", csr_reg_file->csr_reg_read_o);
    else                                    printf(BOLDRED "  FAILED" RESET ":  Unexpected value (incorrect write): %08x \n", csr_reg_file->csr_reg_read_o);

    if (csr_reg_file->except_read_non_existent_CSR_o == 0)  printf(BOLDGREEN "  SUCCESS" RESET ": except_read_non_existent_CSR_o is LOW\n");
    else                                                    printf(BOLDRED "  FAILED" RESET ":  except_read_non_existent_CSR_o is HIGH\n");

    if (csr_reg_file->except_write_non_existent_CSR_o == 0)  printf(BOLDGREEN "  SUCCESS" RESET ": except_write_non_existent_CSR_o is LOW\n");
    else                                                    printf(BOLDRED "  FAILED" RESET ":  except_write_non_existent_CSR_o is HIGH\n");

    if (csr_reg_file->except_write_to_read_only_CSR_o == 0)  printf(BOLDGREEN"  SUCCESS" RESET ": except_write_to_read_only_CSR_o is LOW\n");
    else                                                    printf(BOLDRED "  FAILED" RESET ":  except_write_to_read_only_CSR_o is HIGH\n");

    // We now evaluate the low clock cycle before returning
    csr_reg_file->clk_i = 0;
    csr_reg_file->eval();
    m_trace->dump(sim_time);
    sim_time++; 
    // printf("======================================================================================\n");
}

// This functions assumes CLK is set low, and last step of model was evaluated before calling
void attempt_read_and_write_to_WARL_RW_CSR(uint16_t addr, uint32_t val)
{

    // printf("======== Beginning WRITE TO READ ONLY CSR test =======================================\n");
    printf("\nAttempting write to CSR at address 0x%03x with value 0x%08x\n", addr, val);
    
    // Set read parameters to the CSR we are about to write, so we can check result
    csr_reg_file->read_enable_i = 1;
    csr_reg_file->read_addr_i = addr;

    // Set write inputs to write to given CSR with given value
    csr_reg_file->write_enable_i = 1;
    csr_reg_file->write_addr_i = addr;
    csr_reg_file->write_val_i = val;

    csr_reg_file->clk_i = 1;
    csr_reg_file->eval();
    m_trace->dump(sim_time);
    sim_time++; 

    csr_reg_file->clk_i = 0;
    csr_reg_file->eval();
    m_trace->dump(sim_time);
    sim_time++; 

    // csr_reg_file->read_enable_i = 0;
    // csr_reg_file->write_enable_i = 0;

    // Eval next posedge, and THEN check for output changes from prev. posedge
    csr_reg_file->clk_i = 1;
    csr_reg_file->eval();
    m_trace->dump(sim_time);
    sim_time++; 

    // Now let us verify that the outputs are as expected
    if (csr_reg_file->csr_reg_read_o == 0x00)  printf(BOLDGREEN "  SUCCESS" RESET ": Legal value was kept as expected: %08x \n", csr_reg_file->csr_reg_read_o);
    else                                    printf(BOLDRED "  FAILED" RESET ":  Unexpected value (incorrect write): %08x \n", csr_reg_file->csr_reg_read_o);

    if (csr_reg_file->except_read_non_existent_CSR_o == 0)  printf(BOLDGREEN "  SUCCESS" RESET ": except_read_non_existent_CSR_o is LOW\n");
    else                                                    printf(BOLDRED "  FAILED" RESET ":  except_read_non_existent_CSR_o is HIGH\n");

    if (csr_reg_file->except_write_non_existent_CSR_o == 0)  printf(BOLDGREEN "  SUCCESS" RESET ": except_write_non_existent_CSR_o is LOW\n");
    else                                                    printf(BOLDRED "  FAILED" RESET ":  except_write_non_existent_CSR_o is HIGH\n");

    if (csr_reg_file->except_write_to_read_only_CSR_o == 0)  printf(BOLDGREEN"  SUCCESS" RESET ": except_write_to_read_only_CSR_o is LOW\n");
    else                                                    printf(BOLDRED "  FAILED" RESET ":  except_write_to_read_only_CSR_o is HIGH\n");

    // We now evaluate the low clock cycle before returning
    csr_reg_file->clk_i = 0;
    csr_reg_file->eval();
    m_trace->dump(sim_time);
    sim_time++; 
    // printf("======================================================================================\n");
}

int main(int argc, char** argv) 
{
    Verilated::commandArgs(argc, argv);   // Remember args
    Verilated::traceEverOn(true); 

    std::cout << "Beginning simulation...\n";
    csr_reg_file = new Vcsr_reg_file;             // Create model
    m_trace = new VerilatedVcdC;
    csr_reg_file->trace(m_trace, 5);
    m_trace->open("csr_reg_waveform.vcd");


    csr_reg_file->clk_i = 0;
    csr_reg_file->eval();
    m_trace->dump(sim_time);
    sim_time++; 
    m_trace->dump(sim_time);
    sim_time++;


    // Functions called from here on out should expect CLK set low, and should
    // set it back to low, and call eval before returning
    
    attempt_write_to_read_only_CSR(MVENDORID_ADDR, 0x45);
    attempt_write_to_read_only_CSR(MARCHID_ADDR, 0x45);
    attempt_write_to_read_only_CSR(MIMPID_ADDR, 0x45);
    attempt_write_to_read_only_CSR(MHARTID_ADDR, 0x45);

    attempt_read_and_write_to_non_existent_CSR(NON_EXIST_CSR_ADDR_1, 0x45);
    attempt_read_and_write_to_non_existent_CSR(NON_EXIST_CSR_ADDR_2, 0x45);
    attempt_read_and_write_to_non_existent_CSR(NON_EXIST_CSR_ADDR_3, 0x45);

    attempt_read_and_write_to_WARL_RW_CSR(MISA_ADDR, 0x45);

    attempt_read_and_write_to_RW_CSR(MIE_ADDR, 0x45);
    attempt_read_and_write_to_RW_CSR(MTVEC_ADDR, 0x45);
    attempt_read_and_write_to_RW_CSR(MEPC_ADDR, 0x45);
    attempt_read_and_write_to_RW_CSR(MCAUSE_ADDR, 0x45);
    attempt_read_and_write_to_RW_CSR(MTVAL_ADDR, 0x45);
    attempt_read_and_write_to_RW_CSR(MIP_ADDR, 0x45);

    csr_reg_file->final();               // Done simulating
    m_trace->close();

    delete csr_reg_file;
    delete m_trace; 

    std::cout << "Ending simulation...\n";

    return EXIT_SUCCESS;
}
