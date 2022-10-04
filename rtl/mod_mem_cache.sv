`include "system_defines.svh"

// Implements a direct-mapped write-through cache.
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
    input logic memory_operation_stb_i,
    output logic [`XLEN-1:0] memory_address_o,
    output logic [`XLEN-1:0] memory_writedata_o,
    output logic memory_write_o,
    output logic memory_read_o,
    output logic [`BYTEENABLE_WIDTH-1:0] memory_byteenable_o
);

  enum {
    // IDLE represents no tx is pending.
    IDLE,
    // WRITE represents an on-going write operation to memory.
    WRITE,
    // MISS represents an on-going read operation from memory (due to a
    // cache-miss).
    MISS,
    // Waits until the current operation is complete and then discards the
    // result.
    ABORT,
    // DONE represents the state where the memory operation is complete (and for
    // a read, data is presented on the outputs).
    DONE
  }
      current_state, next_state;

  assign busy_o = current_state != IDLE;

  // The number of bits used to identify which cache bank (row) to use.
  localparam CACHE_BANK_BITS = 5;
  // The number of banks/rows (computed from the number of bits).
  localparam CACHE_BANK_ENTRIES = 2 ** CACHE_BANK_BITS;
  // The number of bits to use for the row tag.
  localparam CACHE_TAG_BITS = 28;

  typedef logic [`XLEN-1:0] xlen_t;
  typedef logic [CACHE_TAG_BITS-1:0] cache_tag_t;

  typedef struct packed {
    cache_tag_t tag;
    logic valid;
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

  // The cache memory.  
  cache_row_t [CACHE_BANK_ENTRIES-1:0] cache_rows;

  // The index of the cache row which corresponds to the bank bits in the
  // address.
  logic [CACHE_BANK_BITS-1:0] cache_row_number;
  assign cache_row_number = current_state == IDLE ? address_i[CACHE_BANK_BITS-1+2:2] : memory_address_q[CACHE_BANK_BITS-1+2:2];

  // The cache row which corresponds to the bank bits in the address.
  cache_row_t cache_row;
  assign cache_row = cache_rows[cache_row_number];

  // The tag of the selected cache row.
  cache_tag_t cache_row_tag;
  assign cache_row_tag = cache_row.tag;

  // Whether the cache row is valid (i.e. can be used for cache hits).
  logic cache_row_valid;
  assign cache_row_valid = cache_row.valid;

  // The data in the corresponding cache entry for the supplied address.
  xlen_t cache_row_data;
  assign cache_row_data = cache_row.data;

  // Operations are always done when the state is equal to DONE.
  assign stb_o = current_state == DONE;

  // Backing register for the returned data from a cache hit / memory read.
  xlen_t readdata_q;
  assign readdata_o = readdata_q;

  // The tag bits of the supplied address.
  logic [CACHE_TAG_BITS-1:0] address_tag;
  assign address_tag = current_state == IDLE ? address_i[31-:CACHE_TAG_BITS] : memory_address_q[31-:CACHE_TAG_BITS];

  // Reset logic for cache rows.
  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      for (int i = 0; i < $size(cache_rows); i++) begin
        cache_rows[i] <= '0;
      end
    end
  end

  // Perform a memory transaction for cache misses (read) or writes (due to this
  // being a write-through cache).
  always_ff @(posedge clk_i) begin
    if (rst_i || abort_i) begin
      memory_address_q <= 0;
      memory_writedata_q <= 0;
      memory_byteenable_q <= 0;
      memory_read_q <= 0;
      memory_write_q <= 0;
    end else if (current_state != next_state) begin
      case (next_state)
        MISS: begin
          memory_address_q <= address_i;
          memory_writedata_q <= 0;
          memory_byteenable_q <= byteenable_i;
          memory_read_q <= 1;
          memory_write_q <= 0;
        end
        WRITE: begin
          memory_address_q <= address_i;
          memory_writedata_q <= writedata_i;
          memory_byteenable_q <= byteenable_i;
          memory_read_q <= 0;
          memory_write_q <= 1;
        end
        default: begin
          memory_address_q <= 0;
          memory_writedata_q <= 0;
          memory_byteenable_q <= 0;
          memory_read_q <= 0;
          memory_write_q <= 0;
        end
      endcase
    end
  end

  // Update next state machine state.
  always_comb begin
    case (current_state)
      IDLE: begin
        if (abort_i) begin
          next_state = IDLE;
        end else if (write_i) begin
          next_state = WRITE;
        end else if (read_i) begin
          if (cache_row_valid && cache_row_tag == address_tag) begin
            // Tag matches the row, and the row is valid; therefore, we have a
            // cache hit.
            next_state = DONE;
          end else begin
            next_state = MISS;
          end
        end else begin
          next_state = IDLE;
        end
      end
      DONE: begin
        // TODO: we can improve the performance of this by applying the same
        // logic as in the IDLE state above, however it will require a few
        // changes to the module where we check for transitions from IDLE to
        // another mode.
        next_state = IDLE;
      end
      MISS: begin
        if (memory_operation_stb_i) begin
          // Data from memory will be valid in the next cycle.
          next_state = DONE;
        end else if (abort_i) begin
          next_state = ABORT;
        end else begin
          // Stay in the same state.
          next_state = MISS;
        end
      end
      ABORT: begin
        if (memory_operation_stb_i) begin
          next_state = DONE;
        end
      end
      WRITE: begin
        if (memory_operation_stb_i) begin
          // Value will be committed to memory in the next cycle.
          next_state = DONE;
        end else if (abort_i) begin
          next_state = ABORT;
        end else begin
          // Stay in the same state.
          next_state = WRITE;
        end
      end
    endcase
  end

  // Update state machine state.
  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end

  // Output read-data at end of a tx.
  always_ff @(posedge clk_i) begin
    if (rst_i || abort_i) begin
      address_q  <= 0;
      readdata_q <= 0;
    end else if (current_state != next_state) begin
      case (next_state)
        DONE: begin
          if (current_state == IDLE) begin
            // Cache hit (special case)
            address_q <= address_i;
          end else if (current_state == ABORT) begin
            address_q <= 0;
          end else begin
            address_q <= memory_address_q;
          end

          if (current_state == IDLE) begin
            // Idle -> Done implies cache hit
            readdata_q <= cache_row_data;
          end else if (current_state == ABORT) begin
            readdata_q <= 0;
          end else if (current_state == MISS) begin
            // Write back to cache.
            cache_rows[cache_row_number].tag <= address_tag;
            cache_rows[cache_row_number].data <= memory_readdata_i;
            cache_rows[cache_row_number].valid <= 1;
            // Output value from memory.
            readdata_q <= memory_readdata_i;
          end else if (current_state == WRITE) begin
            // TODO: improve check to remove magic number (so that byte-enable
            // width can change without code changing).
            if (memory_byteenable_q == 4'b1111) begin
              // TODO: improve this by allowing SW/SB to write update cache
              cache_rows[cache_row_number].tag   <= address_tag;
              cache_rows[cache_row_number].data  <= memory_writedata_q;
              cache_rows[cache_row_number].valid <= 1;
            end else begin
              // TODO: improve this by allowing SW/SB to write update cache
              cache_rows[cache_row_number].valid <= 0;
            end
          end
        end
        IDLE: begin
          // Persist data for another clock cycle.
        end
        default: begin
          // Reset on state transition
          address_q  <= 0;
          readdata_q <= 0;
        end
      endcase
    end
  end

endmodule
