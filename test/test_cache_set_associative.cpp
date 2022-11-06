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

class ModuleRAM{
public:
    VL_IN8(&clk_i, 0, 0);
    VL_IN8(&read_i, 0, 0);
    VL_IN8(&write_i, 0, 0);
    VL_IN(&memory_address_i, 31, 0);
    VL_IN(&memory_writedata_i, 31, 0);
    VL_OUT(&readdata_o, 31, 0);
    VL_OUT8(&memory_stb_o, 0, 0);

    ModuleRAM(CData &clk_i, CData &read_i, CData &write_i, IData &memory_address_i, IData &memory_writedata_i, IData &readdata_o, CData &memory_stb_o): clk_i{clk_i}, read_i{read_i}, write_i{write_i}, memory_address_i{memory_address_i}, memory_writedata_i{memory_writedata_i}, readdata_o{readdata_o}, memory_stb_o{memory_stb_o}
    {}
    void eval(){
        this->memory_stb_o = 0;
        this->readdata_o = 0;

        IData ram_read_0 = this->memory[this->memory_address_i];
        IData ram_read_1 = this->memory[this->memory_address_i + 1];
        IData ram_read_2 = this->memory[this->memory_address_i + 2];
        IData ram_read_3 = this->memory[this->memory_address_i + 3];

        IData writedata_0 = this->memory_writedata_i & 0xFF;
        IData writedata_1 = (this->memory_writedata_i >> 8) & 0xFF;
        IData writedata_2 = (this->memory_writedata_i >> 16) & 0xFF;
        IData writedata_3 = (this->memory_writedata_i >> 24) & 0xFF;

        if (this->write_i)//write to RAM
        {
            this->memory[this->memory_address_i] = writedata_0;
            this->memory[this->memory_address_i + 1] = writedata_1;
            this->memory[this->memory_address_i + 2] = writedata_2;
            this->memory[this->memory_address_i + 3] = writedata_3;
            this->memory_stb_o = 1;
        }
        else if(this->read_i)//read from RAM
        {
            this->readdata_o = (ram_read_3 << 24) | (ram_read_2 << 16) | (ram_read_1 << 8) | (ram_read_0);
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
    void display(){
        for(int i = 0; i < 30; i++){
            std::cout<<i<<" : "<<this->memory[i]<<std::endl;
            //std::cout<<i<<" : "<<this->memory[4*i]<<this->memory[4*i+1]<<this->memory[4*i+2]<<this->memory[4*i+3]<<std::endl;
        }
    }

private:
    uint8_t memory[RAM_BYTES];
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
class TB{
public:
    uint32_t m_tickcount;
    VerilatedVcdC *m_trace;
    Vmod_mem_cache_set_associative *cache;
    ModuleRAM *ram;

    TB(){
        
        Verilated::traceEverOn(true); 
        cache = new Vmod_mem_cache_set_associative;             // Create model
        ram = new ModuleRAM(cache->clk_i, cache->memory_read_o, cache->memory_write_o, cache->memory_address_o, cache->memory_writedata_o, cache->memory_readdata_i,cache->memory_operation_stb_i);
        std::vector<uint8_t> ram_buf;
        load_ram_file("./test/cache.hex", ram_buf);
        ram->load(ram_buf);
    }
    // Open/create a trace file
    virtual void opentrace(const char *vcdname)
    {
        if (!m_trace)
        {
            m_trace = new VerilatedVcdC;
            cache->trace(m_trace, 99);
            m_trace->open(vcdname);
        }
    }


    virtual void close(void)
    {
        if (m_trace)
        {
            m_trace->close();
            m_trace = NULL;
        }
        cache->final();
    }    // Close a trace file

    virtual void reset(void)
    {
        cache->rst_i = 1;
        this->tick();
        cache->rst_i = 0;
    }

    virtual void tick(void)
    {
        // Make sure the tickcount is greater than zero before
        // we do this
        m_tickcount++;

        // Allow any combinatorial logic to settle before we tick
        // the clock.  This becomes necessary in the case where
        // we may have modified or adjusted the inputs prior to
        // coming into here, since we need all combinatorial logic
        // to be settled before we call for a clock tick.
        //
        cache->clk_i = 0;
        cache->eval();
        ram->clk_i = 0;
        ram->eval();

        //
        // Here's the new item:
        //
        //	Dump values to our trace file
        //
        if (m_trace)
            m_trace->dump(10 * m_tickcount - 2);

        // Repeat for the positive edge of the clock
        cache->clk_i = 1;
        cache->eval();
        ram->clk_i = 1;
        ram->eval();
        if (m_trace)
            m_trace->dump(10 * m_tickcount);

        // Now the negative edge
        cache->clk_i = 0;
        cache->eval();
        ram->clk_i = 0;
        ram->eval();
        if (m_trace)
        {
            // This portion, though, is a touch different.
            // After dumping our values as they exist on the
            // negative clock edge ...
            m_trace->dump(10 * m_tickcount + 5);
            //
            // We'll also need to make sure we flush any I/O to
            // the trace file, so that we can use the assert()
            // function between now and the next tick if we want to.
            m_trace->flush();
        }
    }
    void write_cache(uint32_t address_i, uint32_t writedata_i){
        while(!cache->stb_o){
            cache->address_i = address_i,
            cache->writedata_i = writedata_i,
            cache->read_i = 0b0,
            cache->write_i = 0b1,
            cache->byteenable_i = 0b1111;
            this->tick();
        }
        this->tick();
    }
    void read_cache(uint32_t address_i){
        while(!cache->stb_o){
            cache->address_i = address_i,
            cache->read_i = 0b1,
            cache->write_i = 0b0,
            cache->byteenable_i = 0b1111;
            this->tick();
        }
        this->tick();
        std::cout<<cache->readdata_o<<std::endl;
    }
    void init_cache(){
        for(int i = 0; i < 32; i++){
        this->read_cache(i*4);
    }
    }
};

int main(int argc, char** argv) 
{
    Verilated::commandArgs(argc, argv);
    std::cout << "Beginning simulation...\n";
    TB *tb = new TB;
    tb->opentrace("trace.vcd");
    // case 1: read miss and write back dirty cache line 
    // tb->reset();
    // tb->init_cache();
    // tb->read_cache(0x4);
    // tb->write_cache(0x4,0xFFFFFFFF);
    // tb->read_cache(0x4);
    // tb->read_cache(0x44);
    // tb->read_cache(0x84);
    // tb->read_cache(0x4);
    // case 2: write miss and write back dirty cache line 
    tb->reset();
    tb->init_cache();
    tb->write_cache(0x4,0xFFFFFFFF);
    tb->read_cache(0x44);
    tb->write_cache(0x84,0x0F0F0F0F);
    tb->read_cache(0x4);
    tb->close();
    std::cout << "Ending simulation...\n";

}