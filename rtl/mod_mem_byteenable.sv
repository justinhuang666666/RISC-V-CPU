`include "system_defines.svh"

module mod_mem_byteenable (
    input logic [`FUNCT3_WIDTH-1:0] funct3_i,
    input logic [`XLEN-1:0] memory_address_unaligned_i,
    output logic [`XLEN-1:0] memory_address_aligned_o,
    output logic [`BYTEENABLE_WIDTH-1:0] memory_byteenable_o
);

  logic [`XLEN-3:0] unused_byte_offset;
  logic [1:0] mem_load_store_byte_offset;
  assign {unused_byte_offset, mem_load_store_byte_offset} = memory_address_unaligned_i % 4;

  assign memory_address_aligned_o = memory_address_unaligned_i & 32'hFFFFFFFC;

  always_comb begin
    /* verilator lint_off CASEOVERLAP */
    case (funct3_i)
      `FUNCT3_LB, `FUNCT3_LBU, `FUNCT3_SB: begin
        memory_byteenable_o = 4'b0001 << mem_load_store_byte_offset;
        $display("got lb byte enable of %b %d", memory_byteenable_o, mem_load_store_byte_offset);
      end
      `FUNCT3_LH, `FUNCT3_LHU, `FUNCT3_SH: begin
        memory_byteenable_o = 4'b0011 << mem_load_store_byte_offset;
        $display("got lh byte enable of %b %d", memory_byteenable_o, mem_load_store_byte_offset);
      end
      `FUNCT3_LW, `FUNCT3_SW: begin
        memory_byteenable_o = 4'b1111;
        $display("got lw byte enable of %b %d", memory_byteenable_o, mem_load_store_byte_offset);
      end
      default: begin
        memory_byteenable_o = 0;
      end
    endcase
    /* verilator lint_on CASEOVERLAP */
  end

endmodule
