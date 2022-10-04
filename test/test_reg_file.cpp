#include <verilated.h>          // Defines common routines
#include <iostream>             // Need std::cout
#include "Vreg_file.h"               // From Verilating "top.v"

Vreg_file* reg_file;                      // Instantiation of model

uint64_t main_time = 0;       // Current simulation time
// This is a 64-bit integer to reduce wrap over issues and
// allow modulus.  This is in units of the timeprecision
// used in Verilog (or from --timescale-override)

double sc_time_stamp() // Called by $time in Verilog
{        
    return main_time;           // converts to double, to match
                                // what SystemC does
}

// NOTE: This testbench is ugly as hell, it's just a proof of concept
// It will be cleaned up asap
int main(int argc, char** argv) 
{
    Verilated::commandArgs(argc, argv);   // Remember args

    std::cout << "Beginning simulation...\n";
    reg_file = new Vreg_file;             // Create model

    // Begin setting and inspecting signals
    reg_file->clk_i = 0;       // Init clock

    // We are gonna be testing registers 0 and 1
    reg_file->read_addr_1_i = 0;
    reg_file->read_addr_2_i = 31;
    reg_file->eval();            // Evaluate model
    // Initial values should be zero
    std::cout << "x0: " << reg_file->reg_1_o << std::endl;       // Read a output
    std::cout << "x31: " << reg_file->reg_2_o << std::endl;       // Read a output

    reg_file->clk_i ^= 1;       // Toggle clock

    // Now try writing to register 0, this should not do anything
    std::cout << "Attempting to write 0x45 into x0...\n";
    reg_file->write_enable_i = 1;
    reg_file->write_addr_i = 0;
    reg_file->write_val_i = 0x45;
    reg_file->eval();            // Evaluate model

    reg_file->clk_i ^= 1;       // Toggle clock
    reg_file->eval();            // Evaluate model

    reg_file->clk_i ^= 1;       // Toggle clock
    reg_file->eval();            // Evaluate model
    std::cout << "x0: " << reg_file->reg_1_o << std::endl;       // Read a output
    std::cout << "x31: " << reg_file->reg_2_o << std::endl;       // Read a output

    reg_file->clk_i ^= 1;       // Toggle clock
    reg_file->eval();            // Evaluate model
    
    reg_file->clk_i ^= 1;       // Toggle clock

    // Now try writing to register 1, this should succeed
    std::cout << "Attempting to write 0x45 into x31...\n";
    reg_file->write_enable_i = 1;
    reg_file->write_addr_i = 31;
    reg_file->write_val_i = 0x45;
    reg_file->eval();            // Evaluate model

    reg_file->clk_i ^= 1;       // Toggle clock
    reg_file->eval();            // Evaluate model

    reg_file->clk_i ^= 1;       // Toggle clock
    reg_file->eval();            // Evaluate model
    std::cout << "x0: " << reg_file->reg_1_o << std::endl;       // Read a output
    std::cout << "x31: " << reg_file->reg_2_o << std::endl;       // Read a output

    reg_file->clk_i ^= 1;       // Toggle clock
    reg_file->eval();            // Evaluate model
    // Test reset
    reg_file->clk_i ^= 1;       // Toggle clock
    std::cout << "Resetting all registers..\n";
    reg_file->rst_i = 1;
    reg_file->write_enable_i = 0;
    reg_file->eval();            // Evaluate model
    std::cout << "x0: " << reg_file->reg_1_o << std::endl;       // Read a output
    std::cout << "x31: " << reg_file->reg_2_o << std::endl;       // Read a output
    // End setting and inspecting signals
    reg_file->final();               // Done simulating
    delete reg_file;
    std::cout << "Ending simulation...\n";
}
