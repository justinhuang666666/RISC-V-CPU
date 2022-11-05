#include <verilated.h>          // Defines common routines
#include <iostream>             // Need std::cout
#include <fstream>
#include "Vmod_mem_cache_set_associative.h"               // From Verilating "top.v"
#include <verilated_vcd_c.h>
#include <stdint.h>
#include <stdio.h>
#include <typeinfo>   //for debugging
#include "defines.h"

Vmod_mem_cache_set_associative * cache;                      // Instantiation of model
VerilatedVcdC* m_trace; 

vluint64_t sim_time = 0;

#define RAM_BYTES 4096

class ModuleRAM
{
public:

    VL_IN8(&clk_i, 0, 0);
    VL_IN8(&read_i, 0, 0);
    VL_IN8(&write_i, 0, 0);
    VL_IN(&memory_address_i, 31, 0);
    VL_IN(&memory_writedata_i, 31, 0);
    VL_OUT(&readdata_o, 31, 0);
    VL_OUT8(&memory_stb_o, 0, 0);

    ModuleRAM(CData &clk_i, CData &read_i, CData &write_i, IData &memory_address_i, IData &memory_writedata_i, IData &readdata_o, CData &memory_stb_o) : clk_i{clk_i}, read_i{read_i}, write_i{write_i}}, memory_address_i{memory_address_i}, memory_writedata_i{memory_writedata_i}, readdata_o{readdata_o}, memory_stb_o{memory_stb_o}
    {
    }
    void eval(){
        this->memory_stb_o = 0;

        IData ram_read_0 = this->memory[this->memory_address_i];
        IData ram_read_1 = this->memory[this->memory_address_i + 1];
        IData ram_read_2 = this->memory[this->memory_address_i + 2];
        IData ram_read_3 = this->memory[this->memory_address_i + 3];

        IData writedata_0 = this->memory_writedata_i & 0xFF;
        IData writedata_1 = (this->memory_writedata_i >> 8) & 0xFF;
        IData writedata_2 = (this->memory_writedata_i >> 16) & 0xFF;
        IData writedata_3 = (this->memory_writedata_i >> 24) & 0xFF;

        if (this->write_i & (this->memory_address_i != 0))//write to RAM
        {
            this->memory[this->memory_address_i] = writedata_0;
            this->memory[this->memory_address_i + 1] = writedata_1;
            this->memory[this->memory_address_i + 2] = writedata_2;
            this->memory[this->memory_address_i + 3] = writedata_3;
            this->memory_stb_o = 1;
        }
        else if(this->read_i & (this->memory_address_i != 0))//read from RAM
        {
            this->readdata_o = (ram_read_3) | (ram_read_2) | (ram_read_1) | (ram_read_0);
            this->memory_stb_o = 1;
        }
    }
    void load(std::vector<uint8_t> &data){
        size_t len = sizeof(this->memory);
        if (data.size() < len)
        {
            len = data.size();
        }
        memcpy(this->memory, data.data(), len);
        //copy data into memory 
        //.data() returns a direct pointer to the memory array used internally by the vector 
        //to store its owned elements.
    }
private:
    uint8_t memory[RAM_BYTES];//4096*8 32KB
};


void load_ram_file(std::string filepath, std::vector<uint8_t> &buffer)
{
    std::ifstream file(filepath);

    buffer.reserve(RAM_BYTES); 
    //Requests that the vector capacity be at least enough to contain n elements.

    uint32_t temp = 0;
    while (!file.eof())
    {
        file >> std::hex >> temp;
        // std::cout<<"----"<<std::endl;
        // std::cout<<std::hex<<temp<<std::endl;
        buffer.push_back(temp);
    }
}

void reset_cache(){
    cache->rst_i = 1;
    cache->clk_i ^= 1;       // Toggle clock
    cache->eval();            // Evaluate model
    m_trace->dump(sim_time);
    sim_time++;
    cache->clk_i ^= 1;       // Toggle clock
    cache->eval();            // Evaluate model
    m_trace->dump(sim_time);
    sim_time++;
    cache->rst_i = 0;
}

void write_cache(uint32_t address_i, uint32_t writedata_i){
    // clk_i,
    // rst_i,
    cache->address_i = address_i,
    cache->writedata_i = writedata_i,
    cache->read_i = 0b0,
    cache->write_i = 0b1,
    cache->byteenable_i = 0b1111;
    for(int i = 0; i < 10; i++){
        cache->clk_i ^= 1;       // Toggle clock
        cache->eval();            // Evaluate model
        m_trace->dump(sim_time);
        sim_time++;
        cache->clk_i ^= 1;       // Toggle clock
        cache->eval();            // Evaluate model
        m_trace->dump(sim_time);
        sim_time++;
    }
    // readdata_o,
    // address_o,

    // stb_o,
    // busy_o,
    // memory_readdata_i,
    // memory_operation_stb_i,
    // memory_address_o,
    // memory_writedata_o,
    // memory_write_o,
    // memory_read_o,
    // memory_byteenable_o
    
}

int main(int argc, char** argv) 
{
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true); 
    cache = new Vmod_mem_cache_set_associative;             // Create model
    m_trace = new VerilatedVcdC;
    cache->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    std::cout << "Beginning simulation...\n";
    ModuleRAM *ram;
    ram = new ModuleRAM(cache->clk_i, cache->memory_read_o, cache->memory_write_o, cache->memory_address_o, cache->memory_writedata_o, cache->memory_readdata_i,cache->memory_operation_stb_i);
    std::vector<uint8_t> ram_buf;
    load_ram_file("./test/cache.hex", ram_buf);
    ram->load(ram_buf);

    cache->clk_i = 0;
    cache->eval();
    m_trace->dump(sim_time);
    sim_time++;

    reset_cache();
    write_cache(0x1,0x1);

    m_trace->close();
    cache->final();               // Done simulating
    delete cache;
    std::cout << "Ending simulation...\n";
}