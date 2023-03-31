`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes the top desing RTL model to implement the immediate generator
//   for a 32bit Multi-cycle RISC-V microprocessor
// Date: March 5, 2023
//////////////////////////////////////////////////////////////////////////////////
module Memory_Map_Decoder(
	
	// uP Interface
	input MemRead,						// Input data MemRead from uP Control Unit
	input MemWrite,					// Input data MemWrite from uP Control Unit
	input [31:00] AddrIn,			// Input data Addr from uP
	input [31:00] DataIn,			// Input data BReg from uP	
	output reg [31:00] DataOut,	// Output data Instr/Data to uP
	// Address out
	output reg [31:00] AddrOut, 	// Output address to selected device
	// Device 0: Data Memory interface	
	input [31:00] DataIn0,			// Input data Q from Data memory
	output reg [31:00] DataOut0,	// Ouput data to Data memory
	output reg		Select0,			// Output chip select to Data memory 
	// Device 1: Instruction Memory interface
	input [31:00] DataIn1,			// Input data Q from Instruction memory
	output reg		Select1,			// Output chip select to Instruction memory 	
	// Device 2: GPIO interface
	input [31:00] DataIn2,			// Input data Q from GPIO
	output reg [31:00] DataOut2,	// Ouput data to GPIO
	output reg		Select2,			// Output chip select to GPIO
	// Device 3: UART interface
	input [31:00] DataIn3,			// Input data from GPIO
	output reg [31:00] DataOut3,	// Ouput data to GPIO
	output reg	Select3,				// Output chip select to GPIO
	output reg	Write3				// Ouptut write to GPIO
	
);
// ====================================================
// = Parameters            
// ====================================================
//localparam ADDR_DATA_H_MAX		= 32'h 7FFF_FFFF;
//localparam ADDR_DATA_H_MIN		= 32'h 1001_0040;


localparam ADDR_PROGRAM_MAX	= 32'h 0FFF_FFFF; // 64k words
localparam ADDR_PROGRAM_MIN	= 32'h 0040_0000; // Program Memory
localparam BASE_PROGRAM = 0;
localparam RANG_PROGRAM = (ADDR_PROGRAM_MAX - ADDR_PROGRAM_MIN) + 0;

localparam ADDR_DATA_L_MAX		= 32'h 1001_0023; // 8 words
localparam ADDR_DATA_L_MIN		= 32'h 1001_0000; // Data Memory
localparam BASE_DATA_L = 0;
localparam RANG_DATA_L = (ADDR_DATA_L_MAX - ADDR_DATA_L_MIN) + 0;

localparam ADDR_GPIO_MAX		= 32'h 1001_002B;	// 2 words
localparam ADDR_GPIO_MIN		= 32'h 1001_0024; // GPIO Port
localparam BASE_GPIO = 0;
localparam RANG_GPIO = (ADDR_GPIO_MAX - ADDR_GPIO_MIN) + 0;

localparam ADDR_UART_MAX		= 32'h 1001_003F; // 5 words
localparam ADDR_UART_MIN		= 32'h 1001_002C; // UART Port
localparam BASE_UART = 0;
localparam RANG_UART = (ADDR_UART_MAX - ADDR_UART_MIN) + 0; 

localparam ADDR_DATA_H_MAX		= 32'h 1001_011F; // 56 words
localparam ADDR_DATA_H_MIN		= 32'h 1001_0040; // Data memory
localparam BASE_DATA_H = RANG_DATA_L;
localparam RANG_DATA_H = (ADDR_DATA_H_MAX - ADDR_DATA_H_MIN) + RANG_DATA_L;

localparam ADDR_STACK_MAX		= 32'h 1001_0140;	// 16 words
localparam ADDR_STACK_MIN		= 32'h 1001_0100; // Data memory
localparam BASE_STACK = RANG_DATA_H;
localparam RANG_STACK = (ADDR_STACK_MAX - ADDR_STACK_MIN) + RANG_DATA_H;


always @ (*) begin

	Select0	<=  1'b0;
	Select1	<=  1'b0;
	Select2	<=  1'b0;
	Select3  <=  1'b0;
	Write3   <=  1'b0;
	AddrOut	<= 32'b0;
	DataOut	<= 32'b0;
	DataOut0	<= 32'b0;
	DataOut2 <= 32'b0;
	DataOut3 <= 32'b0;
		
	
		// Select 0: Data Memory (Stack)
	if(AddrIn >= ADDR_STACK_MIN && AddrIn <= ADDR_STACK_MAX) begin
		Select0 <= (MemRead | MemWrite);
		AddrOut <= {AddrIn - ADDR_STACK_MIN + BASE_STACK}>>2;
		//AddrOut <= {AddrIn - ADDR_STACK_MIN}>>2;
		DataOut 	<= DataIn0;
		DataOut0 <= DataIn;
	end
	
	// Select 0: Data Memory (High data memory)
	else if(AddrIn >= ADDR_DATA_H_MIN && AddrIn <= ADDR_DATA_H_MAX) begin
		//Select0 	= 1'b1;
		Select0	<= (MemRead | MemWrite);
		AddrOut 	<= {AddrIn - ADDR_DATA_H_MIN + BASE_DATA_H}>>2;
		//AddrOut 	<= {AddrIn - ADDR_DATA_H_MIN}>>2;
		DataOut 	<= DataIn0;
		DataOut0 <= DataIn;
		
	end
	// Select 0: Data Memory (Low data memory)
	else if(AddrIn >= ADDR_DATA_L_MIN && AddrIn <= ADDR_DATA_L_MAX) begin
		//Select0 	= 1'b1;
		Select0	<= (MemRead | MemWrite);
		AddrOut 	<= {AddrIn - ADDR_DATA_L_MIN + BASE_DATA_L}>>2;
		//AddrOut 	<= {AddrIn - ADDR_DATA_L_MIN}>>2;
		DataOut 	<= DataIn0;
		DataOut0 <= DataIn;
		
	end
	
	// Select 1: Program Memory
	else if(AddrIn >= ADDR_PROGRAM_MIN && AddrIn <= ADDR_PROGRAM_MAX) begin
		Select1 <= MemRead;
		AddrOut <= {AddrIn - ADDR_PROGRAM_MIN + BASE_PROGRAM}>>2;
		//AddrOut <= {AddrIn - ADDR_PROGRAM_MIN}>>2;
		DataOut <= DataIn1;
	end
	
	// Select 2: GPIO
	else if(AddrIn >= ADDR_GPIO_MIN && AddrIn <= ADDR_GPIO_MAX) begin
		Select2	<= (MemRead | MemWrite);
		AddrOut	<= {AddrIn - ADDR_GPIO_MIN + BASE_GPIO}>>2;
		//AddrOut	<= {AddrIn - ADDR_GPIO_MIN}>>2;
		DataOut	<= DataIn2;
		DataOut2	<= DataIn;
	end
	
	// Select 3: UART
	else if(AddrIn >= ADDR_UART_MIN && AddrIn <= ADDR_UART_MAX) begin
		Select3	<= (MemRead | MemWrite);
		Write3	<= MemWrite;
		AddrOut	<= {AddrIn - ADDR_UART_MIN + BASE_UART}>>2;
		//AddrOut	<= {AddrIn - ADDR_UART_MIN}>>2;
		DataOut	<= DataIn3;
		DataOut3	<= DataIn;
	end
	
	
	//	else if(AddrIn >= ADDR_DATA_1_MIN && AddrIn <= ADDR_DATA_1_MAX) begin
//		//Select0 = 1'b1;
//		Select0	<= (MemRead | MemWrite);
//		AddrOut	<= {AddrIn - ADDR_DATA_1_MIN}>>2;
//		DataOut	<= DataIn0;
//		DataOut0	<= DataIn;
//	end
	
	// No device shall be selected
//	else if(AddrIn >= ADDR_RESERVED_MIN && AddrIn <= ADDR_RESERVED_MAX) begin
//		Select0 <= 1'b0;
//		Select1 <= 1'b0;
//		Select2 <= 1'b0;
//	end
		
	
end

endmodule