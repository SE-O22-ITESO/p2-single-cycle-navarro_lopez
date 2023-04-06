`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes a RTL model for Control Unit for 32-bit RISCV Singlecycle
// Date: April 3, 2023
//////////////////////////////////////////////////////////////////////////////////
module Control_Unit_Singlecycle(
	
	// Main Controller FSM
	output PCWrite,		//
	output AddrSrc, 		//
	output MemRead,		//
	output MemWrite,		//
	output [01:00] WritebackSrc,	//
	output IRWrite,		//
		
	input [06:00] Opcode,
	input [06:00] Funct7,
	input [02:00] Funct3,
	
	output PCSrc,			//
	output [3:0]ALUOp,	//
	output [1:0]ALUSrcA,	//
	output [1:0]ALUSrcB,	//
	output RegWrite,		//
	input [1:0] Comp,		//
		
	input	clk,
	input	rst
);

wire ALUControl;
// PCWrite
//or();
//and();
Main_Controller_Singlecycle Controller_Singlecycle(
	
	.PCWrite			(PCWrite),
	.AddrSrc			(AddrSrc),	
	.MemRead			(MemRead),
	.MemWrite		(MemWrite),
	.WritebackSrc	(WritebackSrc),
	.IRWrite			(IRWrite),
	
	.Opcode			(Opcode),
	.Funct7			(Funct7),
	.Funct3			(Funct3),
	
	.PCSrc			(PCSrc),
	.ALUControl		(ALUControl),
	.ALUSrcA			(ALUSrcA),
	.ALUSrcB			(ALUSrcB),
	.RegWrite		(RegWrite),
	.Comp				(Comp),
		
	.clk				(clk),
	.rst				(rst)
);

ALU_Decoder ALU_Decoder(
	//.Funct		(Funct),
	//.ALUControl	(ALUControl)
	.ALUControl	(ALUControl),
	.Opcode		(Opcode),
	.Funct7		(Funct7),
	.Funct3		(Funct3),
	.ALUOp		(ALUOp)
	
);

endmodule