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
	output reg		Select2			// Output chip select to GPIO
	
);
// ====================================================
// = Parameters            
// ====================================================
localparam ADDR_DATA_1_MAX		= 32'h FFFF_FFFF;
localparam ADDR_DATA_1_MIN		= 32'h 1001_002C;

localparam ADDR_GPIO_MAX		= 32'h 1001_002B;
localparam ADDR_GPIO_MIN		= 32'h 1001_0024;

localparam ADDR_DATA_0_MAX		= 32'h 1001_0023;
localparam ADDR_DATA_0_MIN		= 32'h 1000_0000;

localparam ADDR_PROGRAM_MAX	= 32'h 0FFF_FFFF;
localparam ADDR_PROGRAM_MIN	= 32'h 0040_0000;

localparam ADDR_RESERVED_MAX	= 32'h 003F_FFFF;
localparam ADDR_RESERVED_MIN	= 32'h 0000_0000;


always @ (*) begin

	Select0	<=  1'b0;
	Select1	<=  1'b0;
	Select2	<=  1'b0;
	AddrOut	<= 32'b0;
	DataOut	<= 32'b0;
	DataOut0	<= 32'b0;
	DataOut2 <= 32'b0;
		
	
	// Select 0: Data Memory
	if(AddrIn >= ADDR_DATA_0_MIN && AddrIn <= ADDR_DATA_0_MAX) begin
		//Select0 	= 1'b1;
		Select0	<= (MemRead | MemWrite);
		AddrOut 	<= {AddrIn - ADDR_DATA_0_MIN}>>2;
		DataOut 	<= DataIn0;
		DataOut0 <= DataIn;
		
	end
	
	else if(AddrIn >= ADDR_DATA_1_MIN && AddrIn <= ADDR_DATA_1_MAX) begin
		//Select0 = 1'b1;
		Select0	<= (MemRead | MemWrite);
		AddrOut	<= {AddrIn - ADDR_DATA_1_MIN}>>2;
		DataOut	<= DataIn0;
		DataOut0	<= DataIn;
	end
	
		// Select 2: GPIO
	else if(AddrIn >= ADDR_GPIO_MIN && AddrIn <= ADDR_GPIO_MAX) begin
		Select2	<= (MemRead | MemWrite);
		AddrOut	<= {AddrIn - ADDR_GPIO_MIN}>>2;
		DataOut	<= DataIn2;
		DataOut2	<= DataIn;
	end
	
	// Select 1: Program Memory
	else if(AddrIn >= ADDR_PROGRAM_MIN && AddrIn <= ADDR_PROGRAM_MAX) begin
		Select1 <= MemRead;
		AddrOut <= {AddrIn - ADDR_PROGRAM_MIN}>>2;
		DataOut <= DataIn1;
	end
	
	
	
	// No device shall be selected
	else if(AddrIn >= ADDR_RESERVED_MIN && AddrIn <= ADDR_RESERVED_MAX) begin
		Select0 <= 1'b0;
		Select1 <= 1'b0;
		Select2 <= 1'b0;
	end
		
	
end

endmodule