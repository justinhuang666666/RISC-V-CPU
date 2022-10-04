`include "system_defines.svh"

module mod_reg_file (
    input  logic                       clk_i,
    input  logic                       rst_i,
    input  logic                       write_enable_i,
    input  logic [`REG_ADDR_WIDTH-1:0] read_addr_1_i,
    input  logic [`REG_ADDR_WIDTH-1:0] read_addr_2_i,
    input  logic [`REG_ADDR_WIDTH-1:0] write_addr_i,
    input  logic [          `XLEN-1:0] write_val_i,
    output logic [          `XLEN-1:0] reg_1_o,
    output logic [          `XLEN-1:0] reg_2_o,
    output logic [          `XLEN-1:0] register_a0
);

  // Declare REG_FILE_SZ number of registers, each XLEN bits wide
  logic [`REG_FILE_SZ-1:0] registers[`XLEN-1:0];

  // Register x0 is hardwired to 0 as per ISA
  assign registers[0] = `XLEN'b0;

  // Reading from registers is combinatorial
  assign reg_1_o = registers[read_addr_1_i];
  assign reg_2_o = registers[read_addr_2_i];
  assign register_a0 = registers[10];

  // Writing to registers is synchronous
  always_ff @(posedge clk_i) begin
    if (rst_i) begin  // Reset registers x1-x31... (x0 is hardwired to 0 anyway)
      for (integer i = 1; i < `REG_FILE_SZ; i++) begin
        registers[i] <= `XLEN'b0;
      end
    end else if (write_enable_i && (write_addr_i != '0)) begin
      registers[write_addr_i] <= write_val_i;
    end
  end

endmodule

