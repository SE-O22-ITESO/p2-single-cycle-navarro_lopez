`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes RTL model for FSM used to handle RISCV Control Unit
//   signal cadance, timings and enablement for other models 
// Date: Marzo 8, 2023
//////////////////////////////////////////////////////////////////////////////////
module Main_Controller_FSM(
	output reg PCWrite,			//
	output reg AddrSrc, 			//
	output reg MemRead,			//
	output reg MemWrite,			//
	output reg [01:00] WritebackSrc,	//
	output reg IRWrite,			//
		
	input [06:00] Opcode,
	input [06:00] Funct7,
	input [02:00] Funct3,
	
	output reg PCSrc,				//
	output reg ALUControl,
	output reg [1:0]ALUSrcA,	//
	output reg [1:0]ALUSrcB,	//
	output reg RegWrite,			//
	input [1:0]Comp,		//
	
	input	clk,
	input	rst
);
// ====================================================
// = Machine state         
// ====================================================
localparam INS_FETCH		= 5'd00;
localparam INS_DECODE	= 5'd01;
localparam REG_EXEC		= 5'd02;
localparam IMM_EXEC		= 5'd03;
localparam JAL_EXEC		= 5'd04;
localparam JAR_EXEC		= 5'd05;
localparam BRN_COMP		= 5'd06;
localparam AUI_EXEC		= 5'd07;
localparam LUI_EXEC		= 5'd08;
localparam JAL_WRTBCK	= 5'd09;
localparam JAR_WRTBCK	= 5'd10;
localparam GNR_WRTBCK	= 5'd11;
localparam MEM_ADDR		= 5'd12;
localparam MEM_LOAD		= 5'd13;
localparam MEM_STORE		= 5'd14;
localparam MEM_WRTBCK	= 5'd15;
localparam BRN_REACH		= 5'd16;
localparam BRN_REJCT		= 5'd17;
localparam CPU_HALT		= 5'd31;

localparam OPCODE_R_TYPE_LA	= 7'b0110011;	// R-Type Logic Arithmetic
localparam OPCODE_I_TYPE_LA	= 7'b0010011;	// I-Type Logic Arithmetic
localparam OPCODE_I_TYPE_LW	= 7'b0000011;	// I-Type Load Word
localparam OPCODE_I_TYPE_JR	= 7'b1100111;	// I-Type Jump and Link Register
localparam OPCODE_S_TYPE_SW	= 7'b0100011;	// S-Type Store Word
localparam OPCODE_B_TYPE_BR	= 7'b1100011;	// B-Type Branch
localparam OPCODE_U_TYPE_LU	= 7'b0110111;	// U-Type Load Upper Imm
localparam OPCODE_U_TYPE_AU	= 7'b0010111;	// U-Type Add Upper Imm to PC 
localparam OPCODE_J_TYPE_JL	= 7'b1101111;	// J-Type Jump and Link

localparam FUNC3_BRN_EQU	= 3'd0;
localparam FUNC3_BRN_NEQ	= 3'd1;

localparam CMP_EQU	= 2'd0;	// Comp: A == B
localparam CMP_LST	= 2'd1;	// Comp: A < B
localparam CMP_GRT	= 2'd2;	// Comp: A > B
localparam CMP_NA		= 2'd3;	// Comp: 

// ====================================================
// = State Machine         
// ====================================================
// State register
reg [4:0] state;

//Next state logic & Present state FF's
always @(posedge rst, posedge clk) begin
	
	if (rst) 
		state <= INS_FETCH;
	
	else
		case(state)
		
			// ===== Instruction fetch =======================================
			INS_FETCH: begin
				state <= INS_DECODE;
				end
				
			// ===== Instruction decode ======================================
			INS_DECODE: begin
				
				case(Opcode)
					OPCODE_R_TYPE_LA: state <= REG_EXEC;	// => Register Execute
					OPCODE_I_TYPE_LA: state <= IMM_EXEC;	// => Immediate execute
					OPCODE_I_TYPE_LW: state <= MEM_ADDR;	// => Memory address calc
					OPCODE_I_TYPE_JR: state <= JAR_WRTBCK; // => Direct to Writeback
					OPCODE_S_TYPE_SW: state <= MEM_ADDR;	// => Memory address calc
					OPCODE_B_TYPE_BR: state <= BRN_COMP;	// => Branch completion
					OPCODE_U_TYPE_LU: state <= LUI_EXEC;	// => Load up imm exe
					OPCODE_U_TYPE_AU: state <= AUI_EXEC;	// => Add up imm to pc exe
					OPCODE_J_TYPE_JL: state <= JAL_WRTBCK;	// => Direct to Writeback
					default: state <= CPU_HALT;
				endcase
				
				end
				
			// ===== Execution / Completion =============================
			REG_EXEC: begin
				state <= GNR_WRTBCK;	// => General writeback
				end
				
			IMM_EXEC: begin
				state <= GNR_WRTBCK;	// => General writeback
				end
				
			BRN_COMP: begin			
				if((Funct3 == FUNC3_BRN_EQU) && (Comp == CMP_EQU) || // if(rs1 == rs2) PC += imm
					(Funct3 == FUNC3_BRN_NEQ) && (Comp != CMP_EQU))   // if(rs1 != rs2) PC += imm
					state <= BRN_REACH;	// => Branch reach
				else
					state <= BRN_REJCT;	// => Branch rejection
										
				end
			
			LUI_EXEC: begin
				state <= GNR_WRTBCK;	// => General writeback
				end
			
			
			AUI_EXEC: begin
				state <= GNR_WRTBCK;	// => General writeback
				end
				
			JAL_EXEC: begin
				state <= INS_FETCH; // => Instruction fetch
				end
			// ===== Memory Address Calculation =========================
			MEM_ADDR: begin
				case(Opcode)
					OPCODE_I_TYPE_LW: state <= MEM_LOAD; // => Memory load
					OPCODE_S_TYPE_SW: state <= MEM_STORE;// => Memory store
					default: state <= CPU_HALT;
				endcase
				end
				
			// ===== Memory Access ======================================
			MEM_LOAD: begin
				state <= MEM_WRTBCK;	// => Memory writeback
				end
				
			MEM_STORE: begin
				state <= INS_FETCH;	// => Instruction fetch
				end
			
			// ===== Memory Writeback ===================================
			MEM_WRTBCK: begin
				state <= INS_FETCH;	// => Instruction fetch
				end
					
			
			// ===== Register File Writeback ============================
			GNR_WRTBCK: begin
				state <= INS_FETCH;	// => Instruction fetch
				end
			
			JAL_WRTBCK: begin
				state <= JAL_EXEC;	// => Execute
				end
			
			JAR_WRTBCK: begin
				state <= JAR_EXEC;	// => Execute
				end
						
			// ===== Branch completion ==================================
			BRN_REACH: begin
				state <= INS_FETCH;	// => Instruction fetch
				end
			
			BRN_REJCT: begin
				state <= INS_FETCH;	// => Instruction fetch
				end
				
			// ===== CPU ================================================
			CPU_HALT: begin
				//state <= state;	// Loop
				state <= state;
				end
			
			default: begin
				state <= INS_FETCH;
				end
			
		endcase
end

//// Output logic
always @(state) begin

	// Default values
	PCWrite			= 1'b0;
	AddrSrc			= 1'b0;
	MemRead			= 1'b0;
	MemWrite			= 1'b0;
	WritebackSrc	= 2'b00;
	IRWrite			= 1'b0;
	
	ALUControl		= 1'b0;
	PCSrc				= 1'b0;
	ALUSrcA			= 2'b00;
	ALUSrcB			= 2'b00;
	RegWrite			= 1'b0;
		
	case(state)
		// ===== Instruction fetch =====================
		INS_FETCH: begin
			PCWrite			= 1'b1;	// Set PCWrite
			AddrSrc			= 1'b0;	// Addr = PC
			MemRead			= 1'b1;	// Read instr memory
			//MemWrite			= 1'b0;
			//WritebackSrc	= 2'b00;
			IRWrite			= 1'b1; // Set IRWrite 
			
			ALUControl		= 1'b1;	// Set ALUControl
			PCSrc				= 1'b0;	// ALUResult (PC+4)
			ALUSrcA			= 2'b00; // A = PC
			ALUSrcB			= 2'b01; // B = 4
			//RegWrite			= 1'b0;
			end
		
		// ===== Instruction decode ====================
		INS_DECODE: begin
			//PCWrite			= 1'b0;
			//AddrSrc			= 1'b0;
			//MemRead			= 1'b0;
			//MemWrite			= 1'b0;
			//WritebackSrc		= 2'b00;
			//IRWrite			= 1'b0;
			
			//PCSrc				= 1'b0;
			ALUSrcA			= 2'b00; // A = PC
			ALUSrcB			= 2'b10; // B = ImmExt
			//RegWrite			= 1'b0;
			end
			
		// ===== Execution / Completion ================
		REG_EXEC: begin
			//PCWrite			= 1'b0;
			//AddrSrc			= 1'b0;
			//MemRead			= 1'b0;
			//MemWrite			= 1'b0;
			//WritebackSrc		= 2'b00;
			//IRWrite			= 1'b0;
		
			//PCSrc				= 1'b0;
			ALUSrcA			= 2'b10; // A = AReg
			ALUSrcB			= 2'b00; // B = BReg
			//RegWrite			= 1'b0;
			end
		
		IMM_EXEC: begin
			//PCWrite			= 1'b0;
			//AddrSrc			= 1'b0;
			//MemRead			= 1'b0;
			//MemWrite			= 1'b0;
			//WritebackSrc		= 2'b00;
			//IRWrite			= 1'b0;
		
			//PCSrc				= 1'b0;
			ALUSrcA			= 2'b10; // A = AReg
			ALUSrcB			= 2'b10; // B = ImmExt
			//RegWrite			= 1'b0;
			end
		
		BRN_COMP: begin
			//PCWrite			= 1'b0;
			//AddrSrc			= 1'b0;
			//MemRead			= 1'b0;
			//MemWrite			= 1'b0;
			//WritebackSrc		= 2'b00;
			//IRWrite			= 1'b0;
		
			//PCSrc				= 1'b0;
			ALUSrcA			= 2'b10; // A = AReg
			ALUSrcB			= 2'b00; // B = BReg
			//RegWrite			= 1'b0;
			end
		
		AUI_EXEC: begin
			//PCWrite			= 1'b0;
			//AddrSrc			= 1'b0;
			//MemRead			= 1'b0;
			//MemWrite			= 1'b0;
			//WritebackSrc		= 2'b00;
			//IRWrite			= 1'b0;
		
			//PCSrc				= 1'b0;
			ALUSrcA			= 2'b01; // A = OldPC
			ALUSrcB			= 2'b10; // B = ImmExt
			//RegWrite			= 1'b0;
			end
			
		LUI_EXEC: begin
			//PCWrite			= 1'b0;
			//AddrSrc			= 1'b0;
			//MemRead			= 1'b0;
			//MemWrite			= 1'b0;
			//WritebackSrc		= 2'b00;
			//IRWrite			= 1'b0;
		
			//PCSrc				= 1'b0;
			ALUSrcA			= 2'b11; // A = 0
			ALUSrcB			= 2'b10; // B = ImmExt
			//RegWrite			= 1'b0;
			end
			
		JAL_EXEC: begin
			PCWrite			= 1'b1;	//Set PCWrite
			//AddrSrc			= 1'b0;
			//MemRead			= 1'b0;
			//MemWrite			= 1'b0;
			//WritebackSrc		= 2'b00;
			//IRWrite			= 1'b0;
			
			//ALUControl		= 1'b0;
			PCSrc				= 1'b0;	// ALUResult (OldPC+ImmExt)
			ALUSrcA			= 2'b01; // A = OldPC
			ALUSrcB			= 2'b10; // B = ImmExt
			//RegWrite			= 1'b0;
			end
			
		JAR_EXEC: begin
			PCWrite			= 1'b1;	//Set PCWrite
			//AddrSrc			= 1'b0;
			//MemRead			= 1'b0;
			//MemWrite			= 1'b0;
			//WritebackSrc		= 2'b00;
			//IRWrite			= 1'b0;
			
			//ALUControl		= 1'b0;
			PCSrc				= 1'b0;	// ALUResult (AReg+ImmExt)
			ALUSrcA			= 2'b10; // A = AReg
			ALUSrcB			= 2'b10; // B = ImmExt
			//RegWrite			= 1'b0;
			end
				
		// ===== Memory Address Calculation ============
		MEM_ADDR: begin
			//PCWrite			= 1'b0;
			//AddrSrc			= 1'b0;
			//MemRead			= 1'b0;
			//MemWrite			= 1'b0;
			//WritebackSrc		= 2'b00;
			//IRWrite			= 1'b0;
		
			//PCSrc				= 1'b0;
			ALUSrcA			= 2'b10; // A = AReg
			ALUSrcB			= 2'b10; // B = ImmExt
			//RegWrite			= 1'b0;
			end
		// ===== Memory Access =========================
		MEM_LOAD: begin
			//PCWrite			= 1'b0;
			AddrSrc			= 1'b1; // ALUOut
			MemRead			= 1'b1; // Set MemRead
			//MemWrite			= 1'b0;
			//WritebackSrc		= 2'b00;
			//IRWrite			= 1'b0;
		
			//PCSrc				= 1'b0;
			//ALUSrcA			= 2'b00;
			//ALUSrcB			= 2'b00;
			//RegWrite			= 1'b0;
			end
		
		MEM_STORE: begin
			//PCWrite			= 1'b0;
			AddrSrc			= 1'b1; // ALUOut
			//MemRead			= 1'b0;
			MemWrite			= 1'b1; // Set MemWrite
			//WritebackSrc		= 2'b00;
			//IRWrite			= 1'b0;
		
			//PCSrc				= 1'b0;
			//ALUSrcA			= 2'b00;
			//ALUSrcB			= 2'b00;
			//RegWrite			= 1'b0;
			end
		
		// ===== Writeback ============================
		MEM_WRTBCK: begin
			//PCWrite			= 1'b0;
			//AddrSrc			= 1'b0;
			//MemRead			= 1'b0;
			//MemWrite			= 1'b0;
			WritebackSrc		= 2'b00; // Data_Reg
			//IRWrite			= 1'b0;
		
			//PCSrc				= 1'b0;
			//ALUSrcA			= 2'b00;
			//ALUSrcB			= 2'b00;
			RegWrite				= 1'b1;	// Set RegWrite
			end
			
		GNR_WRTBCK: begin
			//PCWrite			= 1'b0;
			//AddrSrc			= 1'b0;
			//MemRead			= 1'b0;
			//MemWrite			= 1'b0;
			WritebackSrc		= 2'b01; // ALUOut_Reg
			//IRWrite			= 1'b0;
		
			//PCSrc				= 1'b0;
			//ALUSrcA			= 2'b00;
			//ALUSrcB			= 2'b00;
			RegWrite				= 1'b1;	// Set RegWrite
			end
			
		JAL_WRTBCK: begin
			//PCWrite			= 1'b0;
			//AddrSrc			= 1'b0;
			//MemRead			= 1'b0;
			//MemWrite			= 1'b0;
			WritebackSrc		= 2'b10; // PCNext
			//IRWrite			= 1'b0;
			
			//ALUControl		= 1'b0;
			//PCSrc				= 1'b0;
			ALUSrcA			= 2'b00; // PCNext
			ALUSrcB			= 2'b11;  //0
			RegWrite			= 1'b1;	// Set RegWrite
			end
			
		JAR_WRTBCK: begin
			//PCWrite			= 1'b0;
			//AddrSrc			= 1'b0;
			//MemRead			= 1'b0;
			//MemWrite			= 1'b0;
			WritebackSrc		= 2'b01; // ALUOut_Reg
			//IRWrite			= 1'b0;
			
			//ALUControl		= 1'b0;
			//PCSrc				= 1'b0;
			ALUSrcA			= 2'b00; // PCNext
			ALUSrcB			= 2'b11;  //0
			RegWrite			= 1'b1;	// Set RegWrite
			end
			
		// ===== Branch completion ==================================
		BRN_REACH: begin
			PCWrite			= 1'b1;	//Set PCWrite
			//AddrSrc			= 1'b0;
			//MemRead			= 1'b0;
			//MemWrite			= 1'b0;
			//WritebackSrc		= 2'b00;
			//IRWrite			= 1'b0;
		
			PCSrc				= 1'b0;	// ALUResult (OldPC+ImmExt)
			ALUControl		= 1'b1;	// Set ALUControl
			ALUSrcA			= 2'b01; // A = OldPC
			ALUSrcB			= 2'b10; // B = ImmExt
			//RegWrite			= 1'b0;
			end
						
		 BRN_REJCT: begin
			PCWrite			= 1'b1;	//Set PCWrite
			//AddrSrc			= 1'b0;
			//MemRead			= 1'b0;
			//MemWrite			= 1'b0;
			//WritebackSrc		= 2'b00;
			//IRWrite			= 1'b0;
		
			PCSrc				= 1'b0;	// ALUResult (OldPC+4)
			ALUControl		= 1'b1;	// Set ALUControl
			ALUSrcA			= 2'b01; // A = OldPC
			ALUSrcB			= 2'b01;	// B = 4
			//RegWrite			= 1'b0;
			end
			
		// ===== CPU ================================================
		CPU_HALT: begin
			// Default signal values
			PCWrite			= 1'b0;
			AddrSrc			= 1'b0;
			MemRead			= 1'b0;
			MemWrite			= 1'b0;
			WritebackSrc	= 2'b00;
			IRWrite			= 1'b0;

			PCSrc				= 1'b0;
			ALUSrcA			= 2'b00;
			ALUSrcB			= 2'b00;
			RegWrite			= 1'b0;
			end
			
		default: begin
			// Default signal values
			PCWrite			= 1'b0;
			AddrSrc			= 1'b0;
			MemRead			= 1'b0;
			MemWrite			= 1'b0;
			WritebackSrc	= 2'b00;
			IRWrite			= 1'b0;

			PCSrc				= 1'b0;
			ALUSrcA			= 2'b00;
			ALUSrcB			= 2'b00;
			RegWrite			= 1'b0;
			end
			
		endcase
end


endmodule
