`include "system_defines.svh"

module mod_mem_load_data_aligner (
    input logic [`FUNCT3_WIDTH-1:0] funct3_i,
    input logic [`XLEN-1:0] memory_address_unaligned_i,
    input logic [`XLEN-1:0] memory_readdata_i,
    output logic [`XLEN-1:0] aligned_value_o
);

  logic [`XLEN-3:0] unused_byte_offset;
  logic [1:0] mem_load_store_byte_offset;
  assign {unused_byte_offset, mem_load_store_byte_offset} = memory_address_unaligned_i % 4;

  function automatic logic [`XLEN-1:0] signextend16to32(input [15:0] x);
    begin
      return ((x & 16'h8000) != 0) ? {16'hFFFF, x} : {16'b0, x};
    end
  endfunction

  function automatic logic [`XLEN-1:0] zeroextend16to32(input [15:0] x);
    begin
      return {16'b0, x};
    end
  endfunction

  function automatic logic [`XLEN-1:0] signextend8to32(input [7:0] x);
    begin
      return ((x & 8'h80) != 0) ? {24'hFFFFFF, x} : {24'b0, x};
    end
  endfunction

  function automatic logic [`XLEN-1:0] zeroextend8to32(input [7:0] x);
    begin
      return {24'b0, x};
    end
  endfunction

  always_comb begin
    case (funct3_i)
      `FUNCT3_LB: begin
        case (mem_load_store_byte_offset)
          0: aligned_value_o = signextend8to32(memory_readdata_i[7:0]);
          1: aligned_value_o = signextend8to32(memory_readdata_i[15:8]);
          2: aligned_value_o = signextend8to32(memory_readdata_i[23:16]);
          default: aligned_value_o = signextend8to32(memory_readdata_i[31:24]);
        endcase
      end
      `FUNCT3_LH: begin
        case (mem_load_store_byte_offset)
          0: aligned_value_o = signextend16to32(memory_readdata_i[15:0]);
          default: aligned_value_o = signextend16to32(memory_readdata_i[31:16]);
        endcase
      end
      `FUNCT3_LW: begin
        $display("read lw value %08x", memory_readdata_i);
        aligned_value_o = memory_readdata_i;
      end
      `FUNCT3_LBU: begin
        case (mem_load_store_byte_offset)
          0: aligned_value_o = zeroextend8to32(memory_readdata_i[7:0]);
          1: aligned_value_o = zeroextend8to32(memory_readdata_i[15:8]);
          2: aligned_value_o = zeroextend8to32(memory_readdata_i[23:16]);
          default: aligned_value_o = zeroextend8to32(memory_readdata_i[31:24]);
        endcase
      end
      `FUNCT3_LHU: begin
        case (mem_load_store_byte_offset)
          0: aligned_value_o = zeroextend16to32(memory_readdata_i[15:0]);
          default: aligned_value_o = zeroextend16to32(memory_readdata_i[31:16]);
        endcase
      end
      default: begin
        aligned_value_o = 0;
      end
    endcase
  end
endmodule
