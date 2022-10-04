`include "system_defines.svh"

module mod_stall_control (
    // Connected to the ORed stall requests generated in respective stages 
    input logic if_stall_req_i,
    input logic id_stall_req_i,
    input logic ex_stall_req_i,
    input logic mem_stall_req_i,

    // Active high signals 
    // Connected to respective pipeline register (&pc)
    output logic pc_stall_o,
    output logic if2id_stall_o,
    output logic id2ex_stall_o,
    output logic ex2mem_stall_o,
    output logic mem2wb_stall_o
);

  // The Stall Controller is intended to be an exposed block visible to
  // all blocks (i.e. memory and interupt/exception handling) to stall 
  // the earlier stages of the pipeline. (ex. the ALU raises a stall 
  // request and the controller would stall the if and id stages) The 
  // outputs are connected to the stall inputs of the pipeline registers. 
  // 
  // The effect of s stall signal set to high would be to "freeze" or 
  // prevent the values of the pipeline registers from changing.  

  logic [4:0] stall_sig;

  assign pc_stall_o = stall_sig[0];
  assign if2id_stall_o = stall_sig[1];
  assign id2ex_stall_o = stall_sig[2];
  assign ex2mem_stall_o = stall_sig[3];
  assign mem2wb_stall_o = stall_sig[4];

  always_comb begin
    if (mem_stall_req_i) begin
      stall_sig = 5'b11111;
    end else if (ex_stall_req_i) begin
      stall_sig = 5'b01111;
    end else if (id_stall_req_i) begin
      stall_sig = 5'b00111;
    end else if (if_stall_req_i) begin
      stall_sig = 5'b00011;
    end else begin
      //default is not to stall any registers 
      stall_sig = 5'b00000;
    end
  end

endmodule
