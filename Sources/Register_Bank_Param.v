`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes a Multiplexer 32 inputs 1 output 32 bit length RTL model 
// Date: November 13, 2022
//////////////////////////////////////////////////////////////////////////////////
module Register_Bank_Param #(
	parameter DATA_LENGTH	= 32,
	parameter REGS_QTY		= 32
	//parameter ADDR_LENGTH	= 5
)
(

// Inputs
//	input [DATA_LENGTH-1:0] d,
//	input [REGS_QTY-1:0] en,
	input [31:0] d,
	input [31:0] en,
	input rst,
	input clk,
	
// Outputs
	//output [OUTPUT_LENGTH-1:0] q
	output [1023:0] q

);

//localparam REGS_QTY 			= 2**ADDR_LENGTH;

localparam ADDR_LENGTH		= $clog2(REGS_QTY);
localparam OUTPUT_LENGTH 	= REGS_QTY*DATA_LENGTH;

//wire [OUTPUT_LENGTH-1:0]q_w;

genvar addr;
generate
	for(addr=0 ; addr<REGS_QTY ; addr=addr+1) begin:register
		
		Register_Param #(.LENGTH(DATA_LENGTH)) register (.d(d), .rst(rst), .clk(clk), .en(en[addr]), .q(q[(addr+1)*REGS_QTY-1:addr*REGS_QTY]));

	end
endgenerate

endmodule