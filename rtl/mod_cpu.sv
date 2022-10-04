`include "system_defines.svh"

module mod_cpu (
    input logic clk_i,
    input logic rst_i,
    output logic [31:0] register_a0,

    /* Wishbone B4 classic master interface */
    output logic [31:0] wb_adr_o,
    input logic [31:0] wb_dat_i,
    output logic [31:0] wb_dat_o,
    output logic wb_we_o,
    output logic [3:0] wb_sel_o,
    output logic wb_stb_o,
    input logic wb_ack_i,
    output logic wb_cyc_o
);


  logic read;

  logic waitrequest;
  assign waitrequest = !wb_ack_i;

  assign wb_stb_o = read || wb_we_o;
  assign wb_cyc_o = read || wb_we_o;

  logic pc_stall, if2id_stall, id2ex_stall, ex2mem_stall, mem2wb_stall;
  logic pc_stall_hazard, if2id_stall_hazard;
  logic if2id_flush_hazard, id2ex_flush_hazard;
  logic if2id_flush, id2ex_flush, ex2mem_flush, mem2wb_flush;
  // Add coresponding flush signals if needed 
  assign if2id_flush  = if2id_flush_hazard;
  assign id2ex_flush  = id2ex_flush_hazard;
  assign ex2mem_flush = 0;
  assign mem2wb_flush = 0;

  // PC and branch registers
  logic [`XLEN-1:0] pc, id_pc_in;
  logic [`XLEN-1:0] ex_target_address;
  logic ex_branch_taken;
  mod_pc u_mod_pc (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .stall_i(pc_stall || pc_stall_hazard),
      .pc_i(ex_target_address),
      .pc_stb_i(ex_branch_taken),
      .pc_o(pc)
  );

  logic halt;
  logic [`XLEN-1:0] pc_1, pc_2;
  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      pc_1 <= 32'hFFFFFFFF;
      pc_2 <= 32'hFFFFFFFF;
    end else begin
      pc_2 <= pc_1;
      pc_1 <= pc;
    end
  end

  assign halt = (pc == 0 && pc_1 == 0 && pc_2 == 0) ? 1 : 0;

  always_ff @(posedge clk_i) begin
    if (halt && !rst_i) begin
      $finish();
    end
  end

  logic is_instruction_read;
  assign is_instruction_read = !ex_branch_taken && (!pc_stall || pc == `PC_RESET_ADDR);

  // Used for load/store operations.
  logic [`XLEN-1:0] mem_alu_out, mem_reg_2, mem_instr_o;
  logic mem_mem_write_en, mem_mem_read_en;

  // Registers for data to/from cache
  /* verilator lint_off UNUSED */
  logic instruction_cache_stb, instruction_cache_busy, data_cache_stb, data_cache_busy;
  /* verilator lint_on UNUSED */

  logic is_data_load_operation, is_data_store_operation;
  assign is_data_load_operation  = mem_mem_read_en;
  assign is_data_store_operation = mem_mem_write_en;

  logic [`XLEN-1:0]
      instruction_cache_readdata,
      instruction_cache_readdata_address,
      data_cache_readdata,
      data_cache_writedata,
      data_cache_address,
      id_instruction_in;

  // Registers for data to/from main memory.
  logic [`XLEN-1:0]
      mem_ctrl_instruction_address,
      mem_ctrl_instruction_readdata,
      c2m_loadstore_address,
      m2c_loadstore_readdata,
      c2m_loadstore_writedata;
  logic
      mem_ctrl_instruction_address_stb,
      mem_ctrl_instruction_readdata_stb,
      c2m_loadstore_read,
      c2m_loadstore_write,
      m2c_loadstore_stb;
  logic [`BYTEENABLE_WIDTH-1:0] c2m_loadstore_byteenable, data_cache_byteenable;

  mod_mem_ctrl u_mem_ctrl (
      .clk_i(clk_i),
      .rst_i(rst_i),

      .instruction_address_i(mem_ctrl_instruction_address),
      .instruction_address_stb_i(mem_ctrl_instruction_address_stb),
      .instruction_readdata_o(mem_ctrl_instruction_readdata),
      .instruction_readdata_stb_o(mem_ctrl_instruction_readdata_stb),

      .loadstore_address_i(c2m_loadstore_address),
      .loadstore_address_stb_i(c2m_loadstore_read || c2m_loadstore_write),
      .loadstore_writedata_i(c2m_loadstore_writedata),
      .loadstore_writedata_stb_i(c2m_loadstore_write),
      .loadstore_readdata_o(m2c_loadstore_readdata),
      .loadstore_stb_o(m2c_loadstore_stb),

      .loadstore_byteenable_i(c2m_loadstore_byteenable),
      .memory_byteenable_o(wb_sel_o),

      .memory_waitrequest_i(waitrequest),
      .memory_readdata_i(wb_dat_i),
      .memory_writedata_o(wb_dat_o),
      .memory_address_o(wb_adr_o),
      .memory_write_o(wb_we_o),
      .memory_read_o(read)
  );

  mod_mem_instruction_cache u_mod_mem_instruction_cache (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .abort_i(ex_branch_taken),
      .address_i(pc & 32'hFFFFFFFC),
      .read_i(is_instruction_read),
      .readdata_o(instruction_cache_readdata),
      .address_o(instruction_cache_readdata_address),
      .stb_o(instruction_cache_stb),
      .busy_o(instruction_cache_busy),
      .memory_readdata_i(mem_ctrl_instruction_readdata),
      .memory_operation_stb_i(mem_ctrl_instruction_readdata_stb),
      .memory_address_o(mem_ctrl_instruction_address),
      .memory_read_o(mem_ctrl_instruction_address_stb)
  );

  mod_mem_data_cache u_mod_mem_data_cache (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .address_i(data_cache_address & 32'hFFFFFFFC),
      .writedata_i(data_cache_writedata),
      .read_i(is_data_load_operation),
      .write_i(is_data_store_operation),
      .byteenable_i(data_cache_byteenable),
      .readdata_o(data_cache_readdata),
      .stb_o(data_cache_stb),
      .busy_o(data_cache_busy),
      .memory_readdata_i(m2c_loadstore_readdata),
      .memory_operation_stb_i(m2c_loadstore_stb),
      .memory_address_o(c2m_loadstore_address),
      .memory_writedata_o(c2m_loadstore_writedata),
      .memory_write_o(c2m_loadstore_write),
      .memory_read_o(c2m_loadstore_read),
      .memory_byteenable_o(c2m_loadstore_byteenable)
  );

  logic if2id_stall_input;
  assign if2id_stall_input = if2id_stall || if2id_stall_hazard;

  mod_if2id u_mod_if2id (
      .clk_i(clk_i),
      .stall_i(if2id_stall_input),
      .rst_i(rst_i || if2id_flush || (if2id_stall_input && !id2ex_stall)),
      .pc_i(instruction_cache_readdata_address),
      .instr_i(instruction_cache_readdata),
      .pc_o(id_pc_in),
      .instr_o(id_instruction_in)
  );

  logic [`FUNCT7_WIDTH-1:0] id_funct7;
  logic [`REG_ADDR_WIDTH-1:0] id_rs1, id_rs2, id_rs2_muxed, id_rd;
  logic [`FUNCT3_WIDTH-1:0] id_funct3;
  logic [`OPCODE_WIDTH-1:0] id_opcode;
  logic [`XLEN-1:0] id_immediate;

  mod_instr_decode u_mod_instr_decode (
      .instr_i(id_instruction_in),
      .funct7_o(id_funct7),
      .rs1_o(id_rs1),
      .rs2_o(id_rs2),
      .funct3_o(id_funct3),
      .rd_o(id_rd),
      .opcode_o(id_opcode),
      .immediate_o(id_immediate)
  );

  logic
      id_reg_write_en,
      id_mem_to_reg,
      id_mem_write_en,
      id_mem_read_en,
      id_alu_op2_src,
      id_b_instr,
      id_j_instr;

  // id_alu_op2_src is 1 if immediate or 0 if id_rs2 should be outputted.
  assign id_rs2_muxed = id_alu_op2_src ? 0 : id_rs2;

  mod_control u_mod_control (
      .opcode_i(id_opcode),
      .reg_write_en_o(id_reg_write_en),
      .mem_to_reg_o(id_mem_to_reg),
      .mem_write_en_o(id_mem_write_en),
      .mem_read_en_o(id_mem_read_en),
      .alu_op2_src_o(id_alu_op2_src),
      .b_instr_o(id_b_instr),
      .j_instr_o(id_j_instr)
  );

  // Regfile outputs 
  logic [`XLEN-1:0] id_reg_1_data, id_reg_1_data_muxed, id_reg_2_data, id_reg_2_data_muxed;

  // Signals taken from the WB stage for the regfile.
  logic [`XLEN-1:0] wb_value;
  logic wb_reg_write_en;
  logic [`REG_ADDR_WIDTH-1:0] wb_rd;

  mod_reg_file u_mod_reg_file (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .read_addr_1_i(id_rs1),
      .read_addr_2_i(id_rs2),
      .write_enable_i(wb_reg_write_en),
      .write_addr_i(wb_rd),
      .write_val_i(wb_value),
      .reg_1_o(id_reg_1_data),
      .reg_2_o(id_reg_2_data),
      .register_a0(register_a0)
  );

  // Used to forward written data in the previous cycle, if the register
  // matches, as this is fed directly into a pipeline register.
  assign id_reg_1_data_muxed = (wb_reg_write_en && id_rs1 == wb_rd) ? wb_value : id_reg_1_data;
  assign id_reg_2_data_muxed = (wb_reg_write_en && id_rs2 == wb_rd) ? wb_value : id_reg_2_data;

  logic [`OPCODE_WIDTH-1:0] ex_opcode;
  logic [`FUNCT3_WIDTH-1:0] ex_funct3;
  logic [`FUNCT7_WIDTH-1:0] ex_funct7;
  logic ex_reg_write_en, ex_mem_to_reg, ex_mem_write_en, ex_mem_read_en, ex_b_instr, ex_j_instr;
  logic [`XLEN-1:0] ex_reg_1, ex_reg_2, ex_immediate, ex_pc, ex_instr_o;
  logic [`REG_ADDR_WIDTH-1:0] ex_rs1, ex_rs2, ex_rd;

  mod_id2ex u_mod_id2ex (
      .clk_i         (clk_i),
      .stall_i       (id2ex_stall),
      .rst_i         (rst_i || id2ex_flush || (id2ex_stall && !ex2mem_stall)),
      .opcode_i      (id_opcode),
      .funct3_i      (id_funct3),
      .funct7_i      (id_funct7),
      .reg_write_en_i(id_reg_write_en),
      .mem_to_reg_i  (id_mem_to_reg),
      .mem_write_en_i(id_mem_write_en),
      .mem_read_en_i (id_mem_read_en),
      .b_instr_i     (id_b_instr),
      .j_instr_i     (id_j_instr),
      .reg_1_i       (id_reg_1_data_muxed),
      .reg_2_i       (id_reg_2_data_muxed),
      .immediate_i   (id_immediate),
      .pc_i          (id_pc_in),
      .rs1_i         (id_rs1),
      .rs2_i         (id_rs2_muxed),
      .rd_i          (id_rd),
      .instr_i       (id_instruction_in),
      .opcode_o      (ex_opcode),
      .funct3_o      (ex_funct3),
      .funct7_o      (ex_funct7),
      .reg_write_en_o(ex_reg_write_en),
      .mem_to_reg_o  (ex_mem_to_reg),
      .mem_write_en_o(ex_mem_write_en),
      .mem_read_en_o (ex_mem_read_en),
      .b_instr_o     (ex_b_instr),
      .j_instr_o     (ex_j_instr),
      .reg_1_o       (ex_reg_1),
      .reg_2_o       (ex_reg_2),
      .immediate_o   (ex_immediate),
      .pc_o          (ex_pc),
      .rs1_o         (ex_rs1),
      .rs2_o         (ex_rs2),
      .rd_o          (ex_rd),
      .instr_o       (ex_instr_o)
  );


  // From hazard unit to decide which value, from what stage, to use.
  logic [1:0] alu_op1_sel, alu_op2_sel;

  // Computed based on hazard unit values.
  logic [`XLEN-1:0] ex_alu_operand_1, ex_alu_operand_2;

  always_comb begin
    // alu_opx_sel signal: 
    // 00 = the register value forwarded from the id stage is inputted into the alu
    // 01 = the corresponding value from the MEM stage is routed back and used as an operand 
    // 10 = the corresponding value from the WB stage is routed back and used as an operand 

    case (alu_op1_sel)
      2'b00: ex_alu_operand_1 = ex_reg_1;
      2'b01: ex_alu_operand_1 = mem_alu_out;
      2'b10: ex_alu_operand_1 = wb_value;
      default: begin
        $display("unknown alu_op1_sel");
        ex_alu_operand_1 = 0;
      end
    endcase
  end

  always_comb begin
    // alu_opx_sel signal: 
    // 00 = the register value forwarded from the id stage is inputted into the alu
    // 01 = the corresponding value from the MEM stage is routed back and used as an operand 
    // 10 = the corresponding value from the WB stage is routed back and used as an operand 
    case (alu_op2_sel)
      2'b00: ex_alu_operand_2 = ex_reg_2;
      2'b01: ex_alu_operand_2 = mem_alu_out;
      2'b10: ex_alu_operand_2 = wb_value;
      default: begin
        $display("unknown alu_op2_sel");
        ex_alu_operand_2 = 0;
      end
    endcase
  end


  logic ex_b_cond_met;
  assign ex_branch_taken = ex_j_instr || (ex_b_instr && ex_b_cond_met);

  logic [`XLEN-1:0] ex_alu_result;

  logic ex_stb_o;

  mod_ex u_mod_ex (
      .rst_i(rst_i),
      .clk_i(clk_i),

      .pc_i(ex_pc),
      .alu_operand_1_i(ex_alu_operand_1),
      .alu_operand_2_i(ex_alu_operand_2),

      .immediate_i(ex_immediate),
      .opcode_i(ex_opcode),
      .funct3_i(ex_funct3),
      .funct7_i(ex_funct7),

      .target_address_o(ex_target_address),
      .b_cond_met_o(ex_b_cond_met),
      .alu_result_o(ex_alu_result),
      .ex_stb_o(ex_stb_o)
  );

  logic mem_reg_write_en, mem_mem_to_reg;
  logic [`REG_ADDR_WIDTH-1:0] mem_rd;
  logic [`FUNCT3_WIDTH-1:0] mem_funct3;
  logic [`XLEN-1:0] mem_loaded_value;

  mod_ex2mem u_mod_ex2mem (
      .clk_i(clk_i),
      .stall_i(ex2mem_stall),
      .rst_i(rst_i || ex2mem_flush || (ex2mem_stall && !mem2wb_stall)),
      .reg_write_en_i(ex_reg_write_en),
      .mem_to_reg_i(ex_mem_to_reg),
      .mem_write_en_i(ex_mem_write_en),
      .mem_read_en_i(ex_mem_read_en),
      .funct3_i(ex_funct3),
      .rd_i(ex_rd),
      .alu_out_i(ex_alu_result),
      .reg_2_i(ex_alu_operand_2),
      .instr_i(ex_instr_o),
      .reg_write_en_o(mem_reg_write_en),
      .mem_to_reg_o(mem_mem_to_reg),
      .mem_write_en_o(mem_mem_write_en),
      .mem_read_en_o(mem_mem_read_en),
      .funct3_o(mem_funct3),
      .rd_o(mem_rd),
      .alu_out_o(mem_alu_out),
      .reg_2_o(mem_reg_2),
      .instr_o(mem_instr_o)
  );

  mod_mem_byteenable u_mod_mem_byteenable (
      .funct3_i(mem_funct3),
      .memory_address_unaligned_i(mem_alu_out),
      .memory_address_aligned_o(data_cache_address),
      .memory_byteenable_o(data_cache_byteenable)
  );

  mod_mem_load_data_aligner u_mod_mem_load_data_aligner (
      .funct3_i(mem_funct3),
      .memory_address_unaligned_i(mem_alu_out),
      .memory_readdata_i(data_cache_readdata),
      .aligned_value_o(mem_loaded_value)
  );

  mod_mem_store_data_aligner u_mod_mem_store_data_aligner (
      .funct3_i(mem_funct3),
      .memory_address_unaligned_i(mem_alu_out),
      .register_value_i(mem_reg_2),
      .aligned_value_o(data_cache_writedata)
  );

  // Outputs     
  logic             wb_mem_to_reg;
  logic [`XLEN-1:0] wb_mem_read;
  logic [`XLEN-1:0] wb_alu_out;
  /* verilator lint_off UNUSED */
  logic [`XLEN-1:0] wb_instr_o;
  assign wb_value = wb_mem_to_reg ? wb_mem_read : wb_alu_out;

  mod_mem2wb u_mod_mem2wb (
      .clk_i(clk_i),
      .stall_i(mem2wb_stall),
      .rst_i(rst_i || mem2wb_flush),
      .reg_write_en_i(mem_reg_write_en),
      .mem_to_reg_i(mem_mem_to_reg),
      .rd_i(mem_rd),
      .mem_read_i(mem_loaded_value),
      .alu_out_i(mem_alu_out),
      .instr_i(mem_instr_o),
      .reg_write_en_o(wb_reg_write_en),
      .mem_to_reg_o(wb_mem_to_reg),
      .rd_o(wb_rd),
      .mem_read_o(wb_mem_read),
      .alu_out_o(wb_alu_out),
      .instr_o(wb_instr_o)
  );

  logic if_stall_req, id_stall_req, ex_stall_req, mem_stall_req;

  assign if_stall_req  = instruction_cache_busy;
  assign id_stall_req  = 0;

  // Stall previous stages if EXEC (e.g. muldiv) not finished
  assign ex_stall_req  = !ex_stb_o;
  assign mem_stall_req = !data_cache_stb && (mem_mem_read_en || mem_mem_write_en);

  mod_stall_control u_mod_stall_control (
      .if_stall_req_i(if_stall_req || id_b_instr || id_j_instr),
      .id_stall_req_i(id_stall_req),
      .ex_stall_req_i(ex_stall_req),
      .mem_stall_req_i(mem_stall_req),
      .pc_stall_o(pc_stall),
      .if2id_stall_o(if2id_stall),
      .id2ex_stall_o(id2ex_stall),
      .ex2mem_stall_o(ex2mem_stall),
      .mem2wb_stall_o(mem2wb_stall)
  );

  mod_hazard u_mod_hazard (
      .rs1_E_i(ex_rs1),
      .rs2_E_i(ex_rs2),
      .rd_M_i(mem_rd),
      .rd_W_i(wb_rd),
      .reg_write_en_M_i(mem_reg_write_en),
      .reg_write_en_W_i(wb_reg_write_en),
      .rs1_D_i(id_rs1),
      .rs2_D_i(id_rs2),
      .mem_to_reg_E_i(ex_mem_to_reg),
      .b_taken_E_i(ex_branch_taken),
      .alu_op1_sel_o(alu_op1_sel),
      .alu_op2_sel_o(alu_op2_sel),
      .pc_stall_o(pc_stall_hazard),
      .if2id_stall_o(if2id_stall_hazard),
      .if2id_flush_o(if2id_flush_hazard),
      .id2ex_flush_o(id2ex_flush_hazard)
  );

endmodule


