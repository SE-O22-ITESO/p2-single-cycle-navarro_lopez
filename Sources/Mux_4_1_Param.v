`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes the desing RTL model for a 4 input 1 output Multiplexor
//   with parametric data length.
// Date: November 25, 2022
//////////////////////////////////////////////////////////////////////////////////
module Mux_4_1_Param #(	
	parameter	DATA_LENGTH = 8
	)(
	input		[DATA_LENGTH-1:0] a, b, c, d,
	input		[1:0]sel,
	output	reg [DATA_LENGTH-1:0] out
);


always @ (a, b, c, d, sel) begin
	
	case(sel)
		2'b00: out = a;
		2'b01: out = b;
		2'b10: out = c;
		2'b11: out = d;
		default: out = {DATA_LENGTH{1'b0}};
	
	endcase
	
end

endmodule