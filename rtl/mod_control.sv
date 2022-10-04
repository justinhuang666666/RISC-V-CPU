`include "system_defines.svh"

module mod_control (
    input logic [`OPCODE_WIDTH-1:0] opcode_i,
    output logic reg_write_en_o,
    output logic mem_to_reg_o,
    output logic mem_write_en_o,
    output logic mem_read_en_o,
    output logic alu_op2_src_o,
    output logic b_instr_o,
    output logic j_instr_o
);


  /*
    Explanation for control signals: 
    > reg_write_en_o : Enables the register file to write data in the WB stage. Connected
    to the write_enable port of the register file. It should be high for instructions that
    store any data into the registers (IMM, OP, AUIPC, LUI, JAL, JALR, LOAD). 
    > mem_to_reg_o : Signals the multiplexer in the WB stage whether the data written into 
    the register originates from memory or the ALU. Connected to the select port of the 
    multiplexer in the WB stage. It should be high for instructions that store memory data 
    into the register file (LOAD). 
    > mem_write_en_o : Enables the data memory to write data in the MEM stage. Connected to 
    the write_enable port of the data memory. It should be high for instructions that store 
    data into the data memory (STORE). 
    > mem_read_en_o : Enables the CPU to read data from the data memory. Connected to the
    read_enable port of the data memory. It should be high for instructions that load data 
    into the CPU (LOAD). 
    > alu_op2_src_o : Used in the ID stage to select the address of rt passed into the EX 
    stage for forwarding. Connected to the select port of a multiplexer for choosing the 
    address for rt. It should be high for instructions using the immediate field of the 
    instruction (IMM, AUIPC, LUI, JAL, JALR, LOAD, STORE). It prevents the forwarding logic 
    to forward data when the ALU is operating on an immediate type operand (the case when 
    the bits in the 'rt' bit field is identical to 'rd' in MEM or WB). 
    NOTE: This signal is originally used to select the ALU op2 DATA instead of the 
    ADDRESS but since the immediate field in our CPU is directly inputted into the ALU, there 
    is no need. This design choice can be reverted in the future. 
    > b_instr_o : Used to signal whether the current processed instruction is a BRANCH type
    instruction. ANDed with the branch_condition_met output of the ALU to signal the pc to 
    branch to the calculated effective address and flush corresponding pipeline stages. It 
    should be highh during branch instructions. 
    > j_instr_o : Used to signal whether the current processed instruction is a JUMP type 
    instruction. Signals the pc to jump to the calculated effective address and flush 
    corresponding pipeline stages. It should be highh during jump instructions. 
  */

  logic default_reg_write_en_o;
  logic default_mem_to_reg_o;
  logic default_mem_write_en_o;
  logic default_mem_read_en_o;
  logic default_alu_op2_src_o;
  logic default_b_instr_o;
  logic default_j_instr_o;

  // Define default values for control signals and change only when needed 
  assign default_reg_write_en_o = 1'b0;
  assign default_mem_to_reg_o   = 1'b0;
  assign default_mem_write_en_o = 1'b0;
  assign default_mem_read_en_o  = 1'b0;
  assign default_alu_op2_src_o  = 1'b0;
  assign default_b_instr_o      = 1'b0;
  assign default_j_instr_o      = 1'b0;

  always_comb begin
    // Initialize the control variables with the set-defaults 
    // Note: this implementation has caused unknonwn feedback errors, solution: add tmp variables 
    reg_write_en_o = default_reg_write_en_o;
    mem_to_reg_o   = default_mem_to_reg_o;
    mem_write_en_o = default_mem_write_en_o;
    mem_read_en_o  = default_mem_read_en_o;
    alu_op2_src_o  = default_alu_op2_src_o;
    b_instr_o      = default_b_instr_o;
    j_instr_o      = default_j_instr_o;

    unique case (opcode_i)
      `OP_AUIPC, `OP_LUI: begin
        reg_write_en_o = 1'b1;
        alu_op2_src_o  = 1'b1;
      end
      `OP_IMM: begin
        reg_write_en_o = 1'b1;
        alu_op2_src_o  = 1'b1;
      end
      `OP_OP: begin
        reg_write_en_o = 1'b1;
      end
      `OP_LOAD: begin
        reg_write_en_o = 1'b1;
        mem_to_reg_o   = 1'b1;
        mem_read_en_o  = 1'b1;
        alu_op2_src_o  = 1'b1;
      end
      `OP_STORE: begin
        mem_write_en_o = 1'b1;
        alu_op2_src_o  = 1'b1;
      end
      `OP_JAL, `OP_JALR: begin
        reg_write_en_o = 1'b1;
        alu_op2_src_o  = 1'b1;
        j_instr_o      = 1'b1;
      end
      `OP_BRANCH: begin
        b_instr_o = 1'b1;
      end
      // TODO: Have not implemented OP_MISC_MEM, OP_CSR
      default: begin
        // Debugging code 
        $display("Control block: do not recognize opcode/ unsupported instruction");
      end
    endcase

  end

endmodule
