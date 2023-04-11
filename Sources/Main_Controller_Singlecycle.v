`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes RTL model for FSM used to handle RISCV Singlecycle Control Unit
//   signal cadance, timings and enablement for other models 
// Date: April 4, 2023
//////////////////////////////////////////////////////////////////////////////////
module Main_Controller_Singlecycle(
	
	output MemRead,				//
	output MemWrite,				//
	input [1:0] Comp,				//
	output [3:0] ALUOp,			//
	output [1:0] PCSrc,			//
	output [1:0] ALUSrcB,		//
	output RegWrite,				//
	output [2:0] WritebackSrc,	// "MemtoReg"
	input [06:00] Opcode,
	input [06:00] Funct7,
	input [02:00] Funct3,
	
	input	clk,
	input	rst
);
// ====================================================
// = Parameters       
// ====================================================
// Opcodes
localparam OPCODE_R_TYPE_LA	= 7'b0110011;	// R-Type Logic Arithmetic
localparam OPCODE_I_TYPE_LA	= 7'b0010011;	// I-Type Logic Arithmetic
localparam OPCODE_I_TYPE_LW	= 7'b0000011;	// I-Type Load Word
localparam OPCODE_I_TYPE_JR	= 7'b1100111;	// I-Type Jump and Link Register
localparam OPCODE_S_TYPE_SW	= 7'b0100011;	// S-Type Store Word
localparam OPCODE_B_TYPE_BR	= 7'b1100011;	// B-Type Branch
localparam OPCODE_U_TYPE_LU	= 7'b0110111;	// U-Type Load Upper Imm
localparam OPCODE_U_TYPE_AU	= 7'b0010111;	// U-Type Add Upper Imm to PC 
localparam OPCODE_J_TYPE_JL	= 7'b1101111;	// J-Type Jump and Link
// ALU Operations
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
// PCSrc
localparam PC_4	= 2'd0;
localparam PC_Im	= 2'd1;
localparam RS_Im	= 2'd2;
localparam PC		= 2'd3;
// ALUSrcB
localparam ALUB_RS2			=2'd0;
localparam ALUB_Imm			=2'd1;
localparam ALUB_4				=2'd2;
localparam ALUB_0				=2'd3;
// WritebackSrc
localparam WbS_MemData		= 3'd0;
localparam WbS_ALURes		= 3'd1;
localparam WbS_PC_4			= 3'd2;
localparam WbS_Imm			= 3'd3;
localparam WbS_PC_Imm		= 3'd4;

localparam FUNC3_BRN_EQU	= 3'd0;
localparam FUNC3_BRN_NEQ	= 3'd1;
// Compare A, B flag
localparam CMP_EQU	= 2'd0;	// Comp: A == B
localparam CMP_LST	= 2'd1;	// Comp: A < B
localparam CMP_GRT	= 2'd2;	// Comp: A > B
localparam CMP_NA		= 2'd3;	// Comp: 

reg [13:0] Outputs;

always @ (Comp,Funct7,Funct3,Opcode) begin
	
	//Outputs = 12'b0;

	casez({Comp,Funct7,Funct3,Opcode})
		
		// R-Type Logic-Arithmetic ======================= M M  A        P     A             R W    
		//   _____ _             __                        e e  L        C     L             e b
		//  / ___/(_)___  ____ _/ /__                      m m  U        S     U             g S
		//  \__ \/ / __ \/ __ `/ / _ \                     R W  O        r     S             W r
		// ___/ / / / / / /_/ / /  __/                     d r  p        c     B             r c 
		//{2'b??,7'h00,3'h0,OPCODE_R_TYPE_LA}: Outputs = {2'b0_0, ALU_ADD, PC_4 , ALUB_RS2, 1'b1,WbS_ALURes }; // add  | rd = rs1 + rs2
		//{2'b??,7'h20,3'h0,OPCODE_R_TYPE_LA}: Outputs = {2'b0_0, ALU_SUB, PC_4 , ALUB_RS2, 1'b1,WbS_ALURes }; // sub  | rd = rs1 - rs2
		//{2'b??,7'h00,3'h4,OPCODE_R_TYPE_LA}: Outputs = {2'b0_0, ALU_XOR, PC_4 , ALUB_RS2, 1'b1,WbS_ALURes }; // xor  | rd = rs1 ˆ rs2
		//{2'b??,7'h00,3'h6,OPCODE_R_TYPE_LA}: Outputs = {2'b0_0, ALU_OR , PC_4 , ALUB_RS2, 1'b1,WbS_ALURes }; // or   | rd = rs1 | rs2
		//{2'b??,7'h00,3'h7,OPCODE_R_TYPE_LA}: Outputs = {2'b0_0, ALU_AND, PC_4 , ALUB_RS2, 1'b1,WbS_ALURes }; // and  | rd = rs1 & rs2
		//{2'b??,7'h00,3'h1,OPCODE_R_TYPE_LA}: Outputs = {2'b0_0, ALU_SLL, PC_4 , ALUB_RS2, 1'b1,WbS_ALURes }; // sll  | rd = rs1 << rs2
		{2'b??,7'h00,3'h5,OPCODE_R_TYPE_LA}: Outputs = {2'b0_0, ALU_SRL, PC_4 , ALUB_RS2, 1'b1,WbS_ALURes }; // srl  | rd = rs1 >> rs2
		//{2'b??,7'h20,3'h5,OPCODE_R_TYPE_LA}: Outputs = {2'b0_0, ALU_SRL, PC_4 , ALUB_RS2, 1'b1,WbS_ALURes }; // sra  | rd = rs1 >> rs2 msb-extends
		//{2'b??,7'h00,3'h2,OPCODE_R_TYPE_LA}: Outputs = {2'b0_0, ALU_LST, PC_4 , ALUB_RS2, 1'b1,WbS_ALURes }; // slt  | rd = (rs1 < rs2)?1:0
		//{2'b??,7'h00,3'h3,OPCODE_R_TYPE_LA}: Outputs = {2'b0_0, ALU_LST, PC_4 , ALUB_RS2, 1'b1,WbS_ALURes }; // sltu | rd = (rs1 < rs2)?1:0 zero-extends
		{2'b??,7'h01,3'h0,OPCODE_R_TYPE_LA}: Outputs = {2'b0_0, ALU_MUL, PC_4 , ALUB_RS2, 1'b1,WbS_ALURes }; // mul  | rd = (rs1 * rs2)[31:0]
		//{2'b??,7'h01,3'h4,OPCODE_R_TYPE_LA}: Outputs = {2'b0_0, ALU_DIV, PC_4 , ALUB_RS2, 1'b1,WbS_ALURes }; // div  | rd = rs1 / rs2
		
		// I-Type Logic-Arithmetic ======================= M M  A        P     A             R W    
		//   _______  _______/ /__                         e e  L        C     L             e b
		//  / ___/ / / / ___/ / _ \                        m m  U        S     U             g S
		// / /__/ /_/ / /__/ /  __/                        R W  O        r     S             W r
		// \___/\__, /\___/_/\___/                         d r  p        c     B             r c 
		{2'b??,7'h??,3'h0,OPCODE_I_TYPE_LA}: Outputs = {2'b0_0, ALU_ADD, PC_4 , ALUB_Imm, 1'b1,WbS_ALURes }; // addi | rd = rs1 + imm
		//{2'b??,7'h??,3'h4,OPCODE_I_TYPE_LA}: Outputs = {2'b0_0, ALU_XOR, PC_4 , ALUB_Imm, 1'b1,WbS_ALURes }; // xori | rd = rs1 ˆ imm
		//{2'b??,7'h??,3'h6,OPCODE_I_TYPE_LA}: Outputs = {2'b0_0, ALU_OR , PC_4 , ALUB_Imm, 1'b1,WbS_ALURes }; // ori  | rd = rs1 | imm
		{2'b??,7'h??,3'h7,OPCODE_I_TYPE_LA}: Outputs = {2'b0_0, ALU_AND, PC_4 , ALUB_Imm, 1'b1,WbS_ALURes }; // andi | rd = rs1 & imm
		//{2'b??,7'h00,3'h1,OPCODE_I_TYPE_LA}: Outputs = {2'b0_0, ALU_SLL, PC_4 , ALUB_Imm, 1'b1,WbS_ALURes }; // slli | rd = rs1 << imm[0:4]
		{2'b??,7'h00,3'h5,OPCODE_I_TYPE_LA}: Outputs = {2'b0_0, ALU_SRL, PC_4 , ALUB_Imm, 1'b1,WbS_ALURes }; // srli | rd = rs1 >> imm[0:4]
		//{2'b??,7'h20,3'h5,OPCODE_I_TYPE_LA}: Outputs = {2'b0_0, ALU_SRL, PC_4 , ALUB_Imm, 1'b1,WbS_ALURes }; // srai | rd = rs1 >> imm[0:4] msb-extends
		{2'b??,7'h??,3'h2,OPCODE_I_TYPE_LA}: Outputs = {2'b0_0, ALU_LST, PC_4 , ALUB_Imm, 1'b1,WbS_ALURes }; // slti | rd = (rs1 < imm)?1:0
		//{2'b??,7'h??,3'h3,OPCODE_I_TYPE_LA}: Outputs = {2'b0_0, ALU_LST, PC_4 , ALUB_Imm, 1'b1,WbS_ALURes }; // sltiu| rd = (rs1 < imm)?1:0 zero-extends
				
		// I-Type Jump and Link Register ================= M M  A        P     A             R W    
		//     ____  _________ ______   _    __            e e  L        C     L             e b
		//    / __ \/  _/ ___// ____/  | |  / /            m m  U        S     U             g S
		//   / /_/ // / \__ \/ /  _____| | / /             R W  O        r     S             W r
		//  / _, _// / ___/ / /__/_____/ |/ /              d r  p        c     B             r c 
		{2'b??,7'h??,3'h0,OPCODE_I_TYPE_JR}: Outputs = {2'b0_0, ALU_NA , RS_Im, ALUB_0  , 1'b1,WbS_PC_4   }; // jalr | rd = PC+4; PC = rs1 + imm
		
		// I-Type Load Word ==============================
		{2'b??,7'h??,3'h2,OPCODE_I_TYPE_LW}: Outputs = {2'b1_0, ALU_ADD, PC_4 , ALUB_Imm, 1'b1,WbS_MemData}; // lw   | rd = M[rs1+imm][0:31]
		
		// S-Type Store Word =============================
		{2'b??,7'h??,3'h2,OPCODE_S_TYPE_SW}: Outputs = {2'b0_1, ALU_ADD, PC_4 , ALUB_Imm, 1'b0,WbS_MemData}; // sw   | M[rs1+imm][0:31] = rs2[0:31]
		
		// B-Type Branch =================================
		{CMP_EQU,7'h??,3'h0,OPCODE_B_TYPE_BR}: Outputs={2'b0_0, ALU_NA , PC_Im, ALUB_RS2, 1'b0,WbS_MemData}; // beq  | if(rs1 == rs2) PC += imm (Branch case)
		{CMP_LST,7'h??,3'h0,OPCODE_B_TYPE_BR}: Outputs={2'b0_0, ALU_NA , PC_4 , ALUB_RS2, 1'b0,WbS_MemData}; // beq  | if(rs1 == rs2) PC += imm (Continue case)
		{CMP_GRT,7'h??,3'h0,OPCODE_B_TYPE_BR}: Outputs={2'b0_0, ALU_NA , PC_4 , ALUB_RS2, 1'b0,WbS_MemData}; // beq  | if(rs1 == rs2) PC += imm (Continue case)
		{CMP_NA ,7'h??,3'h0,OPCODE_B_TYPE_BR}: Outputs={2'b0_0, ALU_NA , PC_4 , ALUB_RS2, 1'b0,WbS_MemData}; // beq  | if(rs1 == rs2) PC += imm (Continue case)
		
		{CMP_EQU,7'h??,3'h1,OPCODE_B_TYPE_BR}: Outputs={2'b0_0, ALU_NA , PC_4 , ALUB_RS2, 1'b0,WbS_MemData}; // bne  | if(rs1 != rs2) PC += imm (Continue case)
		{CMP_LST,7'h??,3'h1,OPCODE_B_TYPE_BR}: Outputs={2'b0_0, ALU_NA , PC_Im, ALUB_RS2, 1'b0,WbS_MemData}; // bne  | if(rs1 != rs2) PC += imm (Branch case)
		{CMP_GRT,7'h??,3'h1,OPCODE_B_TYPE_BR}: Outputs={2'b0_0, ALU_NA , PC_Im, ALUB_RS2, 1'b0,WbS_MemData}; // bne  | if(rs1 != rs2) PC += imm (Branch case)
		{CMP_NA ,7'h??,3'h1,OPCODE_B_TYPE_BR}: Outputs={2'b0_0, ALU_NA , PC_Im, ALUB_RS2, 1'b0,WbS_MemData}; // bne  | if(rs1 != rs2) PC += imm (Branch case)
		
		// J-Type Jump and Link ==========================
		{2'b??,7'h??,3'h?,OPCODE_J_TYPE_JL}: Outputs = {2'b0_0, ALU_NA , PC_Im, ALUB_0  , 1'b1,WbS_PC_4   }; // jal  | rd = PC+4; PC += imm
		
		// U-Type Load Upper Imm ========================= 
		{2'b??,7'h??,3'h?,OPCODE_U_TYPE_LU}: Outputs = {2'b0_0, ALU_NA , PC_4 , ALUB_0  , 1'b1,WbS_Imm    }; // lui  | rd = imm << 12
		
		// U-Type Add Upper Imm to PC ====================
		//{2'b??,7'h??,3'h?,OPCODE_U_TYPE_AU}: Outputs = {2'b0_0, ALU_NA , PC_4 , ALUB_0  , 1'b1,WbS_PC_Imm }; // auipc| rd = PC + (imm << 12)
		
		
		
		// Undefined Opcode ============================== 
		default:                             Outputs = {2'b0_0, ALU_NA , PC   , ALUB_0  , 1'b0,WbS_MemData}; // (undef) PC = PC
		//default:                             Outputs = {2'b0_0, ALU_NA , PC_4 , ALUB_0  , 1'b0,WbS_MemData}; // (undef) PC = PC
		 
	endcase

end

assign MemRead			= Outputs[13];
assign MemWrite		= Outputs[12];
assign ALUOp			= Outputs[11:8];
assign PCSrc 			= Outputs[7:6];
assign ALUSrcB			= Outputs[5:4];
assign RegWrite		= Outputs[3];
assign WritebackSrc	= Outputs[2:0];

endmodule

// Experimental stuff
	//output reg [1:0]ALUSrcA,	//
	//output reg PCWrite,			//
	//output reg AddrSrc, 			//
	//output reg IRWrite,			//
