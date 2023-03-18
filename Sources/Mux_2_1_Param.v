`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes the desing RTL model for a Multiplexor 32bit Multi-cycle microprocessor (MIPs)
// Date: November 25, 2022
//////////////////////////////////////////////////////////////////////////////////
module Mux_2_1_Param #(	
	parameter	DATA_LENGTH = 8
	)(
	input		[DATA_LENGTH-1:0] a, b,
	input		sel,
	output	[DATA_LENGTH-1:0] out
);

	assign out = sel ? b : a;

endmodule

//generate
//
//	case(SLCT_LENGTH)
//		2: begin
//			
//			assign out = sel ? a : b;
//			
//			end
//			
//		3: begin
//			
//			always @(*) begin
//			
//				case(sel)
//				3'd0: out
//				endcase
//			
//			end
//			
//			end
//			
//		4: begin
//			
//			end
//		
//		default: $display("Invalid SLCT_LENGTH");
//	
//	endcase
//
//endgenerate