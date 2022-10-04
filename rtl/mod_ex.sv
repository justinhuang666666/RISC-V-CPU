`include "system_defines.svh"
module mod_ex (
    input logic rst_i,
    input logic clk_i,

    input logic [`XLEN-1:0] pc_i,
    input logic [`XLEN-1:0] immediate_i,
    input logic [`FUNCT3_WIDTH-1:0] funct3_i,
    input logic [`FUNCT7_WIDTH-1:0] funct7_i,
    input logic [`OPCODE_WIDTH-1:0] opcode_i,
    input logic [`XLEN-1:0] alu_operand_1_i,
    input logic [`XLEN-1:0] alu_operand_2_i,

    output logic [`XLEN-1:0] target_address_o,
    output logic b_cond_met_o,
    output logic [`XLEN-1:0] alu_result_o,
    output logic ex_stb_o

);

  logic muldiv_stb_o;
  logic [`XLEN-1:0] alu_result, muldiv_data;

  mod_alu u_alu (
      .pc_i(pc_i),
      .alu_operand_1_i(alu_operand_1_i),
      .alu_operand_2_i(alu_operand_2_i),

      .immediate_i(immediate_i),
      .opcode_i(opcode_i),
      .funct3_i(funct3_i),
      .funct7_i(funct7_i),

      .target_address_o(target_address_o),
      .b_cond_met_o(b_cond_met_o),
      .alu_result_o(alu_result)
  );

  mod_muldiv u_muldiv (
      .clk_i(clk_i),
      .rst_i(rst_i),

      .opcode_i(opcode_i),
      .funct3_i(funct3_i),
      .funct7_i(funct7_i),

      .muldiv_rs0_i(alu_operand_1_i),
      .muldiv_rs1_i(alu_operand_2_i),

      .muldiv_stb_o(muldiv_stb_o),
      .muldiv_data (muldiv_data)
  );

  always_comb begin
    if (opcode_i == `OP_OP && funct7_i == `FUNCT7_MULDIV) begin
      alu_result_o = muldiv_data;
      ex_stb_o = muldiv_stb_o;
    end else begin
      alu_result_o = alu_result;
      ex_stb_o = 1;
    end
  end

endmodule
