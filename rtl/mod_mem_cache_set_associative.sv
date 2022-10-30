`include "system_defines.svh"

// Implements a 2-way set associative, LRU, write-through cache.
module mod_mem_cache (
    input logic clk_i,
    input logic rst_i,
    // Aborts a read operation by discarding the next result after
    // `memory_operation_stb_i` goes high (if a transaction is already in
    // progress) or going directly lowering `busy_o` if no transaction is in
    // progress. As such, stb_o should not output high until the next reaq/write
    // request to the cache is made. 
    input logic abort_i,
    input logic [`XLEN-1:0] address_i,
    input logic [`XLEN-1:0] writedata_i,
    input logic read_i,
    input logic write_i,
    input logic [`BYTEENABLE_WIDTH-1:0] byteenable_i,
    output logic [`XLEN-1:0] readdata_o,
    output logic [`XLEN-1:0] address_o,
    // Signals that all requested operations are completed.
    output logic stb_o,
    output logic busy_o,

    // I/O for talking to main memory.
    input logic [`XLEN-1:0] memory_readdata_i,
    // Signals that the read/write to memory is complete.
    input logic memory_operation_stb_i,//loadstore_stb
    output logic [`XLEN-1:0] memory_address_o,
    output logic [`XLEN-1:0] memory_writedata_o,
    output logic memory_write_o,
    output logic memory_read_o,
    output logic [`BYTEENABLE_WIDTH-1:0] memory_byteenable_o
);

    enum{
        IDLE;
        READ;
        WRITE;
        READMM;
        ABORT;
        UPDATEMM;
        UPDATECACHE;
        DONE
    }
        current_state, next_state;

    // The number of bits used to identify which cache bank (row) to use.
    localparam CACHE_BANK_BITS = 5;
    // The number of banks/rows (computed from the number of bits).
    localparam CACHE_BANK_ENTRIES = 2 ** CACHE_BANK_BITS;
    // The number of bits to use for the row tag.
    localparam CACHE_TAG_BITS = 26;

    typedef logic [`XLEN-1:0] xlen_t;
    typedef logic [CACHE_TAG_BITS-1:0] cache_tag_t;

    typedef struct packed {
        logic valid;
        logic used;
        logic dirty;
        cache_tag_t tag;
        xlen_t data;
        
    } cache_row_t;

    // Registers for persisting memory values, so we don't rely on the input being
    // held constant over several clock cycles.
    logic [`BYTEENABLE_WIDTH-1:0] memory_byteenable_q;
    logic [`XLEN-1:0] memory_address_q, memory_writedata_q, address_q;
    logic memory_write_q, memory_read_q;

    // These outputs come from the registers.
    assign memory_byteenable_o = memory_byteenable_q;
    assign memory_address_o = memory_address_q;
    assign memory_writedata_o = memory_writedata_q;
    assign memory_write_o = memory_write_q;
    assign memory_read_o = memory_read_q;

    assign address_o = address_q;

    assign stb_o = (current_state == DONE);//TODO: change to data_valid
    assign busy_o = (current_state != IDLE);

    always_comb begin
        case(current_state) begin

        end
    end

    // Update state machine state.
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end