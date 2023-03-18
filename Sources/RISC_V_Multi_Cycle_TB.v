`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module is a test bench for a 32bit Multi-cycle microprocessor (MIPs)
// Date: November 28, 2022
//////////////////////////////////////////////////////////////////////////////////
module RISC_V_Multi_Cycle_TB();

// Inputs
reg			clk;
reg			rst;
reg [9:0] GPIO_Port_In;

// Outputs
wire [9:0] GPIO_Port_Out;

RISC_V_Multi_Cycle RISCV_UUT(
	.GPIO_Port_In(GPIO_Port_In),
	.GPIO_Port_Out(GPIO_Port_Out),
	.clk(clk),
	//.outclk_0(clk),
	.rst(~rst)


);

initial begin
	clk		= 1'b0;
	rst		= 1'b0;
	rst		= 1'b1; #1;
	rst		= 1'b0;
	GPIO_Port_In = 10'd2;
end

always begin
	
	
	clk		= ~clk; #2; 
	
end

endmodule