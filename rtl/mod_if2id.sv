`include "system_defines.svh"

module mod_if2id (
    input logic clk_i,
    input logic stall_i,
    input logic rst_i,

    //Data Signals 
    input  logic [`XLEN-1:0] pc_i,
    input  logic [`XLEN-1:0] instr_i,
    output logic [`XLEN-1:0] pc_o,
    output logic [`XLEN-1:0] instr_o
);

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      pc_o    <= 0;
      instr_o <= 0;
    end else if (!stall_i) begin
      pc_o    <= pc_i;
      instr_o <= instr_i;
    end

  end

endmodule
