`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes the desing of Register File RTL model for MIPs
// Date: November 13, 2022
//////////////////////////////////////////////////////////////////////////////////
module Register_File /*#(
	
	parameter ADDR_LENGTH	= 6,
	parameter DATA_LENGTH	= 8

) */(
	
	// Inputs
	input	[4:0] a1,
	input	[4:0] a2,
	input	[4:0] a3,
	input	[31:0] wd3,
	input we3,
	input clk,
	input rst,
	
	// Outputs
	output	[31:0] rd1,
	output	[31:0] rd2
	
);

// ====================================================
// = Parameters            
// ====================================================

// Wiring
wire [31:0] wc_w;

// Wiring
wire [1023:0]q_W;

// ====================================================
// = Register Bank            
// ====================================================

Register_Bank_Param #(
	.DATA_LENGTH	(32),
	.REGS_QTY		(32)
) register_bank(
	.d		(wd3),
	.en	(wc_w),
	.rst	(rst),
	.clk	(clk),
	.q		(q_W)
);

// ====================================================
// = Write control            
// ====================================================



Write_Control write_control (
	.we		(we3),
	.addr		(a3),
	.reg_en	(wc_w)
);

// ====================================================
// = Multiplexors            
// ====================================================



Mux_32_1_32 a1_mux (
	.in		(q_W),
	.addr		(a1),
	.out		(rd1)
);

Mux_32_1_32 a2_mux (
	.in		(q_W),
	.addr		(a2),
	.out		(rd2)
);



endmodule




















// Experimental stuff

//localparam REG_QTY 	= 2**ADDR_LENGTH;
//
//// Register array
////reg [DATA_LENGTH-1:0] reg_file[ADDR_COUNT-1:0];
//
//wire en = 1'b1;


//genvar i;
//
//generate
//	for(i=0 ; i<32 ; i=i+1) begin:register
//		
//		Register_Param #(.LENGTH (32)) r (.d(), .rst(rst), .clk(clk), .en(wc_w[i]));
//
//	end
//endgenerate

//// Port 1
//assign rd1 = reg_file[a1];
//
//// Port 2
//assign rd2 = reg_file[a2];
//
//// Port 3
//integer i;
//always @ (posedge clk, posedge rst) begin
//
//	if(rst) begin
//	
//		for (i=0;i<ADDR_COUNT;i=i+1) begin
//		
//			reg_file[a3] <= {DATA_LENGTH{1'b0}};
//		
//		end
//		
//	end
//	
//	else
//		
//		if(we3)
//			
//			reg_file[a3] <= wd3;
//	
//end