`include "system_defines.svh"

module mod_ex2mem (
    input logic clk_i,
    input logic stall_i,
    input logic rst_i,

    // Control signals 
    input logic reg_write_en_i,  // Signals coming out of control block 
    input logic mem_to_reg_i,
    input logic mem_write_en_i,
    input logic mem_read_en_i,
    input logic [`FUNCT3_WIDTH-1:0] funct3_i,  // For MEM byte enable operations 

    // Data Signals 
    input logic [`REG_ADDR_WIDTH-1:0] rd_i,
    input logic [          `XLEN-1:0] alu_out_i,
    input logic [          `XLEN-1:0] reg_2_i,
    input logic [          `XLEN-1:0] instr_i,

    // Outputs
    output logic                       reg_write_en_o,
    output logic                       mem_to_reg_o,
    output logic                       mem_write_en_o,
    output logic                       mem_read_en_o,
    output logic [  `FUNCT3_WIDTH-1:0] funct3_o,
    output logic [`REG_ADDR_WIDTH-1:0] rd_o,
    output logic [          `XLEN-1:0] alu_out_o,
    output logic [          `XLEN-1:0] reg_2_o,
    output logic [          `XLEN-1:0] instr_o
);

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      reg_write_en_o <= 0;
      mem_to_reg_o   <= 0;
      mem_write_en_o <= 0;
      mem_read_en_o  <= 0;
      funct3_o       <= 0;
      rd_o           <= 0;
      alu_out_o      <= 0;
      reg_2_o        <= 0;
      instr_o        <= 0;
    end else if (!stall_i) begin
      reg_write_en_o <= reg_write_en_i;
      mem_to_reg_o   <= mem_to_reg_i;
      mem_write_en_o <= mem_write_en_i;
      mem_read_en_o  <= mem_read_en_i;
      funct3_o       <= funct3_i;
      rd_o           <= rd_i;
      alu_out_o      <= alu_out_i;
      reg_2_o        <= reg_2_i;
      instr_o        <= instr_i;
    end
  end

endmodule
