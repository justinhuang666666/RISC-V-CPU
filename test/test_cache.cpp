#include <verilated.h>          // Defines common routines
#include <iostream>             // Need std::cout
#include "Vmod_mem_cache_test.h"               // From Verilating "top.v"
#include <verilated_vcd_c.h>
#include <stdint.h>
#include <stdio.h>
#include <typeinfo>   //for debugging
#include "defines.h"

Vmod_mem_cache_test* cache;                      // Instantiation of model
VerilatedVcdC* m_trace; 

vluint64_t sim_time = 0;

// void display_cache(){

//     for(int i = 0; i < 32; i++){
//         std::cout<<*(cache->cache_rows_o+i)<<std::endl;
//     }

// }

int main(int argc, char** argv) 
{
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true); 
    cache = new Vmod_mem_cache_test;             // Create model
    m_trace = new VerilatedVcdC;
    cache->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    std::cout << "Beginning simulation...\n";
    cache->rst_i = 0;
    cache->clk_i = 0;
    cache->eval();
    m_trace->dump(sim_time);
    sim_time++;

    m_trace->close();
    cache->final();               // Done simulating
    delete cache;
    std::cout << "Ending simulation...\n";
}