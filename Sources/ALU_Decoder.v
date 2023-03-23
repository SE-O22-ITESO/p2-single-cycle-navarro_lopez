`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes RTL model for ALU Decoder for RISCV Control Unit
// Date: March 7, 2023
//////////////////////////////////////////////////////////////////////////////////
module ALU_Decoder(

	// Inputs
	input ALUControl,
	input [06:00] Opcode,
	input [06:00] Funct7,
	input [02:00] Funct3,
	// Outputs
	output reg [3:0] ALUOp
		
);
// ====================================================
// = Parameters            
// ====================================================
localparam ALU_ADD	= 4'd00; // ALUResult = A + B
localparam ALU_SUB	= 4'd01; // ALUResult = A - B
localparam ALU_XOR	= 4'd02; // ALUResult = A ˆ B
localparam ALU_OR		= 4'd03; // ALUResult = A | B
localparam ALU_AND	= 4'd04; // ALUResult = A & B
localparam ALU_SLL	= 4'd05; // ALUResult = A << B[5:0]
localparam ALU_SRL	= 4'd06; // ALUResult = A >> B[5:0]
localparam ALU_LST	= 4'd07; // ALUResult = (A < B)?1:0
localparam ALU_MUL	= 4'd08; // ALUResult = (A * B) [31:0]
localparam ALU_DIV 	= 4'd09; // ALUResult = A / B
localparam ALU_NA		= 4'd15; // ALUResult = 0


always @ (ALUControl, Opcode, Funct3, Funct7) begin

	ALUOp = ALU_NA;
	
	casez({ALUControl, Opcode, Funct3, Funct7})
		
		// Unused instructions will be commentedout
		// to avoid decoded and synthetized
		
		18'b1_???????_???_???????: ALUOp = ALU_ADD  ; //
		
		// R-Type Registers
		//17'b0110011_000_0000000: ALUOp = ALU_ADD  ; // add
		//17'b0110011_000_0100000: ALUOp = ALU_SUB  ; // sub
		//17'b0110011_100_0000000: ALUOp = ALU_XOR  ; // xor
		//17'b0110011_110_0000000: ALUOp = ALU_OR   ; // or
		//17'b0110011_111_0000000: ALUOp = ALU_AND  ; // and
		//17'b0110011_001_0000000: ALUOp = ALU_SLL  ; // sll
		//17'b0110011_101_0000000: ALUOp = ALU_SRL  ; // srl
		//17'b0110011_101_0100000: ALUOp = ALU_SRL  ; // sra
		//17'b0110011_010_0000000: ALUOp = ALU_NA   ; // slt
		//17'b0110011_011_0000000: ALUOp = ALU_NA   ; // sltu 
		
		// I-Type Immediate
		18'b0_0010011_000_???????: ALUOp = ALU_ADD  ; // addi
		//17'b0010011_100_???????: ALUOp = ALU_XOR  ; // xori
		//17'b0010011_110_???????: ALUOp = ALU_OR   ; // ori
		18'b0_0010011_111_???????: ALUOp = ALU_AND  ; // andi
		18'b0_0010011_001_0000000: ALUOp = ALU_SLL  ; // slli
		//17'b0010011_101_0000000: ALUOp = ALU_SRL  ; // srli
		//17'b0010011_101_0100000: ALUOp = ALU_SRL  ; // srai
		18'b0_0010011_010_???????: ALUOp = ALU_LST  ; // slti
		//17'b0010011_011_???????: ALUOp = ALU_LST  ; // sltiu
		
		// I-Type Load
		18'b0_0000011_010_???????: ALUOp = ALU_ADD  ; // lw
		
		// S-Type Store
		18'b0_0100011_010_???????: ALUOp = ALU_ADD  ; // sw
		
		// B-Type Branch
		//17'b1100011_000_???????: ALUOp = ALU_ADD  ; // beq
		18'b0_1100011_001_???????: ALUOp = ALU_ADD  ; // bne
		
		// J-Type Jump and link / (I-Type) Jump and link reg
		18'b0_1101111_???_???????: ALUOp = ALU_ADD  ; // jal
		18'b0_1100111_000_???????: ALUOp = ALU_ADD  ; // jalr
		
		// U-Type Upper
		18'b0_0110111_???_???????: ALUOp = ALU_ADD  ; // lui
		18'b0_0010111_???_???????: ALUOp = ALU_ADD  ; // auipc
		
		// R-Type Multiply extension
		18'b0_0110011_000_0000001: ALUOp = ALU_MUL  ; // mul
		//17'b0110011_100_0000001: ALUOp = ALU_DIV  ; // div

		
		default: ALUOp = ALU_NA;
	endcase
	
	
end

endmodule