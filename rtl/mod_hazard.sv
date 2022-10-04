`include "system_defines.svh"

module mod_hazard (
    // Inputs for forwarding 
    // TODO: double check these were renamed correctly.
    input logic [`REG_ADDR_WIDTH-1:0] rs1_E_i,
    input logic [`REG_ADDR_WIDTH-1:0] rs2_E_i,
    input logic [`REG_ADDR_WIDTH-1:0] rd_M_i,
    input logic [`REG_ADDR_WIDTH-1:0] rd_W_i,
    input logic                       reg_write_en_M_i,
    input logic                       reg_write_en_W_i,

    // Inputs for LW hazard 
    input logic [`REG_ADDR_WIDTH-1:0] rs1_D_i,
    input logic [`REG_ADDR_WIDTH-1:0] rs2_D_i,
    input logic                       mem_to_reg_E_i,

    // Inputs for BRANCH hazard 
    input logic b_taken_E_i,

    // Outputs for forwarding
    output logic [1:0] alu_op1_sel_o,
    output logic [1:0] alu_op2_sel_o,

    // Outputs for LW hazard 
    output logic pc_stall_o,
    output logic if2id_stall_o,

    // Output for BRANCH hazard 
    output logic if2id_flush_o,

    // Output for BRANCH & LW hazard
    output logic id2ex_flush_o
);

  // Signal naming convention: signal_name + _STAGE_ + i/o 
  // Example: rd_M_i is the rd signal during the MEM stage as an input 

  logic lw_hazard;
  assign pc_stall_o    = lw_hazard;
  assign if2id_stall_o = lw_hazard;
  assign id2ex_flush_o = lw_hazard || b_taken_E_i;
  assign if2id_flush_o = b_taken_E_i;

  always_comb begin

    // Forwarding logic to solve data hazard: Accessing a register in EX stage that 
    // is about to be written(in MEM/WB stage). The newest iteration of the result 
    // (i.e. ALU result from the prior instruction reaching MEM stage) has higher 
    // precedence over the older iteration (i.e. ALU result reaching WB stage)   

    // alu_opx_sel signal: 
    // 00 = the register value from the id stage is inputted into the alu
    // 01 = the corresponding value from the MEM stage is routed back and used as an operand 
    // 10 = the corresponding value from the WB stage is routed back and used as an operand 

    if (reg_write_en_M_i && rd_M_i != 0) begin
      alu_op1_sel_o = (rd_M_i == rs1_E_i) ? 2'b01 : 2'b00;
      alu_op2_sel_o = (rd_M_i == rs2_E_i) ? 2'b01 : 2'b00;
    end else if (reg_write_en_W_i && rd_W_i != 0) begin
      alu_op1_sel_o = (rd_W_i == rs1_E_i && rd_M_i != rs1_E_i) ? 2'b10 : 2'b00;
      alu_op2_sel_o = (rd_W_i == rs2_E_i && rd_M_i != rs2_E_i) ? 2'b10 : 2'b00;
    end else begin
      alu_op1_sel_o = 2'b00;
      alu_op2_sel_o = 2'b00;
    end

    // Stalls and flushes to solve data hazard: Accessing data that is being read 
    // from MEM stage in EX stage. This also relies on forwarding and uses the data from 
    // the MEM stage after stalling and flushing the corresponding registers. 
    lw_hazard = (((rs1_D_i == rs1_E_i && rs1_D_i != 0) || (rs2_D_i == rs2_E_i && rs2_E_i != 0)) && mem_to_reg_E_i) ? 1'b1 : 1'b0;

  end

endmodule
