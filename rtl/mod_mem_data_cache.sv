`include "system_defines.svh"

module mod_mem_data_cache (
    input logic clk_i,
    input logic rst_i,
    input logic [`XLEN-1:0] address_i,
    input logic [`XLEN-1:0] writedata_i,
    input logic read_i,
    input logic write_i,
    input logic [`BYTEENABLE_WIDTH-1:0] byteenable_i,
    output logic [`XLEN-1:0] readdata_o,
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

  mod_mem_cache u_mem_cache (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .abort_i(1'b0),
      .address_i(address_i),
      .writedata_i(writedata_i),
      .read_i(read_i),
      .write_i(write_i),
      .byteenable_i(byteenable_i),
      .readdata_o(readdata_o),
      // verilator lint_off PINCONNECTEMPTY
      .address_o(),
      // verilator lint_on PINCONNECTEMPTY
      .stb_o(stb_o),
      .busy_o(busy_o),
      .memory_readdata_i(memory_readdata_i),
      .memory_operation_stb_i(memory_operation_stb_i),
      .memory_address_o(memory_address_o),
      .memory_writedata_o(memory_writedata_o),
      .memory_write_o(memory_write_o),
      .memory_read_o(memory_read_o),
      .memory_byteenable_o(memory_byteenable_o)
  );

endmodule
