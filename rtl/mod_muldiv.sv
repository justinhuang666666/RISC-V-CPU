`include "system_defines.svh"
module mod_muldiv(
    input logic                                   clk_i,
    input logic                                   rst_i,

	input logic [`OPCODE_WIDTH-1:0] 			  opcode_i,
    input logic [`FUNCT3_WIDTH-1:0] 			  funct3_i,
	input logic [`FUNCT7_WIDTH-1:0] 			  funct7_i,

	input logic [`XLEN-1:0]                       muldiv_rs0_i,
	input logic [`XLEN-1:0]                       muldiv_rs1_i,

	output logic                               	  muldiv_stb_o,
	output logic [`XLEN-1:0]                   	  muldiv_data	
	
);
	//generate muldiv trigger internally on the positive edge of incoming muldiv instruction
	logic is_muldiv_special, muldiv_trigger;
	reg [`FUNCT3_WIDTH-1:0] previous_funct3;
    reg [`XLEN-1:0] previous_muldiv_rs0;
    reg [`XLEN-1:0] previous_muldiv_rs1;
    always_comb begin
		//muldiv only
		if((opcode_i == `OP_OP)&(funct7_i == `FUNCT7_MULDIV)) begin
			case(funct3_i)
				`FUNCT3_MUL: begin
					if((previous_funct3 == `FUNCT3_MULH)&(previous_muldiv_rs0 == muldiv_rs0_i)&(previous_muldiv_rs1 == muldiv_rs1_i)) begin
						is_muldiv_special = 1;
					end
					else begin
						is_muldiv_special = 0;
					end
				end
				`FUNCT3_MULH: begin
					if((previous_funct3 == `FUNCT3_MUL)&(previous_muldiv_rs0 == muldiv_rs0_i)&(previous_muldiv_rs1 == muldiv_rs1_i)) begin
						is_muldiv_special = 1;
					end
					else begin
						is_muldiv_special = 0;
					end
				end
				`FUNCT3_DIV: begin
					if((previous_funct3 == `FUNCT3_REM)&(previous_muldiv_rs0 == muldiv_rs0_i)&(previous_muldiv_rs1 == muldiv_rs1_i)) begin
						is_muldiv_special = 1;
					end
					else begin
						is_muldiv_special = 0;
					end
				end
				`FUNCT3_DIVU: begin
					if((previous_funct3 == `FUNCT3_REMU)&(previous_muldiv_rs0 == muldiv_rs0_i)&(previous_muldiv_rs1 == muldiv_rs1_i)) begin
						is_muldiv_special = 1;
					end
					else begin
						is_muldiv_special = 0;
					end
				end
				`FUNCT3_REM: begin
					if((previous_funct3 == `FUNCT3_DIV)&(previous_muldiv_rs0 == muldiv_rs0_i)&(previous_muldiv_rs1 == muldiv_rs1_i)) begin
						is_muldiv_special = 1;
					end
					else begin
						is_muldiv_special = 0;
					end
				end
				`FUNCT3_REMU: begin
					if((previous_funct3 == `FUNCT3_DIVU)&(previous_muldiv_rs0 == muldiv_rs0_i)&(previous_muldiv_rs1 == muldiv_rs1_i)) begin
						is_muldiv_special = 1;
					end
					else begin
						is_muldiv_special = 0;
					end
				end
				default: is_muldiv_special = 0;
				endcase
		end
		else begin
			is_muldiv_special = 0;
		end
		//ensure muldiv_trigger will not be triggered if special case is detected
		muldiv_trigger = ((previous_funct3 != funct3_i)|(previous_muldiv_rs0 != muldiv_rs0_i)|(previous_muldiv_rs1 != muldiv_rs1_i))&!(is_muldiv_special);
    end

	//update previous instruction register when muldiv is triggered
	//this also ensures that muldiv_trigger is asserted for one clock cycle 
    always_ff@(posedge clk_i) begin
		//muldiv onlly
		if((opcode_i == `OP_OP)&(funct7_i == `FUNCT7_MULDIV)) begin
			//ensure register has previous instruction opcode, funct3 and funct7
			if(muldiv_trigger) begin
				previous_funct3 <= funct3_i;
				previous_muldiv_rs0 <= muldiv_rs0_i;
				previous_muldiv_rs1 <= muldiv_rs1_i;
			end
			
		end
    end

	//control logic
	logic muldiv_rs0_sign;
	logic muldiv_rs1_sign;
	logic [`XLEN-1:0] muldiv_rs0_data;
	logic [`XLEN-1:0] muldiv_rs1_data;
	logic muldiv_direct;
	logic highest_pos_compare;
	always_comb begin
		//if div else if mul
		muldiv_rs0_sign = funct3_i[2] ? (~funct3_i[0] & muldiv_rs0_i[31]) : ( (funct3_i[1:0]!=2'b11) & muldiv_rs0_i[31] );
		muldiv_rs1_sign = funct3_i[2] ? (~funct3_i[0] & muldiv_rs1_i[31]) : ( ~funct3_i[1] & muldiv_rs1_i[31] );	
		//take two's complement if negative
		muldiv_rs0_data = muldiv_rs0_sign ? ( ~muldiv_rs0_i + 1'b1 ) : muldiv_rs0_i;
		muldiv_rs1_data = muldiv_rs1_sign ? ( ~muldiv_rs1_i + 1'b1 ) : muldiv_rs1_i;		
		//for div, if div by zero or dividend is smaller than divisor
		//for mul, if multiplicand or multiplier is zero
		muldiv_direct = funct3_i[2] ? ((muldiv_rs1_data==0)|(muldiv_rs0_data<muldiv_rs1_data)) : ((muldiv_rs0_data==0)|(muldiv_rs1_data==0));
		highest_pos_compare = highest_pos(muldiv_rs0_data)<highest_pos(muldiv_rs1_data);
	end

	//multiplier
    logic [5:0] i, i_next;
    logic [31:0] mul_a, mul_b;
	logic mul_valid_out;
	logic [63:0] mul_data;
	logic [63:0] mul_data_negative;
	logic [31:0] mp;
	logic [31:0] mp_next;
	logic [63:0] mc;
	logic [63:0] mc_next;
	logic [63:0] acc;
	logic [63:0] acc_next;

    logic [3:0] mp_nibble;
    assign mp_nibble = mp[3:0];

    function [5:0] highest_pos(input [`XLEN-1:0] d);
	integer k;
	begin
	    highest_pos = 0;
	    for (k=0;k<`XLEN;k++) begin
		    if ( d[k] )
	            highest_pos = k[5:0];
		end
	end
	endfunction

    always_comb begin
        mul_a = highest_pos_compare ? muldiv_rs1_data : muldiv_rs0_data;
		mul_b = highest_pos_compare ? muldiv_rs0_data : muldiv_rs1_data;
        if (muldiv_trigger == 1) begin
			if (muldiv_direct) begin
				i_next = 8;
				acc_next = 0;
				mp_next = 0;
				mc_next = 0;
			end
			else begin
				mp_next = mul_b;
				mc_next = {32'b0,mul_a};
				acc_next = 0;
				i_next = 0;
			end
        end
        else if (i != 8) begin
            acc_next = acc + mp_nibble * mc;
            mp_next = mp >> 4;
            mc_next = mc << 4;
            if (mp_next==0) begin
                i_next=8;
            end
            else begin
                i_next = i + 1;
            end
        end
		else begin
			mp_next = mp;
			mc_next = mc;
			acc_next = acc;
			i_next = i;
		end
    end

    always_ff @(posedge clk_i) begin
		if(rst_i) begin
			mp <= 0;
			mc <= 0;
			acc <= 0;
			i <= 0;
			mul_data <= 0;
			mul_data_negative <= 0;
			mul_valid_out <= 0;
		end
		else begin
			mp <= mp_next;
			mc <= mc_next;
			acc <= acc_next;
			i <= i_next;
			if (i_next==8) begin
				mul_data <= acc_next;
				mul_data_negative <= ~acc_next+1'b1;
				mul_valid_out <= 1'b1;
			end
			else begin
				mul_data <= 0;
				mul_data_negative <= 0;
				mul_valid_out <= 0;
			end
		end
    end

	//divider
	logic [63:0] dividend_copy;
    logic [63:0] dividend_copy_next;
    logic [63:0] divisor_copy;
    logic [63:0] divisor_copy_next; 
    logic [31:0] quotient = 0;
    logic [31:0] quotient_next;
    logic [5:0] j, j_next;

	logic div_valid_out;
	logic [31:0] div_quotient;
	logic [31:0] div_quotient_negative;
	logic [31:0] div_remainder;
	logic [31:0] div_remainder_negative;

    always_comb begin
        if (muldiv_trigger == 1) begin
			if (muldiv_direct) begin
				//if divide by zero, quotient is 32'hFFFFFFFF, remainder is the dividend
				if(muldiv_rs1_data==0) begin
					j_next = 32;
					if(muldiv_rs0_sign) begin
						quotient_next = 32'b1;
					end
					else begin
						quotient_next = 32'hFFFFFFFF;
					end
					dividend_copy_next = {32'b0,muldiv_rs0_data};
					divisor_copy_next = 0;
				end
				// if dividend is smaller than divisor, quotient is zero, remainder is the dividend
				else begin
					j_next = 32;
					quotient_next = 0;
					dividend_copy_next = {32'b0,muldiv_rs0_data};
					divisor_copy_next = 0;
				end
			end
			else begin
				j_next = highest_pos(muldiv_rs1_data)+31-highest_pos(muldiv_rs0_data);
				dividend_copy_next = {32'b0, muldiv_rs0_data};
				divisor_copy_next = {1'b0, muldiv_rs1_data, 31'b0} >> j_next;
				quotient_next = quotient << j_next;
			end
        end
        else if (j != 32) begin
            quotient_next = quotient << 1;
			dividend_copy_next = dividend_copy;
            if(dividend_copy >= divisor_copy) begin
                dividend_copy_next = dividend_copy - divisor_copy;
                quotient_next[0] = 1'b1;
            end
            divisor_copy_next = divisor_copy >> 1;
            j_next = j + 1;
        end
		else begin
			j_next = j;
			dividend_copy_next = dividend_copy;
			divisor_copy_next = divisor_copy;
			quotient_next = quotient;			
		end
    end

    always_ff@(posedge clk_i) begin
		if(rst_i) begin
			dividend_copy <= 0;
			divisor_copy <= 0;
			quotient <= 0;
			j <= 0;
			div_quotient <= 0;
			div_remainder <= 0;
			div_valid_out <= 0;
		end
		else begin
			dividend_copy <= dividend_copy_next;
			divisor_copy <= divisor_copy_next;
			quotient <= quotient_next;
			j <= j_next;
			if(j_next == 32) begin
				div_quotient <= quotient_next;
				div_quotient_negative <= ~quotient_next + 1'b1;
				div_remainder <= dividend_copy_next[31:0];
				div_remainder_negative <= ~dividend_copy_next[31:0] + 1'b1;
				div_valid_out <= 1'b1;
			end
			else begin
				div_quotient <= 0;
				div_quotient_negative <= 0;
				div_remainder <= 0;
				div_remainder_negative <= 0;
				div_valid_out <= 0;
			end
		end
    end

	//muldiv result select
	always_comb begin
		if(opcode_i == `OP_MULDIV) begin
			//force the output low when muldiv_trigger is high
			if(muldiv_trigger) begin
				muldiv_data = 0;
				muldiv_stb_o = 0;
			end
			else begin
				case(funct3_i) 
					`FUNCT3_MUL: begin
						muldiv_data = (muldiv_rs0_sign ^ muldiv_rs1_sign)? mul_data_negative[31:0] : mul_data[31:0];
						muldiv_stb_o = mul_valid_out;
					end
					`FUNCT3_MULH,`FUNCT3_MULHSU,`FUNCT3_MULHU: begin
						muldiv_data = (muldiv_rs0_sign ^ muldiv_rs1_sign)? mul_data_negative[63:32] : mul_data[63:32];
						muldiv_stb_o = mul_valid_out;
					end
					`FUNCT3_DIV, `FUNCT3_DIVU: begin
						muldiv_data = (muldiv_rs0_sign ^ muldiv_rs1_sign)? div_quotient_negative : div_quotient;
						muldiv_stb_o = div_valid_out;
					end
					`FUNCT3_REM, `FUNCT3_REMU: begin
						muldiv_data = (muldiv_rs0_sign)? div_remainder_negative : div_remainder;
						muldiv_stb_o = div_valid_out;
					end
					default: begin
						muldiv_data = 0;
						muldiv_stb_o = 0;
					end
				endcase
			end
		end
		else begin
			muldiv_data = 0;
			muldiv_stb_o = 0;
		end
	end

endmodule
