`include "system_defines.svh"

module mod_alu (
    input logic [`XLEN-1:0] pc_i,
    input logic [`XLEN-1:0] alu_operand_1_i,
    input logic [`XLEN-1:0] alu_operand_2_i,

    input logic [`XLEN-1:0] immediate_i,
    input logic [`OPCODE_WIDTH-1:0] opcode_i,
    input logic [`FUNCT3_WIDTH-1:0] funct3_i,
    input logic [`FUNCT7_WIDTH-1:0] funct7_i,

    output logic [`XLEN-1:0] target_address_o,
    output logic b_cond_met_o,
    output logic [`XLEN-1:0] alu_result_o
);
  // ============ Defination ================
  logic [`XLEN-1:0] pc_plus_immediate;
  logic [`XLEN-1:0] next_pc_i;
  logic [`XLEN-1:0] effective_addr;
  logic [`XLEN-1:0] jump_register_addr;
  logic [4:0] immediate_shift_amount;
  logic [4:0] register_shift_amount;

  // ============ ALU Data Prep ================

  assign next_pc_i = pc_i + 4;

  assign pc_plus_immediate = pc_i + immediate_i;

  assign effective_addr = alu_operand_1_i + immediate_i;

  assign jump_register_addr = {effective_addr[31:1], 1'b0};

  assign immediate_shift_amount = immediate_i[4:0];

  assign register_shift_amount = alu_operand_2_i[4:0];

  // Instructions that affect the alu_result_o.
  always_comb begin
    case (opcode_i)
      `OP_LUI: alu_result_o = immediate_i;
      `OP_AUIPC: alu_result_o = pc_plus_immediate;
      `OP_JAL: alu_result_o = next_pc_i;
      `OP_JALR: alu_result_o = next_pc_i;
      //BRANCH does not influence alu_result_o.
      `OP_LOAD, `OP_STORE: alu_result_o = effective_addr;
      `OP_IMM: begin
        case (funct3_i)
          `FUNCT3_ADDI: alu_result_o = alu_operand_1_i + immediate_i;
          `FUNCT3_SLTI:
          alu_result_o = ($signed(alu_operand_1_i) < $signed(immediate_i)) ? 32'b1 : 32'b0;
          `FUNCT3_SLTIU: alu_result_o = (alu_operand_1_i < immediate_i) ? 32'b1 : 32'b0;
          `FUNCT3_XORI: alu_result_o = alu_operand_1_i ^ immediate_i;
          `FUNCT3_ORI: alu_result_o = alu_operand_1_i | immediate_i;
          `FUNCT3_ANDI: alu_result_o = alu_operand_1_i & immediate_i;
          `FUNCT3_SLLI: alu_result_o = alu_operand_1_i << immediate_shift_amount;
          `FUNCT3_SRLI_SRAI: begin
            case (funct7_i)
              `FUNCT7_SRLI: alu_result_o = alu_operand_1_i >> immediate_shift_amount;
              `FUNCT7_SRAI: alu_result_o = $signed(alu_operand_1_i) >>> immediate_shift_amount;
              default: alu_result_o = 32'b0;
            endcase
          end
          default: alu_result_o = 32'b0;
        endcase
      end
      `OP_OP: begin
        case (funct3_i)
          `FUNCT3_ADD_SUB: begin
            case (funct7_i)
              `FUNCT7_ADD: alu_result_o = alu_operand_1_i + alu_operand_2_i;
              `FUNCT7_SUB: alu_result_o = alu_operand_1_i - alu_operand_2_i;
              default: alu_result_o = 32'b0;
            endcase
          end
          `FUNCT3_SLL: alu_result_o = alu_operand_1_i << register_shift_amount;
          `FUNCT3_SLT:
          alu_result_o = ($signed(alu_operand_1_i) < $signed(alu_operand_2_i)) ? 32'b1 : 32'b0;
          `FUNCT3_SLTU: alu_result_o = (alu_operand_1_i < alu_operand_2_i) ? 32'b1 : 32'b0;
          `FUNCT3_XOR: alu_result_o = alu_operand_1_i ^ alu_operand_2_i;
          `FUNCT3_SRL_SRA: begin
            case (funct7_i)
              `FUNCT7_SRL: alu_result_o = alu_operand_1_i >> register_shift_amount;
              `FUNCT7_SRA: alu_result_o = $signed(alu_operand_1_i) >>> register_shift_amount;
              default: alu_result_o = 32'b0;
            endcase
          end
          `FUNCT3_OR: alu_result_o = alu_operand_1_i | alu_operand_2_i;
          `FUNCT3_AND: alu_result_o = alu_operand_1_i & alu_operand_2_i;
          default: alu_result_o = 32'b0;
        endcase
      end
      default: alu_result_o = 32'b0;

    endcase
  end

  // Instructions that affect the target_address_o.
  always_comb begin
    case (opcode_i)
      `OP_JAL: target_address_o = pc_plus_immediate;
      `OP_JALR: target_address_o = jump_register_addr;
      `OP_BRANCH: target_address_o = pc_plus_immediate;
      default: target_address_o = 32'b0;
    endcase
  end

  // Instructions that affect the b_cond_met_o.
  // Only J/B instructions assert b_cond_met_o.
  always_comb begin
    case (opcode_i)
      `OP_JAL, `OP_JALR: b_cond_met_o = 1'b1;
      `OP_BRANCH: begin
        case (funct3_i)
          `FUNCT3_BEQ: b_cond_met_o = (alu_operand_1_i == alu_operand_2_i) ? 1'b1 : 1'b0;
          `FUNCT3_BNE: b_cond_met_o = (alu_operand_1_i != alu_operand_2_i) ? 1'b1 : 1'b0;
          `FUNCT3_BLT:
          b_cond_met_o = ($signed(alu_operand_1_i) < $signed(alu_operand_2_i)) ? 1'b1 : 1'b0;
          `FUNCT3_BGE:
          b_cond_met_o = ($signed(alu_operand_1_i) >= $signed(alu_operand_2_i)) ? 1'b1 : 1'b0;
          `FUNCT3_BLTU: b_cond_met_o = (alu_operand_1_i < alu_operand_2_i) ? 1'b1 : 1'b0;
          `FUNCT3_BGEU: b_cond_met_o = (alu_operand_1_i >= alu_operand_2_i) ? 1'b1 : 1'b0;
          default: b_cond_met_o = 1'b0;
        endcase
      end
      default: b_cond_met_o = 1'b0;
    endcase
  end

endmodule
