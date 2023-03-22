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
reg	clk;
reg	rst;
reg [9:0] GPIO_In;
reg UART_Rx;
// Outputs
wire [9:0] GPIO_Out;
wire UART_Tx;
wire UART_Tx_Fw;
wire UART_Rx_Fw;

wire TxRx_Bridge;

RISC_V_Multi_Cycle RISCV_UUT(

	// GPIO Port
	.GPIO_In	(GPIO_In),
	.GPIO_Out	(GPIO_Out),
	
	// UART Port
	//.UART_Tx	(UART_Tx),
	//.UART_Rx	(UART_Rx),
	.UART_Tx	(TxRx_Bridge),
	.UART_Rx	(TxRx_Bridge),
	.UART_Tx_Fw	(UART_Tx_Fw),
	.UART_Rx_Fw	(UART_Rx_Fw),
	
	// System
	.clk(clk),
	.rst(~rst)
	
);

initial begin
	clk		= 1'b0;
	rst		= 1'b0;
	UART_Rx = 1'b0;
	rst		= 1'b1; #1;
	rst		= 1'b0;
	GPIO_In = 10'h2AA;
end

always begin
	
	// Clock freq = 50 MHz, period = 20 ns
	// then 10 ns high and 10 ns low, 20 ns total
	clk		= ~clk; #10; 
	//clk		= ~clk; #2; 
	
end

endmodule