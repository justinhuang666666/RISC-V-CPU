`include "system_defines.svh"

module mod_mem_instruction_cache (
    input logic clk_i,
    input logic rst_i,
    input logic abort_i,
    input logic [`XLEN-1:0] address_i,
    input logic read_i,
    output logic [`XLEN-1:0] readdata_o,
    // Signals that the instruction fetch is complete.
    output logic stb_o,
    // The address of the returned instruction.
    output logic [`XLEN-1:0] address_o,
    output logic busy_o,

    // I/O for talking to main memory.
    input logic [`XLEN-1:0] memory_readdata_i,
    // Signals that the read from memory is complete.
    input logic memory_operation_stb_i,
    output logic [`XLEN-1:0] memory_address_o,
    output logic memory_read_o
);

  // The byte-enable for instructions is always 0b1111.
  // TODO: set byte-enable to the max-value of BYTEENABLE_WIDTH instead of this
  // magic number.
  logic [`BYTEENABLE_WIDTH-1:0] byteenable;
  assign byteenable = 4'b1111;

  mod_mem_cache u_mem_cache (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .abort_i(abort_i),
      .address_i(address_i),
      .writedata_i(`XLEN'b0),
      .read_i(read_i),
      .write_i(1'b0),
      .byteenable_i(byteenable),
      .readdata_o(readdata_o),
      .address_o(address_o),
      .stb_o(stb_o),
      .busy_o(busy_o),
      .memory_readdata_i(memory_readdata_i),
      .memory_operation_stb_i(memory_operation_stb_i),
      .memory_address_o(memory_address_o),
      // verilator lint_off PINCONNECTEMPTY
      .memory_writedata_o(),
      .memory_write_o(),
      // verilator lint_on PINCONNECTEMPTY
      .memory_read_o(memory_read_o),
      // verilator lint_off PINCONNECTEMPTY
      .memory_byteenable_o()
      // verilator lint_on PINCONNECTEMPTY
  );

endmodule
