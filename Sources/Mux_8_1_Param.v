`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes the desing RTL model for a 8 input 1 output Multiplexor
//   with parametric data length.
// Date: March 6, 2023
//////////////////////////////////////////////////////////////////////////////////
module Mux_8_1_Param #(	
	parameter	DATA_LENGTH = 8
	)(
	input		[DATA_LENGTH-1:0] a, b, c, d, e, f, g, h,
	input		[2:0]sel,
	output	reg [DATA_LENGTH-1:0] out
);


always @ (a, b, c, d, e, f, g, h, sel) begin
	
	case(sel)
		3'b000: out = a;
		3'b001: out = b;
		3'b010: out = c;
		3'b011: out = d;
		3'b100: out = e;
		3'b101: out = f;
		3'b110: out = g;
		3'b111: out = h;
		
		default: out = {DATA_LENGTH{1'b0}};
	
	endcase
	
end

endmodule