`include "system_defines.svh"

module mod_mem2wb (
    input logic clk_i,
    input logic stall_i,
    input logic rst_i,

    // Control signals 
    input logic reg_write_en_i,  // Signals coming out of control block 
    input logic mem_to_reg_i,

    // Data Signals 
    input logic [`REG_ADDR_WIDTH-1:0] rd_i,
    input logic [          `XLEN-1:0] mem_read_i,
    input logic [          `XLEN-1:0] alu_out_i,
    input logic [          `XLEN-1:0] instr_i,

    // Outputs     
    output logic                       reg_write_en_o,
    output logic                       mem_to_reg_o,
    output logic [`REG_ADDR_WIDTH-1:0] rd_o,
    output logic [          `XLEN-1:0] mem_read_o,
    output logic [          `XLEN-1:0] alu_out_o,
    output logic [          `XLEN-1:0] instr_o
);

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      reg_write_en_o <= 0;
      mem_to_reg_o   <= 0;
      rd_o           <= 0;
      mem_read_o     <= 0;
      alu_out_o      <= 0;
      instr_o        <= 0;
    end else if (!stall_i) begin
      reg_write_en_o <= reg_write_en_i;
      mem_to_reg_o   <= mem_to_reg_i;
      rd_o           <= rd_i;
      mem_read_o     <= mem_read_i;
      alu_out_o      <= alu_out_i;
      instr_o        <= instr_i;
    end

  end

endmodule
