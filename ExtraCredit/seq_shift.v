`include "prj_definition.v"
/*
* The gate based sequential shifter.
*/
module shift_regester(Result, Data, Shift, CLK);
	output [31:0] Result;
	input [31:0] Data;
	input [1:0] Shift;
	input CLK;
	wire nullWire;

	genvar i;
	generate
		for (i=0; i<=31; i=i+1)	
		begin : input_reg_gen_loop_
			if(i!=0 && i!=31) begin
				wire muxOut;
				mux_4x1 mux(muxOut, Result[i], Result[i+1], Result[i-1], Data[i], Shift);
				bit_regester br(Result[i], nullWire, 1'b1, muxOut, 1'b1, CLK, 1'b1);
			end else if(i==31) begin
				wire muxOut;
				mux_4x1 mux(muxOut, Result[i], 1'b0, Result[i-1], Data[i], Shift);
				bit_regester br(Result[i], nullWire, 1'b1, muxOut, 1'b1, CLK, 1'b1);
			end else begin
				wire muxOut;
				mux_4x1 mux(muxOut, Result[i], Result[i+1], 1'b0, Data[i], Shift);
				bit_regester br(Result[i], nullWire, 1'b1, muxOut, 1'b1, CLK, 1'b1);
			end
		end
	endgenerate
endmodule
/*
The control unit for the sequential multiplier
*/
module shiftControl(result, ready, operand, fullShift, leftNotRight, clk);
	output [31:0] result;
	output ready;

	input [31:0] operand;
	input clk, leftNotRight;
	input [4:0] fullShift;


	reg [4:0] countShift;

	reg [1:0] shiftDir;

	shift_regester sh(result, operand, shiftDir, clk);

	reg [5:0] bit;
	wire ready = !bit;

	initial begin
		bit=5'b00000;
		shiftDir=2'b11;
		countShift=fullShift;
	end
	always @(posedge clk)
		if(ready) begin
			bit = 6'b100000;
			countShift=fullShift;
		end else begin
			if(leftNotRight==0)
				shiftDir=2'b01;
			else
				shiftDir=2'b10;
			if(countShift>0) begin
				countShift = countShift - 1 ;
			end else begin
				shiftDir=2'b00;
			end
			bit = bit - 1;
		end
endmodule
/*
Test Bench for sequential multiplier
Runs for the number of clock cycles required to complete multiplication
*/
module a_shift_TB;
	wire [31:0] result;
	wire ready;
	reg [31:0] operand;
	reg [4:0] fullShift;
	wire clk;
	reg leftNotRight;

	CLK_GENERATOR c(clk);
	shiftControl sc(result, ready, operand, fullShift, leftNotRight, clk);
	initial begin
		operand = 32'b00100;
		leftNotRight = 1'b0;
		fullShift = 5'b00010;
		#1000; 
		$stop;
	end
endmodule