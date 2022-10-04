#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <iostream>
#include <fstream>
#include <execinfo.h>
#include <signal.h>

#include "Vmod_cpu.h"
// #include "Vmod_cpu_ram.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#define RAM_OFFSET 0xBFC00000
#define RAM_BYTES 4096
#define MAX_TICKS 4096

class ModuleRAM
{
public:
    VL_IN8(&clk_i, 0, 0);
    VL_IN8(&rst_i, 0, 0);
    VL_IN8(&wb_cyc_i, 0, 0);
    VL_IN8(&wb_we_i, 0, 0);
    VL_IN8(&wb_sel_i, 3, 0);
    VL_IN(&wb_adr_i, 31, 0);
    VL_IN(&wb_dat_i, 31, 0);
    VL_OUT(&wb_dat_o, 31, 0);
    VL_OUT8(&wb_ack_o, 0, 0);

    bool destroy_on_read_with_byteenable;

    ModuleRAM(CData &clk_i, CData &rst_i, CData &wb_cyc_i, CData &wb_we_i, CData &wb_sel_i, IData &wb_adr_i, IData &wb_dat_i, IData &wb_dat_o, CData &wb_ack_o) : clk_i{clk_i}, rst_i{rst_i}, wb_cyc_i{wb_cyc_i}, wb_we_i{wb_we_i}, wb_sel_i{wb_sel_i}, wb_adr_i{wb_adr_i}, wb_dat_i{wb_dat_i}, wb_dat_o{wb_dat_o}, wb_ack_o{wb_ack_o}
    {
        this->prev_clk = 0;
        this->destroy_on_read_with_byteenable = false;
        // for (int i = 0; i < RAM_BYTES / 4; i += 4)
        // {
        //     this->memory[3 + i] = 0x24;
        //     this->memory[2 + i] = i == 0 ? 0x02 : 0x42;
        //     this->memory[1 + i] = 0x00;
        //     this->memory[0 + i] = 0x02;
        // }
    }

    void eval()
    {
        _eval();
        this->prev_clk = clk_i;
        return;
    };

    void load(std::vector<uint8_t> &data)
    {
        size_t len = sizeof(this->memory);
        if (data.size() < len)
        {
            len = data.size();
        }
        memcpy(this->memory, data.data(), len);
    }

private:
    uint8_t memory[RAM_BYTES];
    IData get_mapped_address() { return this->wb_adr_i - RAM_OFFSET; }
    CData prev_clk;
    bool request_in_progress;

    void _eval();
};

void ModuleRAM::_eval()
{
    // TODO: make wb_ack_o do something useful.
    if (this->rst_i == 1)
    {
        // this->prev_clk = 0;
        this->wb_ack_o = 0;
        this->wb_dat_o = 0;
        this->request_in_progress = false;
    }

    if (this->wb_cyc_i == 0)
    {
        // Terminate the request
        this->request_in_progress = false;
    }

    bool is_rising_edge = (this->clk_i == 1 && this->prev_clk == 0);
    if (is_rising_edge)
    {
        // Reset at every rising edge.
        this->wb_ack_o = 0;
    }

    if (!is_rising_edge || wb_adr_i == 0 || !(this->wb_cyc_i))
    {
        // Not rising edge, or not read/write operation
        return;
    }

    if (!this->request_in_progress)
    {
        this->request_in_progress = true;
        return;
    }

    // We're handling this request now
    this->request_in_progress = false;

    IData mapped_address = get_mapped_address();
    if ((mapped_address > RAM_BYTES) && (wb_adr_i != 0))
    {
        if (this->wb_we_i)
        {
            std::cout << "out of bounds write to " << std::hex << wb_adr_i << std::endl;
            throw std::runtime_error("out of bounds write");
        }
        throw std::runtime_error("out of bounds read");
    }

    CData byteenable_0 = wb_sel_i & 1;
    CData byteenable_1 = (wb_sel_i >> 1) & 1;
    CData byteenable_2 = (wb_sel_i >> 2) & 1;
    CData byteenable_3 = (wb_sel_i >> 3) & 1;

    IData ram_read_0 = this->memory[mapped_address];
    IData ram_read_1 = this->memory[mapped_address + 1];
    IData ram_read_2 = this->memory[mapped_address + 2];
    IData ram_read_3 = this->memory[mapped_address + 3];

    IData writedata_0 = this->wb_dat_i & 0xFF;
    IData writedata_1 = (this->wb_dat_i >> 8) & 0xFF;
    IData writedata_2 = (this->wb_dat_i >> 16) & 0xFF;
    IData writedata_3 = (this->wb_dat_i >> 24) & 0xFF;

    if (this->wb_we_i)
    {
        IData write_0 = (byteenable_0 == 1) ? writedata_0 : ram_read_0;
        IData write_1 = (byteenable_1 == 1) ? writedata_1 : ram_read_1;
        IData write_2 = (byteenable_2 == 1) ? writedata_2 : ram_read_2;
        IData write_3 = (byteenable_3 == 1) ? writedata_3 : ram_read_3;
        this->memory[mapped_address] = write_0;
        this->memory[mapped_address + 1] = write_1;
        this->memory[mapped_address + 2] = write_2;
        this->memory[mapped_address + 3] = write_3;
    }
    else
    {
        this->wb_dat_o = (byteenable_3 ? ram_read_3 << 24 : 0) | (byteenable_2 ? ram_read_2 << 16 : 0) | (byteenable_1 ? ram_read_1 << 8 : 0) | (byteenable_0 ? ram_read_0 : 0);

        if (this->destroy_on_read_with_byteenable)
        {
            // Special test mode
            std::cout << "Destroying bytes @ 0x" << std::hex << wb_adr_i << std::endl;
            this->memory[mapped_address] = byteenable_0 ? 0xFF : ram_read_0;
            this->memory[mapped_address + 1] = byteenable_1 ? 0xFF : ram_read_1;
            this->memory[mapped_address + 2] = byteenable_2 ? 0xFF : ram_read_2;
            this->memory[mapped_address + 3] = byteenable_3 ? 0xFF : ram_read_3;
        }
    }

    this->wb_ack_o = 1;
}

void load_ram_file(std::string filepath, std::vector<uint8_t> &buffer)
{
    std::ifstream file(filepath);

    buffer.reserve(RAM_BYTES);

    uint32_t temp = 0;
    while (!file.eof())
    {
        file >> std::hex >> temp;
        buffer.push_back(temp);
    }
}

class TB
{
public:
    unsigned long m_tickcount;
    VerilatedVcdC *m_trace;
    Vmod_cpu *m_core;
    ModuleRAM *ram;

    TB(std::string hex_instruction_filepath, bool destroy_on_read_with_byteenable)
    {
        // According to the Verilator spec, you *must* call
        // traceEverOn before calling any of the tracing functions
        // within Verilator.
        Verilated::traceEverOn(true);
        m_core = new Vmod_cpu;
        ram = new ModuleRAM(m_core->clk_i, m_core->rst_i, m_core->wb_cyc_o, m_core->wb_we_o, m_core->wb_sel_o, m_core->wb_adr_o, m_core->wb_dat_o, m_core->wb_dat_i, m_core->wb_ack_i);

        std::vector<uint8_t> ram_buf;
        load_ram_file(hex_instruction_filepath, ram_buf);
        ram->load(ram_buf);
        ram->destroy_on_read_with_byteenable = destroy_on_read_with_byteenable;
        if (destroy_on_read_with_byteenable)
        {
            std::cout << "destroy_on_read_with_byteenable is enabled" << std::endl;
        }

        std::cout << "Loaded test" << std::endl;
    }

    // Open/create a trace file
    virtual void opentrace(const char *vcdname)
    {
        if (!m_trace)
        {
            m_trace = new VerilatedVcdC;
            m_core->trace(m_trace, 99);
            m_trace->open(vcdname);
        }
    }

    // Close a trace file
    virtual void close(void)
    {
        if (m_trace)
        {
            m_trace->close();
            m_trace = NULL;
        }
    }

    virtual void reset(void)
    {
        m_core->rst_i = 1;
        this->tick();
        m_core->rst_i = 0;
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
        m_core->clk_i = 0;
        m_core->eval();
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
        m_core->clk_i = 1;
        m_core->eval();
        ram->clk_i = 1;
        ram->eval();
        if (m_trace)
            m_trace->dump(10 * m_tickcount);

        // Now the negative edge
        m_core->clk_i = 0;
        m_core->eval();
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

    virtual bool done(void) { return (Verilated::gotFinish()); }
};

uint32_t simulate(std::string hex_filepath)
{
    auto destroyByteEnableEnv = std::getenv("SIM_DESTROY_BYTE_ENABLE");
    bool destroyOnReadWithByteEnable = destroyByteEnableEnv != NULL;
    TB *tb = new TB(hex_filepath, destroyOnReadWithByteEnable);
    tb->opentrace("trace.vcd");
    tb->reset();

    while (!tb->done())
    {
        if (tb->m_tickcount > MAX_TICKS)
        {
            throw std::runtime_error("testbench timed out while running test");
        }
        tb->tick();
    }

    return tb->m_core->register_a0;
}

uint32_t simulate_file_argv(const char *path, uint32_t expected_value)
{
    auto test_path = std::string(path);
    try
    {
        std::cout << "Running test at " << test_path << std::endl;
        auto sim_result = simulate(test_path);
        std::cout << test_path << ": 0x" << std::hex << sim_result << std::endl;
        if (sim_result == expected_value)
        {
            return 0;
        }
        return 255;
    }
    catch (const std::exception &e)
    {
        std::cout << test_path << ": # threw exception -> " << e.what() << std::endl;
    }
    return -1;
}

void sigsev_handler(int sig)
{
    void *array[10];
    size_t size;
    size = backtrace(array, 10);
    fprintf(stderr, "Error: signal %d:\n", sig);
    backtrace_symbols_fd(array, size, STDERR_FILENO);
    exit(1);
}

int main(int argc, char **argv)
{
    signal(SIGSEGV, sigsev_handler); // install our handler

    // Initialize Verilators variables
    Verilated::commandArgs(argc, argv);

    const auto sz_expected_value = std::getenv("SIM_EXPECTED_VALUE");
    uint32_t expected_value = 0;
    if (sz_expected_value != NULL)
    {
        sscanf(sz_expected_value, "%x", &expected_value);
    }

    std::cout << "Running test; expecting 0x" << std::hex << expected_value << std::endl;

    if (argc == 1)
    {
        return simulate_file_argv("./riscv/addi/01_add_positive.asm.hex", expected_value);
    }

    if (argc != 2)
    {
        std::cout << "Exaclty one argument must be supplied" << std::endl;
    }

    return simulate_file_argv(argv[1], expected_value);
}
