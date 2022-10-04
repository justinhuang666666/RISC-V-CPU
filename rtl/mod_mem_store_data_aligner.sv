`include "system_defines.svh"

module mod_mem_store_data_aligner (
    input logic [`FUNCT3_WIDTH-1:0] funct3_i,
    input logic [`XLEN-1:0] memory_address_unaligned_i,
    input logic [`XLEN-1:0] register_value_i,
    output logic [`XLEN-1:0] aligned_value_o
);

  logic [`XLEN-3:0] unused_byte_offset;
  logic [1:0] mem_load_store_byte_offset;
  assign {unused_byte_offset, mem_load_store_byte_offset} = memory_address_unaligned_i % 4;

  always_comb begin
    case (funct3_i)
      `FUNCT3_SB: begin

        case (mem_load_store_byte_offset)
          3: aligned_value_o = (register_value_i << 24) & 32'hFF000000;
          2: aligned_value_o = (register_value_i << 16) & 32'h00FF0000;
          1: aligned_value_o = (register_value_i << 8) & 32'h0000FF00;
          default: aligned_value_o = register_value_i & 32'h000000FF;
        endcase

        $display("got register value of %08x with offset %d - giving %08x", register_value_i,
                 mem_load_store_byte_offset, aligned_value_o);
      end
      `FUNCT3_SH: begin
        aligned_value_o = (mem_load_store_byte_offset == 0) ? (register_value_i & 32'h0000FFFF) : (register_value_i << 16);
      end
      `FUNCT3_SW: begin
        aligned_value_o = register_value_i;
      end
      default: begin
        aligned_value_o = 0;
      end
    endcase
  end

endmodule

