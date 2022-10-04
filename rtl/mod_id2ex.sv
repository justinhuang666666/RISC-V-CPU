`include "system_defines.svh"

module mod_id2ex (
    input logic clk_i,
    input logic stall_i,
    input logic rst_i,

    // Control signals 
    input logic [`OPCODE_WIDTH-1:0] opcode_i,        // For ALU to decode instruction 
    input logic [`FUNCT3_WIDTH-1:0] funct3_i,        // For ALU to decode instruction
    input logic [`FUNCT7_WIDTH-1:0] funct7_i,        // For ALU to decode instruction
    input logic                     reg_write_en_i,  // Signals coming out of control block 
    input logic                     mem_to_reg_i,
    input logic                     mem_write_en_i,
    input logic                     mem_read_en_i,
    input logic                     b_instr_i,
    input logic                     j_instr_i,

    // Data Signals 
    input logic [          `XLEN-1:0] reg_1_i,      // Register data passthrough 
    input logic [          `XLEN-1:0] reg_2_i,      // Register data passthrough 
    input logic [          `XLEN-1:0] immediate_i,  // Input to ALU as an operand 
    input logic [          `XLEN-1:0] pc_i,         // For calculating the effective address 
    input logic [`REG_ADDR_WIDTH-1:0] rs1_i,        // For forwarding logic 
    input logic [`REG_ADDR_WIDTH-1:0] rs2_i,        // For forwarding logic 
    input logic [`REG_ADDR_WIDTH-1:0] rd_i,
    input logic [          `XLEN-1:0] instr_i,

    // Outputs
    output logic [  `OPCODE_WIDTH-1:0] opcode_o,
    output logic [  `FUNCT3_WIDTH-1:0] funct3_o,
    output logic [  `FUNCT7_WIDTH-1:0] funct7_o,
    output logic                       reg_write_en_o,
    output logic                       mem_to_reg_o,
    output logic                       mem_write_en_o,
    output logic                       mem_read_en_o,
    output logic                       b_instr_o,
    output logic                       j_instr_o,
    output logic [          `XLEN-1:0] reg_1_o,
    output logic [          `XLEN-1:0] reg_2_o,
    output logic [          `XLEN-1:0] immediate_o,
    output logic [          `XLEN-1:0] pc_o,
    output logic [`REG_ADDR_WIDTH-1:0] rs1_o,
    output logic [`REG_ADDR_WIDTH-1:0] rs2_o,
    output logic [`REG_ADDR_WIDTH-1:0] rd_o,
    output logic [          `XLEN-1:0] instr_o
);

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      opcode_o       <= 0;
      funct3_o       <= 0;
      funct7_o       <= 0;
      reg_write_en_o <= 0;
      mem_to_reg_o   <= 0;
      mem_write_en_o <= 0;
      mem_read_en_o  <= 0;
      b_instr_o      <= 0;
      j_instr_o      <= 0;
      reg_1_o        <= 0;
      reg_2_o        <= 0;
      immediate_o    <= 0;
      pc_o           <= 0;
      rs1_o          <= 0;
      rs2_o          <= 0;
      rd_o           <= 0;
      instr_o        <= 0;
    end else if (!stall_i) begin
      opcode_o       <= opcode_i;
      funct3_o       <= funct3_i;
      funct7_o       <= funct7_i;
      reg_write_en_o <= reg_write_en_i;
      mem_to_reg_o   <= mem_to_reg_i;
      mem_write_en_o <= mem_write_en_i;
      mem_read_en_o  <= mem_read_en_i;
      b_instr_o      <= b_instr_i;
      j_instr_o      <= j_instr_i;
      reg_1_o        <= reg_1_i;
      reg_2_o        <= reg_2_i;
      immediate_o    <= immediate_i;
      pc_o           <= pc_i;
      rs1_o          <= rs1_i;
      rs2_o          <= rs2_i;
      rd_o           <= rd_i;
      instr_o        <= instr_i;
    end

  end

endmodule
