`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module is a test bench for a 32bit Multi-cycle microprocessor (MIPs)
// Date: November 28, 2022
//////////////////////////////////////////////////////////////////////////////////
module RISC_V_Single_Cycle_TB();

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

//wire TxRx_Bridge;

RISC_V_Single_Cycle RISCV_UUT(

	// GPIO Port
	.GPIO_In	(GPIO_In),
	.GPIO_Out	(GPIO_Out),
	
	// UART Port
	.UART_Tx	(UART_Tx),
	.UART_Rx	(UART_Rx),
	//.UART_Tx	(TxRx_Bridge),
	//.UART_Rx	(TxRx_Bridge),
	.UART_Tx_Fw	(UART_Tx_Fw),
	.UART_Rx_Fw	(UART_Rx_Fw),
	
	// System
	.clk(clk),
	.rst(~rst)
	
);

initial begin
	clk		= 1'b0;
	rst		= 1'b0;
	UART_Rx = 1'b1;
	rst		= 1'b1; #1;
	rst		= 1'b0;
	GPIO_In = 10'h255;
end

always begin
	
	// Clock freq = 50 MHz, period = 20 ns
	// then 10 ns high and 10 ns low, 20 ns total
	clk		= ~clk; #10; 
	//clk		= ~clk; #2; 
	
end

always
	begin

		
		UART_Rx = 1'b1; #8_680;	// Idle state
		UART_Rx = 1'b0; #8_680;	// Start bit
		UART_Rx = 1'b0; #8_680;	// Data bit 0 (0x0c)
		UART_Rx = 1'b0; #8_680;	// Data bit 1
		UART_Rx = 1'b1; #8_680;	// Data bit 2
		UART_Rx = 1'b1; #8_680;	// Data bit 3
		UART_Rx = 1'b0; #8_680;	// Data bit 4
		UART_Rx = 1'b0; #8_680;	// Data bit 5
		UART_Rx = 1'b0; #8_680;	// Data bit 6
		UART_Rx = 1'b0; #8_680;	// Data bit 7
		UART_Rx = 1'b0; #8_680;	// Parity bit
		UART_Rx = 1'b1; #8_680;	// Stop bit
		UART_Rx = 1'b1; #8_680;	// Idle state
		
		UART_Rx = 1'b1; #8_680;	// Idle state
		UART_Rx = 1'b0; #8_680;	// Start bit
		UART_Rx = 1'b0; #8_680;	// Data bit 0 (0x08)
		UART_Rx = 1'b0; #8_680;	// Data bit 1
		UART_Rx = 1'b0; #8_680;	// Data bit 2
		UART_Rx = 1'b1; #8_680;	// Data bit 3
		UART_Rx = 1'b0; #8_680;	// Data bit 4
		UART_Rx = 1'b0; #8_680;	// Data bit 5
		UART_Rx = 1'b0; #8_680;	// Data bit 6
		UART_Rx = 1'b0; #8_680;	// Data bit 7
		UART_Rx = 1'b0; #8_680;	// Parity bit
		UART_Rx = 1'b1; #8_680;	// Stop bit
		UART_Rx = 1'b1; #8_680;	// Idle state
		
		//UART_Rx = 1'b1; #8_680;	// Idle state
		//UART_Rx = 1'b0; #8_680;	// Start bit
		//UART_Rx = 1'b0; #8_680;	// Data bit 0 (0xaa)
		//UART_Rx = 1'b1; #8_680;	// Data bit 1
		//UART_Rx = 1'b0; #8_680;	// Data bit 2
		//UART_Rx = 1'b1; #8_680;	// Data bit 3
		//UART_Rx = 1'b0; #8_680;	// Data bit 4
		//UART_Rx = 1'b1; #8_680;	// Data bit 5
		//UART_Rx = 1'b0; #8_680;	// Data bit 6
		//UART_Rx = 1'b1; #8_680;	// Data bit 7
		//UART_Rx = 1'b0; #8_680;	// Parity bit
		//UART_Rx = 1'b1; #8_680;	// Stop bit
		//UART_Rx = 1'b1; #8_680;	// Idle state
		
		//UART_Rx = 1'b1; #8_680;	// Idle state
		//UART_Rx = 1'b0; #8_680;	// Start bit
		//UART_Rx = 1'b0; #8_680;	// Data bit 0 (0x55)
		//UART_Rx = 1'b0; #8_680;	// Data bit 1
		//UART_Rx = 1'b0; #8_680;	// Data bit 2
		//UART_Rx = 1'b0; #8_680;	// Data bit 3
		//UART_Rx = 1'b1; #8_680;	// Data bit 4
		//UART_Rx = 1'b1; #8_680;	// Data bit 5
		//UART_Rx = 1'b1; #8_680;	// Data bit 6
		//UART_Rx = 1'b1; #8_680;	// Data bit 7
		//UART_Rx = 1'b1; #8_680;	// Parity bit
		//UART_Rx = 1'b1; #8_680;	// Stop bit
		//UART_Rx = 1'b1; #8_680;	// Idle state

	end	
endmodule