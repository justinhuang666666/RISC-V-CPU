`include "system_defines.svh"

module mod_csr_reg_file (
    input  logic                       clk_i,
    input  logic                       rst_i,
    input  logic [`CSR_ADDR_WIDTH-1:0] read_addr_i,
    input  logic                       read_enable_i,
    input  logic [`CSR_ADDR_WIDTH-1:0] write_addr_i,
    input  logic [          `XLEN-1:0] write_val_i,
    input  logic                       write_enable_i,
    output logic [          `XLEN-1:0] csr_reg_read_o,
    output logic                       except_read_non_existent_CSR_o,
    output logic                       except_write_non_existent_CSR_o,
    output logic                       except_write_to_read_only_CSR_o
);

  // Define CSR registers
  // Machine Information Registers
  logic [`XLEN-1:0] mvendorid;  // must be readable, Read-only, can be 0 if not implemented
  logic [`XLEN-1:0] marchid;  // must be readable, Read-only, can be 0 if not implemented
  logic [`XLEN-1:0]   mimpid; // must be readable, not specified but assumed Read-only, can be 0 if not implemented
  logic [`XLEN-1:0] mhartid;  // must be readable, Read-only, at least one hart must have id=0

  // Machine Trap Setup
  logic [`XLEN-1:0] misa;  // must be readable, WARL, can be 0 if not implemented
  logic [`XLEN-1:0] mie;  // RW register
  logic [`XLEN-1:0]   mtvec; // must be implemented, WARL R/W, legal values are implementation defined

  // Machine Trap Handling
  logic [`XLEN-1:0] mepc;  // WARL RW register
  logic [`XLEN-1:0] mcause;  // RW register
  logic [`XLEN-1:0] mtval;  // RW register
  logic [`XLEN-1:0] mip;  // RW register

  // Internal logic 
  logic is_CSR_read_only;
  logic is_CSR_addr_valid;

  // Machine Info Registers **must** be readable on any implementation
  // BUT can be 0 to indicate they are not implemented
  assign mvendorid = `XLEN'b0;
  assign marchid = `XLEN'b0;
  assign mimpid = `XLEN'b0;
  assign misa = `XLEN'b0;

  // Our CPU will only ever run a single hardware thread with an ID of 0,
  // as per the ISA.
  assign mhartid = `XLEN'b0;

  // Internal signal to check if write_addr_i points to Read-only CSR
  assign is_CSR_read_only = (write_addr_i == `MVENDORID_ADDR  || write_addr_i == `MARCHID_ADDR || 
                               write_addr_i == `MIMPID_ADDR     || write_addr_i == `MHARTID_ADDR);

  // Internal signal to check if write_addr_i is valid at all
  assign is_CSR_addr_valid = is_CSR_read_only || (write_addr_i == `MISA_ADDR ||
                               write_addr_i == `MIE_ADDR     || write_addr_i == `MTVEC_ADDR ||
                               write_addr_i == `MEPC_ADDR    || write_addr_i == `MCAUSE_ADDR ||
                               write_addr_i == `MTVAL_ADDR   || write_addr_i == `MIP_ADDR);

  // Combinatorial read, with ILLEGAL INSTRUCTION exception signal generated
  // if read is attempted on non-existent CSR.
  always_comb begin
    // default empty output, and assumed legal read
    csr_reg_read_o = `XLEN'b0;
    except_read_non_existent_CSR_o = 0;

    if (read_enable_i) begin
      unique case (read_addr_i)
        `MVENDORID_ADDR: csr_reg_read_o = mvendorid;
        `MARCHID_ADDR:   csr_reg_read_o = marchid;
        `MIMPID_ADDR:    csr_reg_read_o = mimpid;
        `MHARTID_ADDR:   csr_reg_read_o = mhartid;
        `MISA_ADDR:      csr_reg_read_o = misa;
        `MIE_ADDR:       csr_reg_read_o = mie;
        `MTVEC_ADDR:     csr_reg_read_o = mtvec;
        `MEPC_ADDR:      csr_reg_read_o = mepc;
        `MCAUSE_ADDR:    csr_reg_read_o = mcause;
        `MTVAL_ADDR:     csr_reg_read_o = mtval;
        `MIP_ADDR:       csr_reg_read_o = mip;
        default:         except_read_non_existent_CSR_o = 1;
        // if read_enable_i is HIGH and read_addr_i doesn't match known
        // CSRs then access to a non-existent CSR has been attempted
      endcase
    end
  end

  // Synchronous write, with ILLEGAL INSTRUCTION exception signal generated
  // if write is attempted to READ ONLY CSR or to non-existent CSR
  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      mie <= 0;
      mtvec <= 0;
      mepc <= 0;
      mcause <= 0;
      mtval <= 0;
      mip <= 0;
    end else begin
      if (write_enable_i) begin
        // Write if address is writable
        unique case (write_addr_i)
          `MIE_ADDR:    mie <= write_val_i;
          `MTVEC_ADDR:  mtvec <= write_val_i;
          `MEPC_ADDR:   mepc <= write_val_i;
          `MCAUSE_ADDR: mcause <= write_val_i;
          `MTVAL_ADDR:  mtval <= write_val_i;
          `MIP_ADDR:    mip <= write_val_i;
          default:      ;  // do not write anything  
        endcase
      end
    end
    // Set exception signals
  end

  // Exception signals are combinatorial so that we can immediately react,
  // rather than delay full clock cycle...
  assign except_write_to_read_only_CSR_o = is_CSR_read_only && write_enable_i;
  assign except_write_non_existent_CSR_o = !is_CSR_addr_valid && write_enable_i;

endmodule
