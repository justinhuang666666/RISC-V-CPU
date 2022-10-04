`include "system_defines.svh"

module test_id_alu (
    //input logic rst, 
    input logic [`XLEN-1:0] instruction,
    input logic [`XLEN-1:0] alu_oprand_1,
    input logic [`XLEN-1:0] alu_oprand_2,
    input logic [`XLEN-1:0] pc,

    output logic [  `FUNCT7_WIDTH-1:0] funct7_o,
    output logic [`REG_ADDR_WIDTH-1:0] rs2_o,
    output logic [`REG_ADDR_WIDTH-1:0] rs1_o,
    output logic [  `FUNCT3_WIDTH-1:0] funct3_o,
    output logic [`REG_ADDR_WIDTH-1:0] rd_o,
    output logic [  `OPCODE_WIDTH-1:0] opcode_o,
    output logic [          `XLEN-1:0] immediate_o,

    output logic [`XLEN-1:0] target,
    output logic [`XLEN-1:0] alu_result,
    output logic             branch
);
  logic [`FUNCT3_WIDTH-1:0] funct3_i;
  logic [`FUNCT7_WIDTH-1:0] funct7_i;
  logic [`OPCODE_WIDTH-1:0] opcode_i;
  logic [`XLEN-1:0] immediate_i;

  assign funct3_i = funct3_o;
  assign funct7_i = funct7_o;
  assign immediate_i = immediate_o;
  assign opcode_i = opcode_o;

  mod_alu u_alu (
      .pc_i(pc),
      .alu_operand_1_i(alu_oprand_1),
      .alu_operand_2_i(alu_oprand_2),
      .immediate_i(immediate_i),
      .opcode_i(opcode_i),
      .funct3_i(funct3_i),
      .funct7_i(funct7_i),

      .target_address_o(target),
      .b_cond_met_o(branch),
      .alu_result_o(alu_result)
  );

  mod_instr_decode u_instr_decode (
      .instr_i(instruction),
      .funct7_o(funct7_o),
      .rs2_o(rs2_o),
      .rs1_o(rs1_o),
      .funct3_o(funct3_o),
      .rd_o(rd_o),
      .opcode_o(opcode_o),
      .immediate_o(immediate_o)
  );
endmodule
