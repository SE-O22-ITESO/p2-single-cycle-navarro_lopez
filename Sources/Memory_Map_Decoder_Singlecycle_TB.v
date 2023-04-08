`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module is a test bench for a 3
// Date: November 28, 2022
//////////////////////////////////////////////////////////////////////////////////
module Memory_Map_Decoder_Singlecycle_TB();

reg MemRead;
reg MemWrite;
reg [31:00] Addr0;
wire [31:00] Data0;
reg [31:00] DataIn;
reg [31:00] Addr1;
wire [31:00] Data1;

//reg [31:00] AddrIn;
//reg [31:00] DataIn;
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

reg clk;

Memory_Map_Decoder_Singlecycle MMD_UUT(
	// UP Interface
	.MemRead		(MemRead),		// Input data MemRead from uP Control Unit
	.MemWrite	(MemWrite),	// Input data MemWrite from uP Control Unit
	
	.Addr0		(Addr0),
	.Data0		(Data0),
	.DataIn		(DataIn),
	
	.Addr1		(Addr1),
	.Data1		(Data1),
	
	//.AddrIn		(AddrIn),			// Input data Addr from uP
	//.DataIn		(DataIn),			// Input data BReg from uP	
	//.DataOut		(DataOut),			// Output data Instr/Data to uP
	
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
	.Write3		(Write3),		// Output write to UART
	
	.clk		(clk)
);

// ====================================================
// = Parameters            
// ====================================================

localparam ADDR_PROGRAM_MAX	= 32'h 0FFF_FFFF; // 64k words
localparam ADDR_PROGRAM_MIN	= 32'h 0040_0000; // Program Memory

localparam ADDR_DATA_L_MAX		= 32'h 1001_0023; // 8 words
localparam ADDR_DATA_L_MIN		= 32'h 1001_0000; // Data Memory

localparam ADDR_GPIO_MAX		= 32'h 1001_002B;	// 2 words
localparam ADDR_GPIO_MIN		= 32'h 1001_0024; // GPIO Port

localparam ADDR_UART_MAX		= 32'h 1001_003F; // 5 words
localparam ADDR_UART_MIN		= 32'h 1001_002C; // UART Port

localparam ADDR_DATA_H_MAX		= 32'h 1001_011F; // 56 words
localparam ADDR_DATA_H_MIN		= 32'h 1001_0040; // Data memory

localparam ADDR_STACK_MAX		= 32'h 1001_0140;	// 16 words
localparam ADDR_STACK_MIN		= 32'h 1001_0100; // Data memory

initial begin
	
	clk			= 1'b0;
	MemRead		= 1'b0;
	MemWrite	= 1'b0;
	Addr0		= 32'h 0000_0000;
	DataIn		= 32'h 0000_0000;
	Addr1		= 32'h 0000_0000;
	
	// Data Memory interface
	DataIn0		= 32'h deb1_0000;
	
	// Instruction Memory interface
	DataIn1		= 32'h deb1_0001;
	
	// GPIO interface
	DataIn2		= 32'h deb1_0002;
	
	// UART interface
	DataIn3		= 32'h deb1_0003;
	
	#4;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	Addr0		= 32'h0;
	DataIn		= 32'h f1fa_0000;
	Addr1		= 32'h0;
	#4;
	
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	Addr0		= ADDR_PROGRAM_MIN - 1;
	DataIn		= 32'h f1fa_0001;
	Addr1		= ADDR_PROGRAM_MIN - 1;
	#4;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	Addr0		= ADDR_PROGRAM_MIN;
	DataIn		= 32'h f1fa_0002;
	Addr1		= ADDR_PROGRAM_MIN;
	#4;
	
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	Addr0		= ADDR_PROGRAM_MIN +4;
	DataIn		= 32'h f1fa_0002;
	Addr1		= ADDR_PROGRAM_MIN +4;
	#4;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	Addr0		= ADDR_PROGRAM_MIN +8;
	DataIn		= 32'h f1fa_0002;
	Addr1		= ADDR_PROGRAM_MIN +8;
	#4;
	
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	Addr0		= ADDR_PROGRAM_MAX;
	DataIn		= 32'h f1fa_0003;
	Addr1		= ADDR_PROGRAM_MAX;
	#4;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	Addr0		= ADDR_DATA_L_MIN - 1;
	DataIn		= 32'h f1fa_0004;
	Addr1		= ADDR_DATA_L_MIN - 1;
	#4;
	
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	Addr0		= ADDR_DATA_L_MIN;
	DataIn		= 32'h f1fa_0005;
	Addr1		= ADDR_DATA_L_MIN;
	#4;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	Addr0		= ADDR_DATA_L_MIN +4;
	DataIn		= 32'h f1fa_0005;
	Addr1		= ADDR_DATA_L_MIN +4;
	#4;
	
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	Addr0		= ADDR_DATA_L_MIN +8;
	DataIn		= 32'h f1fa_0005;
	Addr1		= ADDR_DATA_L_MIN +8;
	#4;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	Addr0		= ADDR_DATA_L_MAX;
	DataIn		= 32'h f1fa_0006;
	Addr1		= ADDR_DATA_L_MAX;
	#4;
	
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	Addr0		= ADDR_GPIO_MIN;
	DataIn		= 32'h f1fa_0007;
	Addr1		= ADDR_GPIO_MIN;
	#4;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	Addr0		= ADDR_GPIO_MAX;
	DataIn		= 32'h f1fa_0008;
	Addr1		= ADDR_GPIO_MAX;
	#4;
	
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	Addr0		= ADDR_UART_MIN;
	DataIn		= 32'h f1fa_0009;
	Addr1		= ADDR_UART_MIN;
	#4;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	Addr0		= ADDR_UART_MIN +4;
	DataIn		= 32'h f1fa_0009;
	Addr1		= ADDR_UART_MIN +4;
	#4;
	
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	Addr0		= ADDR_UART_MIN +8;
	DataIn		= 32'h f1fa_0009;
	Addr1		= ADDR_UART_MIN +8;
	#4;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	Addr0		= ADDR_UART_MAX;
	DataIn		= 32'h f1fa_000a;
	Addr1		= ADDR_UART_MAX;
	#4;
		
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	Addr0		= ADDR_DATA_H_MIN;
	DataIn		= 32'h f1fa_000b;
	Addr1		= ADDR_DATA_H_MIN;
	#4;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	Addr0		= ADDR_DATA_H_MIN +4;
	DataIn		= 32'h f1fa_000b;
	Addr1		= ADDR_DATA_H_MIN +4;
	#4;
	
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	Addr0		= ADDR_DATA_H_MIN +8;
	DataIn		= 32'h f1fa_000b;
	Addr1		= ADDR_DATA_H_MIN +8;
	#4;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	Addr0		= ADDR_DATA_H_MAX;
	DataIn		= 32'h f1fa_000c;
	Addr1		= ADDR_DATA_H_MAX;
	#4;
	
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	Addr0		= ADDR_DATA_H_MAX + 1;
	DataIn		= 32'h f1fa_000d;
	Addr1		= ADDR_DATA_H_MAX + 1;
	#4;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	Addr0		= ADDR_STACK_MIN;
	DataIn		= 32'h f1fa_000e;
	Addr1		= ADDR_STACK_MIN;
	#4;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	Addr0		= ADDR_STACK_MIN +4;
	DataIn		= 32'h f1fa_000e;
	Addr1		= ADDR_STACK_MIN +4;
	#4;
	
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	Addr0		= ADDR_STACK_MIN +8;
	DataIn		= 32'h f1fa_000e;
	Addr1		= ADDR_STACK_MIN +8;
	#4;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	Addr0		= ADDR_STACK_MAX;
	DataIn		= 32'h f1fa_000f;
	Addr1		= ADDR_STACK_MAX;
	#4;
	
	MemRead		= 1'b1;
	MemWrite	= 1'b0;
	Addr0		= ADDR_STACK_MAX + 1;
	DataIn		= 32'h f1fa_0010;
	Addr1		= ADDR_STACK_MAX + 1;
	#4;
	
	MemRead		= 1'b0;
	MemWrite	= 1'b1;
	Addr0		= 32'h ffff_ffff;
	DataIn		= 32'h f1fa_000f;
	Addr1		= 32'h ffff_ffff;
	#4;
		
end

always begin
	clk		= ~clk; #2; 
end

endmodule