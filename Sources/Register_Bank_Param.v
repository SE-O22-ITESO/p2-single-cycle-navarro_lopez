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
//localparam SP_RST_VAL		=	32'h7fff_effc;
localparam SP_RST_VAL		=	32'h1001_0140;
localparam GP_RST_VAL		=	32'h1000_8000;


//wire [OUTPUT_LENGTH-1:0]q_w;

genvar addr;
generate
	for(addr=0 ; addr<REGS_QTY ; addr=addr+1) begin:register
		
		
		case(addr)
			0:       Register_Param #(.LENGTH(DATA_LENGTH)) register (.d(32'd0), .rst(rst), .clk(clk), .en(en[addr]), .q(q[(addr+1)*REGS_QTY-1:addr*REGS_QTY]));
			2:       Register_Param #(.LENGTH(DATA_LENGTH), .RST_VAL(SP_RST_VAL)) register (.d(d), .rst(rst), .clk(clk), .en(en[addr]), .q(q[(addr+1)*REGS_QTY-1:addr*REGS_QTY]));
			3:       Register_Param #(.LENGTH(DATA_LENGTH), .RST_VAL(GP_RST_VAL)) register (.d(d), .rst(rst), .clk(clk), .en(en[addr]), .q(q[(addr+1)*REGS_QTY-1:addr*REGS_QTY]));
			default: Register_Param #(.LENGTH(DATA_LENGTH)) register (.d(d), .rst(rst), .clk(clk), .en(en[addr]), .q(q[(addr+1)*REGS_QTY-1:addr*REGS_QTY]));
			
		endcase
		
	end
endgenerate


endmodule