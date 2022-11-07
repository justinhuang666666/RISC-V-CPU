`include "system_defines.svh"

// Implements a 2-way set associative, LRU, write-through cache.
module mod_mem_cache_set_associative_2 (
    input logic clk_i,
    input logic rst_i,
    // Aborts a read operation by discarding the next result after
    // `memory_operation_stb_i` goes high (if a transaction is already in
    // progress) or going directly lowering `busy_o` if no transaction is in
    // progress. As such, stb_o should not output high until the next reaq/write
    // request to the cache is made. 
    //input logic abort_i, //not considered for simplicity
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
        IDLE,
        READ,
        WRITE,
        READMM,
        UPDATEMM,
        UPDATECACHE,
        DONE
    }
        state;

    // The number of bits used to identify which cache bank (row) to use.
    // localparam CACHE_BANK_BITS = 5;
    // The number of bits used to identify which set to use.
    localparam CACHE_SET_BITS = 4;
    // The number of sets (computed from the number of bits).
    localparam CACHE_SET_ENTRIES = 2 ** CACHE_SET_BITS;
    // The number of banks/rows (computed from the number of bits).
    //localparam CACHE_BANK_ENTRIES = 2 ** CACHE_BANK_BITS;
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

    typedef struct packed{
        cache_row_t row1;
        cache_row_t row2;
    } cache_set_t;

    // Registers for persisting memory values, so we don't rely on the input being
    // held constant over several clock cycles.
    logic [`BYTEENABLE_WIDTH-1:0] memory_byteenable_q;
    logic [`XLEN-1:0] memory_address_q, memory_writedata_q, address_q;
    logic memory_write_q, memory_read_q;
    
    //read_i write_i register
    logic rdwr;
    //memory address register
    logic [`XLEN-1:0] memory_address_reg;

    // These outputs come from the registers.
    assign memory_byteenable_o = memory_byteenable_q;
    assign memory_address_o = memory_address_q;
    assign memory_writedata_o = memory_writedata_q;
    assign memory_write_o = memory_write_q;
    assign memory_read_o = memory_read_q;

    assign address_o = address_q;

    assign stb_o = (state == DONE);//TODO: change to data_valid
    assign busy_o = (state != IDLE);

    // The cache memory.  
    cache_set_t [CACHE_SET_ENTRIES-1:0] cache_sets;
    logic [CACHE_SET_BITS-1:0] cache_set_index;
    //register address_i
    assign cache_set_index = (state == IDLE) ? address_i[CACHE_SET_BITS-1+2:2] : memory_address_reg[CACHE_SET_BITS-1+2:2];

    // The cache rows which corresponds to the set index in the address.
    // cache_row_t cache_row_1, cache_row_2;
    // assign cache_row_1 = cache_sets[cache_set_index].row1; 
    // assign cache_row_2 = cache_sets[cache_set_index].row2; 

    // Whether the cache row is valid (i.e. can be used for cache hits).
    logic cache_row_1_valid, cache_row_2_valid, valid;
    assign cache_row_1_valid = cache_sets[cache_set_index].row1.valid;
    assign cache_row_2_valid = cache_sets[cache_set_index].row2.valid;
    assign valid = cache_row_1_valid & cache_row_2_valid;

    // Whether the cache row is used recently
    logic cache_row_1_used;
    assign cache_row_1_used = cache_sets[cache_set_index].row1.used;
    // logic cache_row_2_used;
    // assign cache_row_2_used = cache_row_2.used;

    // Whether the cache row is dirty
    logic cache_row_1_dirty, cache_row_2_dirty, dirty;
    assign cache_row_1_dirty = cache_sets[cache_set_index].row1.dirty;
    assign cache_row_2_dirty = cache_sets[cache_set_index].row2.dirty;
    assign dirty = cache_row_1_dirty | cache_row_2_dirty;

    // The tag of the cache row in the set.
    cache_tag_t cache_row_1_tag, cache_row_2_tag;
    assign cache_row_1_tag = cache_sets[cache_set_index].row1.tag;
    assign cache_row_2_tag = cache_sets[cache_set_index].row2.tag;

    // The data in the corresponding cache entry for the supplied address.
    // xlen_t cache_row_1_data, cache_row_2_data;
    // assign cache_row_1_data = cache_row_1.data;
    // assign cache_row_2_data = cache_row_2.data;

    // Backing register for the returned data from a cache hit / memory read.
    xlen_t readdata_q;
    assign readdata_o = readdata_q;

    // The tag bits of the supplied address.
    logic [CACHE_TAG_BITS-1:0] address_tag;
    assign address_tag = state == IDLE ? address_i[31-:CACHE_TAG_BITS] : memory_address_reg[31-:CACHE_TAG_BITS];

    //hit?
    logic hit_row_1, hit_row_2, hit;
    assign hit_row_1 = cache_row_1_valid & (cache_row_1_tag == address_tag);
    assign hit_row_2 = cache_row_2_valid & (cache_row_2_tag == address_tag);
    assign hit = hit_row_1 | hit_row_2;

    // Reset logic for cache rows.
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            for (int i = 0; i < $size(cache_sets); i++) begin
                cache_sets[i].row1 <= '0;
                cache_sets[i].row2 <= '0;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            memory_address_reg <= 0;

            memory_address_q <= 0;
            memory_writedata_q <= 0;
            memory_byteenable_q <= 0;
            memory_read_q <= 0;
            memory_write_q <= 0;

            address_q  <= 0;
            readdata_q <= 0;

            state <= IDLE;
            rdwr <= 1'b1;
        end 
        else begin
            case (state)
                IDLE: begin
                    $display(" ");
                    $display("IDLE");
                    memory_address_reg <= address_i;

                    memory_address_q <= 0;
                    memory_writedata_q <= 0;
                    memory_byteenable_q <= 0;
                    memory_read_q <= 0;
                    memory_write_q <= 0;

                    address_q  <= 0;
                    readdata_q <= 0;

                    if(read_i) begin
                        state	<= READ;
                        rdwr	<= 1'd1;
                    end 
                    else if(write_i) begin
                        state	<= WRITE;
                        rdwr	<= 1'd0;
					end 
                    else begin
						state	<= state;
					end
                end
                READ: begin
                    $display(" ");
                    $display("READ");
                    memory_address_q <= 0;
                    memory_writedata_q <= 0;
                    memory_byteenable_q <= 0;
                    memory_read_q <= 0;
                    memory_write_q <= 0;

                    address_q <= 0;
                    readdata_q <= 0;
                    case(hit)
                        //read miss
                        1'b0: begin
                            //write back cache line to MM
                            if(valid & dirty) begin
                                state <= UPDATEMM;
                            end 
                            else begin
                                state <= READMM;
                            end
                        end
                        //read hit
                        1'b1: begin
                            state <= DONE;
                            //hit row 1
                            //update used bit
                            if(hit_row_1) begin
                                cache_sets[cache_set_index].row1.used <= 1'b1;
                                cache_sets[cache_set_index].row2.used <= 1'b0;
                            //hit row 2 
                            end 
                            else begin
                                cache_sets[cache_set_index].row1.used <= 1'b0;
                                cache_sets[cache_set_index].row2.used <= 1'b1;
                            end
                        end
                    endcase
                end
                WRITE: begin
                    $display(" ");
                    $display("WRITE");
                    memory_address_q <= 0;
                    memory_writedata_q <= 0;
                    memory_byteenable_q <= 0;
                    memory_read_q <= 0;
                    memory_write_q <= 0;

                    address_q <= 0;
                    readdata_q <= 0;
                    case(hit)
                        //write miss
                        1'b0: begin
                            //write back cache line to MM
                            if(valid & dirty) begin
                                state <= UPDATEMM;
                            end 
                            else begin
                                state <= READMM;
                            end
                        end
                        //write hit
                        1'b1: begin
                            state <= DONE;
                            //hit row 1
                            //update used bit
                            if(hit_row_1) begin
                                cache_sets[cache_set_index].row1.valid <= 1'b1;
                                cache_sets[cache_set_index].row1.used <= 1'b1;
                                cache_sets[cache_set_index].row1.dirty <= 1'b1;
                                cache_sets[cache_set_index].row1.tag <= address_tag;
                                cache_sets[cache_set_index].row1.data <= writedata_i;

                                cache_sets[cache_set_index].row2.used <= 1'b0;
                            end 
                            else begin
                                cache_sets[cache_set_index].row2.valid <= 1'b1;
                                cache_sets[cache_set_index].row2.used <= 1'b1;
                                cache_sets[cache_set_index].row2.dirty <= 1'b1;
                                cache_sets[cache_set_index].row2.tag <= address_tag;
                                cache_sets[cache_set_index].row2.data <= writedata_i;

                                cache_sets[cache_set_index].row1.used <= 1'b0;
                            end
                        end
                    endcase
                end
                READMM: begin
                    memory_address_q <= memory_address_reg;
                    memory_writedata_q <= 0;
                    memory_byteenable_q <= byteenable_i;
                    memory_read_q <= 1;
                    memory_write_q <= 0;

                    address_q <= 0;
                    readdata_q <= 0;

                    if(memory_operation_stb_i) begin
                        state <= UPDATECACHE;
                    end 
                    else begin
                        state <= state;
                    end
                    $display(" ");
                    $display("READMM");
                end
                UPDATEMM: begin
                    //write back LRU dirty cache line
                    if(cache_row_1_used) begin
                        //row 1 is used write back row 2
                        memory_address_q <= {cache_sets[cache_set_index].row2.tag,cache_set_index,2'b0};
                        memory_writedata_q <= cache_sets[cache_set_index].row2.data;
                        memory_byteenable_q <= byteenable_i;
                        memory_read_q <= 0;
                        memory_write_q <= 1;
                    end 
                    else begin
                        //row 2 is used write back row 1
                        memory_address_q <= {cache_sets[cache_set_index].row1.tag,cache_set_index,2'b0};
                        memory_writedata_q <= cache_sets[cache_set_index].row1.data;
                        memory_byteenable_q <= byteenable_i;
                        memory_read_q <= 0;
                        memory_write_q <= 1;
                    end

                    if(memory_operation_stb_i) begin
                        state <= READMM;
                    end 
                    else begin
                        state <= state;
                    end
                    $display(" ");
                    $display("UPDATEMM");
                end
                UPDATECACHE: begin
                    memory_address_q <= 0;
                    memory_writedata_q <= 0;
                    memory_byteenable_q <= 0;
                    memory_read_q <= 0;
                    memory_write_q <= 0;

                    address_q <= 0;
                    readdata_q <= 0;
                    if(rdwr) begin
                        if(cache_row_1_used) begin
                            //row 1 recently used update row 2
                            cache_sets[cache_set_index].row2.valid <= 1'b1;
                            cache_sets[cache_set_index].row2.used <= 1'b1;
                            cache_sets[cache_set_index].row2.dirty <= 1'b0;
                            cache_sets[cache_set_index].row2.tag <= address_tag;
                            cache_sets[cache_set_index].row2.data <= memory_readdata_i;

                            cache_sets[cache_set_index].row1.used <= 1'b0;
                        end 
                        else begin
                            //row 2 used update row 1
                            cache_sets[cache_set_index].row1.valid <= 1'b1;
                            cache_sets[cache_set_index].row1.used <= 1'b1;
                            cache_sets[cache_set_index].row1.dirty <= 1'b0;
                            cache_sets[cache_set_index].row1.tag <= address_tag;
                            cache_sets[cache_set_index].row1.data <= memory_readdata_i;

                            cache_sets[cache_set_index].row2.used <= 1'b0;
                        end
                    end 
                    else begin
                        if(cache_row_1_used) begin
                            //row 1 recently used update row 2
                            cache_sets[cache_set_index].row2.valid <= 1'b1;
                            cache_sets[cache_set_index].row2.used <= 1'b1;
                            cache_sets[cache_set_index].row2.dirty <= 1'b0;
                            cache_sets[cache_set_index].row2.tag <= address_tag;
                            cache_sets[cache_set_index].row2.data <= writedata_i;

                            cache_sets[cache_set_index].row1.used <= 1'b0;
                        end 
                        else begin
                            //row 2 used update row 1
                            cache_sets[cache_set_index].row1.valid <= 1'b1;
                            cache_sets[cache_set_index].row1.used <= 1'b1;
                            cache_sets[cache_set_index].row1.dirty <= 1'b0;
                            cache_sets[cache_set_index].row1.tag <= address_tag;
                            cache_sets[cache_set_index].row1.data <= writedata_i;

                            cache_sets[cache_set_index].row2.used <= 1'b0;
                        end
                    end

                    state <= DONE;
                    $display(" ");
                    $display("UPDATECACHE");
                    // for (int i = 0; i < $size(cache_sets); i++) begin
                    //     $display("set%d:",i);
                    //     $display("valid: ",cache_sets[i].row1.tag," used: ",cache_sets[i].row1.used," dirty: ",cache_sets[i].row1.dirty," data: %h",cache_sets[i].row1.data);
                    //     $display("valid: ",cache_sets[i].row2.tag," used: ",cache_sets[i].row2.used," dirty: ",cache_sets[i].row2.dirty," data: %h",cache_sets[i].row2.data);
                    // end
                end
                DONE: begin
                    memory_writedata_q <= 0;
                    memory_byteenable_q <= 0;
                    memory_read_q <= 0;
                    memory_write_q <= 0;
                    if(rdwr) begin
                        address_q <= memory_address_reg;
                        if(hit_row_1) begin
                            readdata_q <= cache_sets[cache_set_index].row1.data;
                        end 
                        else begin
                            readdata_q <= cache_sets[cache_set_index].row2.data;
                        end
                    end 
                    else begin
                        address_q <= 0;
                        readdata_q <= 0;
                    end
                    state <= IDLE;
                    $display(" ");
                    $display("DONE");
                    for (int i = 0; i < $size(cache_sets); i++) begin
                        $display("set%d:",i);
                        $display("valid: ",cache_sets[i].row1.valid," used: ",cache_sets[i].row1.used," dirty: ",cache_sets[i].row1.dirty," data: %h",cache_sets[i].row1.data);
                        $display("valid: ",cache_sets[i].row2.valid," used: ",cache_sets[i].row2.used," dirty: ",cache_sets[i].row2.dirty," data: %h",cache_sets[i].row2.data);
                    end
                end
                default: begin
                    memory_address_reg <= 0;

                    memory_address_q <= 0;
                    memory_writedata_q <= 0;
                    memory_byteenable_q <= 0;
                    memory_read_q <= 0;
                    memory_write_q <= 0;

                    address_q <= 0;
                    readdata_q <= 0;

                    state <= IDLE;
                end
            endcase
        end
    end
endmodule

