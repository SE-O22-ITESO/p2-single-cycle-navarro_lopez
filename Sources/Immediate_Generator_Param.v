`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes RTL model for Sing extender 
// Date: November 27, 2022
//////////////////////////////////////////////////////////////////////////////////
module Immediate_Generator_Param #(
	parameter INPUT_LENGTH   = 16,
	parameter OUTPUT_LENGTH  = 32
)(
	// Inputs
	input [INPUT_LENGTH-1:0] in,
	
	// Outputs
	output[OUTPUT_LENGTH-1:0] out

);

localparam DIFF_LENGTH = OUTPUT_LENGTH-INPUT_LENGTH;

assign out = { {DIFF_LENGTH{in[INPUT_LENGTH-1]}},in[INPUT_LENGTH-1:0]};

//assign out = { {16{in[15]}},in[15:0]};

endmodule