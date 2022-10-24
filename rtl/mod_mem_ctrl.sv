`include "system_defines.svh"

// The memory controller sits on the top level CPU sheet and connects directly
// to the memory bus. It is used to schedule loads, stores and instruction
// fetches that arrive concurrently yet can only happen one at a time due to
// there only being one address port on the memory bus. It can either connect
// directly to the instruction fetch and MEM stages of the CPU, or to a cache
// for improved performance.
module mod_mem_ctrl (
    input logic clk_i,
    input logic rst_i,

    //instruction 
    // Expected to be held high until instruction_data_stb_o is high
    input logic [`XLEN-1:0] instruction_address_i, 
    input logic instruction_address_stb_i,
    output logic [`XLEN-1:0] instruction_readdata_o,
    output logic instruction_readdata_stb_o,

    //data load store
    // Expected to be held high until loadstore_readdata_stb_o is high
    input logic [`XLEN-1:0] loadstore_address_i,
    // HIGH for either a load or store operation: assumed to be a load if
    // loadstore_writedata_i is LOW.
    input logic loadstore_address_stb_i,
    // HIGH for a store operation.
    input logic [`XLEN-1:0] loadstore_writedata_i,
    input logic loadstore_writedata_stb_i,
    output logic [`XLEN-1:0] loadstore_readdata_o,
    output logic loadstore_stb_o,

    //byte enable
    // TODO: remove this input and put it into this module if opcode is fed in.
    input  logic [`BYTEENABLE_WIDTH-1:0] loadstore_byteenable_i,
    output logic [`BYTEENABLE_WIDTH-1:0] memory_byteenable_o,

    input logic memory_waitrequest_i,
    input logic [`XLEN-1:0] memory_readdata_i,
    output logic [`XLEN-1:0] memory_writedata_o,
    output logic [`XLEN-1:0] memory_address_o,
    output logic memory_write_o,
    output logic memory_read_o
);

  logic [`XLEN-1:0] loadstore_writedata_q;
  logic [`XLEN-1:0] instruction_readdata_q, loadstore_readdata_q;
  logic [`BYTEENABLE_WIDTH-1:0] memory_byteenable_q;
  logic [`XLEN-1:0] memory_address_q;
  logic memory_write_q, memory_read_q;

  enum {
    // IDLE means no operation is currently being performed.
    IDLE,
    // WAIT_LOAD means a data load/read is in progress.
    WAIT_LOAD,
    // WAIT_STORE means a data write is in progress.
    WAIT_STORE,
    // WAIT_IFETCH means an instruction fetch from memory is in progress.
    WAIT_IFETCH,
    // DONE_LOAD means the data load/read transaction is complete.
    DONE_LOAD,
    // DONE_STORE means the data write transaction is complete.
    DONE_STORE,
    // DONE_IFETCH means the instruction fetch transaction is complete.
    DONE_IFETCH
  }
      current_state, next_state;

  // Holds the current and previous state of waitrequest parameter.
  logic waitrequest_d;
  assign waitrequest_d = memory_waitrequest_i;

  // Update the next state of the FSM.
  always_comb begin
    case (current_state)
      IDLE: begin
        // Schedule loads and stores before instruction fetches (IF), as IF
        // happens every cycle unless stalled (we don't want to starve
        // load/stall operations).
        if (loadstore_address_stb_i && loadstore_writedata_stb_i) begin
          next_state = WAIT_STORE;
        end else if (loadstore_address_stb_i) begin
          next_state = WAIT_LOAD;
        end else if (instruction_address_stb_i) begin
          next_state = WAIT_IFETCH;
        end else begin
          next_state = current_state;
        end
      end
      WAIT_LOAD: begin
        if (waitrequest_d == 0) begin
          // If waitrequest is low in this cycle, then the tx is complete in the
          // next cycle.
          next_state = DONE_LOAD;
        end else begin
          next_state = current_state;
        end
      end
      WAIT_STORE: begin
        if (waitrequest_d == 0) begin
          // If waitrequest is low in this cycle, then the tx is complete in the
          // next cycle.
          next_state = DONE_STORE;
        end else begin
          next_state = current_state;
        end
      end
      WAIT_IFETCH: begin
        if (waitrequest_d == 0) begin
          // If waitrequest is low in this cycle, then the tx is complete in the
          // next cycle.
          next_state = DONE_IFETCH;
        end else begin
          next_state = current_state;
        end
      end
      DONE_LOAD: begin
        next_state = IDLE;
      end
      DONE_STORE: begin
        next_state = IDLE;
      end
      DONE_IFETCH: begin
        next_state = IDLE;
      end
      default: begin
        next_state = IDLE;
      end
    endcase
  end

  // On the clock edge, update the current state to be the computed next state.
  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end

  // Handle the start of a memory transaction by storing which address should be
  // read/written from/to, along with other fields required to be persisted by
  // the memory interface throughout the length of the transaction.
  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      memory_address_q <= 0;
      loadstore_writedata_q <= 0;
      memory_byteenable_q <= 0;
      memory_read_q <= 0;
      memory_write_q <= 0;
    end else if (current_state != next_state) begin//when changing state
      case (next_state)
        WAIT_LOAD: begin
          memory_address_q <= loadstore_address_i;
          memory_byteenable_q <= loadstore_byteenable_i;
          memory_read_q <= 1;
        end
        WAIT_STORE: begin
          memory_address_q <= loadstore_address_i;
          loadstore_writedata_q <= loadstore_writedata_i;
          memory_byteenable_q <= loadstore_byteenable_i;
          memory_write_q <= 1;
        end
        WAIT_IFETCH: begin
          memory_address_q <= instruction_address_i;
          memory_byteenable_q <= 4'b1111;
          memory_read_q <= 1;
        end
        default: begin
          memory_address_q <= 0;
          loadstore_writedata_q <= 0;
          memory_byteenable_q <= 0;
          memory_read_q <= 0;
          memory_write_q <= 0;
        end
      endcase
    end
  end

  // Assign the memory registers to the outputs.
  assign memory_address_o = memory_address_q;
  assign memory_writedata_o = loadstore_writedata_q;
  assign memory_byteenable_o = memory_byteenable_q;
  assign memory_read_o = memory_read_q;
  assign memory_write_o = memory_write_q;

  // Handle the end of a memory transaction by updating the readdata outputs
  // with the fetched value from memory.
  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      instruction_readdata_q <= 0;
      loadstore_readdata_q   <= 0;
    end else if (current_state != next_state) begin
      case (current_state)
        IDLE: begin
          // Persist the data for another clock cycle
        end
        DONE_LOAD: begin
          loadstore_readdata_q <= memory_readdata_i;
        end
        DONE_STORE: begin
          // No need to write to any register.
        end
        DONE_IFETCH: begin
          instruction_readdata_q <= memory_readdata_i;
        end
        default: begin
          instruction_readdata_q <= 0;
          loadstore_readdata_q   <= 0;
        end
      endcase
    end
  end

  // Use constant assignment to inform external modules when a load/store/IF
  // transaction is complete. Mux between these as we only get the data on the
  // DONE cycle, hence it is only put into the respective register on the
  // following cycle.
  assign loadstore_readdata_o = (current_state == DONE_LOAD) ? memory_readdata_i : loadstore_readdata_q;
  assign loadstore_stb_o = current_state == DONE_STORE || current_state == DONE_LOAD;

  assign instruction_readdata_o = (current_state == DONE_IFETCH) ? memory_readdata_i : instruction_readdata_q;
  assign instruction_readdata_stb_o = current_state == DONE_IFETCH;

endmodule
