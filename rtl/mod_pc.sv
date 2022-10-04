`include "system_defines.svh"

module mod_pc (
    input logic clk_i,
    input logic rst_i,

    input  logic             stall_i,
    input  logic [`XLEN-1:0] pc_i,
    input  logic             pc_stb_i,
    output logic [`XLEN-1:0] pc_o
);

  logic [`XLEN-1:0] pc;
  assign pc_o = pc;

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      pc <= `PC_RESET_ADDR;
    end else if (pc == 0) begin
      // TODO: remove
      pc <= 0;
    end else if (pc_stb_i) begin
      // TODO: somehow we have to accept this value here.even if the PC is
      // stalling.
      pc <= pc_i;
    end else if (!stall_i) begin
      //if branch taken
      if (pc_stb_i) begin
        pc <= pc_i;
      end else begin
        pc <= pc + 4;
      end
    end
  end

endmodule
