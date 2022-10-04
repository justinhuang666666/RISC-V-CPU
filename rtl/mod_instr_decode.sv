`include "system_defines.svh"

module mod_instr_decode (
    input  logic [          `XLEN-1:0] instr_i,
    output logic [  `FUNCT7_WIDTH-1:0] funct7_o,
    output logic [`REG_ADDR_WIDTH-1:0] rs2_o,
    output logic [`REG_ADDR_WIDTH-1:0] rs1_o,
    output logic [  `FUNCT3_WIDTH-1:0] funct3_o,
    output logic [`REG_ADDR_WIDTH-1:0] rd_o,
    output logic [  `OPCODE_WIDTH-1:0] opcode_o,
    output logic [          `XLEN-1:0] immediate_o
);

  logic [`XLEN-1:0] i_immediate;
  logic [`XLEN-1:0] s_immediate;
  logic [`XLEN-1:0] b_immediate;
  logic [`XLEN-1:0] u_immediate;
  logic [`XLEN-1:0] j_immediate;
  logic [`XLEN-1:0] data;

  assign data = instr_i;

  // Assign instruction bit fields 
  // Refering to The RISC-V Instruction Set Manual 2.2 page 12 
  // Figure 2.3: RISC-V base instruction formats showing immediate variants.
  assign funct7_o = data[31:25];
  assign funct3_o = data[14:12];
  assign rs1_o = data[19:15];
  assign rs2_o = data[24:20];
  assign rd_o = data[11:7];
  assign opcode_o = data[6:0];

  // Assign immediate bit fields 
  // Refering to The RISC-V Instruction Set Manual 2.2 page 12 
  // Figure 2.4  Types of immediate produced by RISC-V instructions.
  assign i_immediate = {{20{data[31]}}, data[31:20]};
  assign s_immediate = {{20{data[31]}}, data[31:25], data[11:7]};
  assign b_immediate = {{20{data[31]}}, data[7], data[30:25], data[11:8], 1'b0};
  assign u_immediate = {data[31:12], 12'b0};
  assign j_immediate = {{12{data[31]}}, data[19:12], data[20], data[30:21], 1'b0};

  // Immediate output dependent on instruction type 
  always_comb begin

    // Type of instruction determined by opcode 
    unique case (opcode_o)
      `OP_IMM, `OP_LOAD, `OP_JALR: begin
        immediate_o = i_immediate;
      end
      `OP_STORE: begin
        immediate_o = s_immediate;
      end
      `OP_BRANCH: begin
        immediate_o = b_immediate;
      end
      `OP_LUI, `OP_AUIPC: begin
        immediate_o = u_immediate;
      end
      `OP_JAL: begin
        immediate_o = j_immediate;
      end
      default: begin
        immediate_o = `XLEN'b0;
      end
    endcase

  end

endmodule
