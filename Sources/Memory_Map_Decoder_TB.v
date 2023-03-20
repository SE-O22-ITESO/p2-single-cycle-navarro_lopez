`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module is a test bench for a 3
// Date: November 28, 2022
//////////////////////////////////////////////////////////////////////////////////
module Memory_Map_Decoder_TB();

reg MemRead;
reg MemWrite;
reg [31:00] AddrIn;
reg [31:00] DataIn;
wire [31:00] DataOut;
wire [31:00] AddrOut;

reg [31:00] DataIn0;
wire [31:00] DataOut0;
wire Select0;

reg [31:00] DataIn1;
wire Select1;

reg [31:00] DataIn2;
wire [31:00] DataOut2;
wire Select2;

reg [31:00] DataIn3;
wire [31:00] DataOut3;
wire Select3;
wire Write3;

Memory_Map_Decoder MMD_UUT(
	// UP Interface
	.MemRead		(MemRead),		// Input data MemRead from uP Control Unit
	.MemWrite	(MemWrite),	// Input data MemWrite from uP Control Unit
	.AddrIn		(AddrIn),			// Input data Addr from uP
	.DataIn		(DataIn),			// Input data BReg from uP	
	.DataOut		(DataOut),			// Output data Instr/Data to uP
	
	// Address out
	.AddrOut		(AddrOut),	// Output address to selected device
	
	// Data Memory interface	
	.DataIn0		(DataIn0),	// Input data Q from Data memory
	.DataOut0	(DataOut0),	// Ouput data to Data memory
	.Select0		(Select0),	// Output chip select to Data memory 
	
	// Instruction Memory interface
	.DataIn1		(DataIn1),	// Input data Q from Instruction memory
	.Select1		(Select1),	// Output chip select to Instruction memory 
	
	// GPIO interface
	.DataIn2		(DataIn2),	// Input data Q from GPIO
	.DataOut2	(DataOut2),	// Ouput data to GPIO
	.Select2		(Select2),		// Output chip select to GPIO
	
	// UART interface
	.DataIn3		(DataIn3),	// Input data from UART
	.DataOut3	(DataOut3),	// Ouput data to UART
	.Select3		(Select3),		// Output chip select to UART
	.Write3		(Write3)		// Output write to UART
);

// ====================================================
// = Parameters            
// ====================================================
localparam ADDR_DATA_H_MAX		= 32'h 7FFF_FFFF;
localparam ADDR_DATA_H_MIN		= 32'h 1001_003C;

localparam ADDR_UART_MAX		= 32'h 1001_003B;
localparam ADDR_UART_MIN		= 32'h 1001_002C;

localparam ADDR_GPIO_MAX		= 32'h 1001_002B;
localparam ADDR_GPIO_MIN		= 32'h 1001_0024;

localparam ADDR_DATA_L_MAX		= 32'h 1001_0023;
localparam ADDR_DATA_L_MIN		= 32'h 1001_0000;

localparam ADDR_PROGRAM_MAX	= 32'h 0FFF_FFFF;
localparam ADDR_PROGRAM_MIN	= 32'h 0040_0000;

initial begin
	
	
	MemRead		= 1'b0;
	MemWrite	= 1'b0;
	AddrIn		= 32'h 0000_0000;
	DataIn		= 32'h 0000_0000;
	
	// Data Memory interface
	DataIn0		= 32'h deb1_0000;
	
	// Instruction Memory interface
	DataIn1		= 32'h deb1_0001;
	
	// GPIO interface
	DataIn2		= 32'h deb1_0002;
	
	// UART interface
	DataIn3		= 32'h deb1_0003;
	
	#1;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	AddrIn		= 32'h0;
	DataIn		= 32'h f1fa_0000;
	#1;
	
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	AddrIn		= ADDR_PROGRAM_MIN - 1;
	DataIn		= 32'h f1fa_0001;
	#1;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	AddrIn		= ADDR_PROGRAM_MIN;
	DataIn		= 32'h f1fa_0002;
	#1;
	
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	AddrIn		= ADDR_PROGRAM_MAX;
	DataIn		= 32'h f1fa_0003;
	#1;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	AddrIn		= ADDR_DATA_L_MIN - 1;
	DataIn		= 32'h f1fa_0004;
	#1;
	
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	AddrIn		= ADDR_DATA_L_MIN;
	DataIn		= 32'h f1fa_0005;
	#1;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	AddrIn		= ADDR_DATA_L_MAX;
	DataIn		= 32'h f1fa_0006;
	#1;
	
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	AddrIn		= ADDR_GPIO_MIN;
	DataIn		= 32'h f1fa_0007;
	#1;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	AddrIn		= ADDR_GPIO_MAX;
	DataIn		= 32'h f1fa_0008;
	#1;
	
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	AddrIn		= ADDR_UART_MIN;
	DataIn		= 32'h f1fa_0009;
	#1;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	AddrIn		= ADDR_UART_MAX;
	DataIn		= 32'h f1fa_000a;
	#1;
	
	
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	AddrIn		= ADDR_DATA_H_MIN;
	DataIn		= 32'h f1fa_000b;
	#1;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	AddrIn		= ADDR_DATA_H_MAX;
	DataIn		= 32'h f1fa_000c;
	#1;
	
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	AddrIn		= ADDR_DATA_H_MAX + 1;
	DataIn		= 32'h f1fa_000d;
	#1;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	AddrIn		= 32'h ffff_ffff;
	DataIn		= 32'h f1fa_000f;
	#1;
		
end

//always begin
//	clk		= ~clk; #2; 
//end

endmodule