`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes the top desing RTL model to implement the immediate generator
//   for a 32bit Multi-cycle RISC-V microprocessor
// Date: March 5, 2023
//////////////////////////////////////////////////////////////////////////////////
module Immediate_Generator(
	
	// Inputs
	input [31:00] Instr,
	
	// Outputs
	output reg [31:0] ImmExt
);

// ====================================================
// = Parameters            
// ====================================================
//localparam OPCODE_R_TYPE_0	= 7'b0110011; // Not required
localparam OPCODE_I_TYPE_0	= 7'b0010011;
localparam OPCODE_I_TYPE_1	= 7'b0000011;
localparam OPCODE_I_TYPE_2	= 7'b1100111;
localparam OPCODE_S_TYPE_0	= 7'b0100011;
localparam OPCODE_B_TYPE_0	= 7'b1100011;
localparam OPCODE_U_TYPE_0	= 7'b0110111;
localparam OPCODE_U_TYPE_1	= 7'b0010111;
localparam OPCODE_J_TYPE_0	= 7'b1101111;

// Wiring
//wire [06:00] Opcode;
//assign Opcode = Instr[06:00];

always @(Instr) begin

	//case (Opcode)
	case (Instr[06:00])
		
		// I-type
		OPCODE_I_TYPE_0: ImmExt = {{20{Instr[31]}}, Instr[31:20]};
		OPCODE_I_TYPE_1: ImmExt = {{20{Instr[31]}}, Instr[31:20]};
		OPCODE_I_TYPE_2: ImmExt = {{20{Instr[31]}}, Instr[31:20]};

		// S-type
		OPCODE_S_TYPE_0: ImmExt = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]};

		// B-type
		OPCODE_B_TYPE_0: ImmExt = {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0};

		// U-type
		OPCODE_U_TYPE_0: ImmExt = {Instr[31], Instr[30:20], Instr[19:12], {12{1'b0}}};
		OPCODE_U_TYPE_1: ImmExt = {Instr[31], Instr[30:20], Instr[19:12], {12{1'b0}}};

		// J-type
		OPCODE_J_TYPE_0: ImmExt = {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0};
		
		// R-type and un-supported opcodes
		default: ImmExt = 32'b0;
		
	endcase
end

endmodule
