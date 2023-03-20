`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes a counter with limit detection RTL model used to generate
//   one shot pulses at baud dare timing each whole bit and half bit for UART RX
// Date: October 24, 2022
//////////////////////////////////////////////////////////////////////////////////
module Bit_Rate_Pulse_NoParam /*#(parameter delay_counts = 11 )*/ (
	
	// Inputs
	input 			clk,
	input 			rst,
	input 			enable,
	input [31:0]	delay_counts,
	
	// Output
	output 			end_bit_time,
	output			end_half_time
	
);
    
//localparam delay_bits = $clog2 (delay_counts);
 //reg [delay_bits-1:0] count;

 reg [31:0] count;  

// Comparator
assign end_bit_time = (delay_counts - 1'b1 == count) ? 1'b1:1'b0;
assign end_half_time = ((delay_counts - 1'b1)/2 == count) ? 1'b1:1'b0;

// Counter
always @(posedge rst, posedge clk) begin
	if (rst)
		count <= {32{1'b0}};
	else 
		if (enable)
			if (end_bit_time)
				count <= {32{1'b0}};
			else 
				count <= count + 1'b1;
		else
			count <= count;

end

endmodule
