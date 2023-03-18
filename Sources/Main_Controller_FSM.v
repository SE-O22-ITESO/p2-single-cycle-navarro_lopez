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
	output reg WritebackSrc,	//
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
// = Machine states         
// ====================================================

localparam INS_FETCH		= 4'd00;
localparam INS_DECODE	= 4'd01;
localparam REG_EXEC		= 4'd02;
localparam IMM_EXEC		= 4'd03;
localparam BRN_COMP		= 4'd04;
localparam AUI_EXEC		= 4'd05;
localparam LUI_EXEC		= 4'd06;
localparam GNR_WRTBCK	= 4'd07;
localparam MEM_ADDR		= 4'd08;
localparam MEM_LOAD		= 4'd09;
localparam MEM_STORE		= 4'd10;
localparam MEM_WRTBCK	= 4'd11;
localparam BRN_REACH		= 4'd12;
localparam BRN_REJCT		= 4'd13;
localparam CPU_HALT		= 4'd15;

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
reg [3:0] state;

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
//					OPCODE_R_TYPE_LA: state <= REG_EXEC;	// => Register Execute
					OPCODE_I_TYPE_LA: state <= IMM_EXEC;	// => Immediate execute
					OPCODE_I_TYPE_LW: state <= MEM_ADDR;	// => Memory address calc
					//OPCODE_I_TYPE_JR: state <= GNR_WRTBCK; // => Direct to Writeback
					OPCODE_S_TYPE_SW: state <= MEM_ADDR;	// => Memory address calc
					OPCODE_B_TYPE_BR: state <= BRN_COMP;	// => Branch completion
					//OPCODE_U_TYPE_LU: state <= LUI_EXEC;		// Load up imm exe
					OPCODE_U_TYPE_AU: state <= AUI_EXEC;	// => Add up imm to pc exe
					//OPCODE_J_TYPE_JL: state <= 				//
					default: state <= CPU_HALT;
				endcase
				
				end
				
			// ===== Execution / Completion =============================
//			REG_EXEC: begin
//				state <= GNR_WRTBCK;	// => General writeback
//				end
				
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
			
//			LUI_EXEC begin
//				state <= GNR_WRTBCK;	// => General writeback
//				end
			
			
			AUI_EXEC: begin
				state <= GNR_WRTBCK;	// => General writeback
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
			
			// ===== General Writeback ==================================
			GNR_WRTBCK: begin
				state <= INS_FETCH;	// => Instruction fetch
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
	WritebackSrc	= 1'b0;
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
			//WritebackSrc	= 1'b0; 
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
			//WritebackSrc	= 1'b0;
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
			//WritebackSrc	= 1'b0;
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
			//WritebackSrc	= 1'b0;
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
			//WritebackSrc	= 1'b0;
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
			//WritebackSrc	= 1'b0;
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
			//WritebackSrc	= 1'b0;
			//IRWrite			= 1'b0;
		
			//PCSrc				= 1'b0;
			ALUSrcA			= 2'b11; // A = 0
			ALUSrcB			= 2'b10; // B = ImmExt
			//RegWrite			= 1'b0;
			end
				
		// ===== Memory Address Calculation ============
		MEM_ADDR: begin
			//PCWrite			= 1'b0;
			//AddrSrc			= 1'b0;
			//MemRead			= 1'b0;
			//MemWrite			= 1'b0;
			//WritebackSrc	= 1'b0;
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
			//WritebackSrc	= 1'b0;
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
			//WritebackSrc	= 1'b0;
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
			WritebackSrc	= 1'b0;	// DataReg
			//IRWrite			= 1'b0;
		
			//PCSrc				= 1'b0;
			//ALUSrcA			= 2'b00;
			//ALUSrcB			= 2'b00;
			RegWrite			= 1'b1;	// Set RegWrite
			end
			
		GNR_WRTBCK: begin
			//PCWrite			= 1'b0;
			//AddrSrc			= 1'b0;
			//MemRead			= 1'b0;
			//MemWrite			= 1'b0;
			WritebackSrc	= 1'b1; // AluResult
			//IRWrite			= 1'b0;
		
			//PCSrc				= 1'b0;
			//ALUSrcA			= 2'b00;
			//ALUSrcB			= 2'b00;
			RegWrite			= 1'b1;	// Set RegWrite
			end
			
		// ===== Branch completion ==================================
		BRN_REACH: begin
			PCWrite			= 1'b1;	//Set PCWrite
			//AddrSrc			= 1'b0;
			//MemRead			= 1'b0;
			//MemWrite			= 1'b0;
			//WritebackSrc	= 1'b0;
			//IRWrite			= 1'b0;
		
			PCSrc				= 1'b0;	// ALUResult (OldPC+ImmExt)
			ALUSrcA			= 2'b01; // A = OldPC
			ALUSrcB			= 2'b10; // B = ImmExt
			//RegWrite			= 1'b0;
			end
						
		 BRN_REJCT: begin
			PCWrite			= 1'b1;	//Set PCWrite
			//AddrSrc			= 1'b0;
			//MemRead			= 1'b0;
			//MemWrite			= 1'b0;
			//WritebackSrc	= 1'b0;
			//IRWrite			= 1'b0;
		
			PCSrc				= 1'b0;	// ALUResult (OldPC+4)
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
			WritebackSrc	= 1'b0;
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
			WritebackSrc	= 1'b0;
			IRWrite			= 1'b0;

			PCSrc				= 1'b0;
			ALUSrcA			= 2'b00;
			ALUSrcB			= 2'b00;
			RegWrite			= 1'b0;
			end
			
		endcase
end


endmodule

// Machine states
//localparam S0_FETCH					= 4'd00;
//localparam S1_DECODE					= 4'd01;
//localparam S2_MEM_ADR				= 4'd02;
//localparam S3_MEM_READ				= 4'd03;
//localparam S4_MEM_WRITEBACK		= 4'd04;
//localparam S5_MEM_WRITE				= 4'd05;
//localparam S6_EXECUTE				= 4'd06;
//localparam S7_ALU_WRITEBACK		= 4'd07;
//localparam S8_BRANCH					= 4'd08;
//localparam S9_ADDI_EXECUTE			= 4'd09;
//localparam S10_ADDI_WRITEBACK		= 4'd10;
//localparam S11_ANDI_EXECUTE		= 4'd11;
//localparam S12_EXECUTE				= 4'd12;
//localparam S13_EXECUTE				= 4'd13;
//localparam S14_ALU_WRITEBACK_2	= 4'd14;
//
//// Constants
////localparam INSTR_OPC_LW				= 6'bxx_xxxx;
////localparam INSTR_OPC_SW				= 6'bxx_xxxx;
////localparam INSTR_OPC_R_TYPE		= 6'h00;
////localparam INSTR_OPC_R				= 6'h00;
//
//localparam INSTR_OPC_LW				= 6'h23;
//localparam INSTR_OPC_SW				= 6'h2B;
//localparam INSTR_OPC_ADDI			= 6'h08;
//localparam INSTR_OPC_ANDI			= 6'h0C;
//
//localparam INSTR_OPC_SD				= 6'h3F;
//
////localparam INSTR_OPC_ADD			= 6'h20;
////localparam INSTR_OPC_OR				= 6'h25;
////localparam INSTR_OPC_SLL			= 6'h00;
//localparam INSTR_FNC_ADD			= 6'h20;
//localparam INSTR_FNC_OR				= 6'h25;
//localparam INSTR_FNC_SLL			= 6'h00;
//localparam INSTR_OPC_R				= 6'h00;
//wire [3:0] MC_State /*synthesis keep*/;
//assign MC_State = state; // To read with Signal Tap

// Next state logic & Present state FF's
//always @(posedge rst, posedge clk) begin
//	
//	if (rst) 
//		state <= S0_FETCH;
//	
//	else
//		case(state)
//		
//			S0_FETCH: begin
//				state <= S1_DECODE;
//				end
//				
//			S1_DECODE: begin
//			
//				case(Opcode)
//					INSTR_OPC_R: begin
//					
//						case(Funct)
//							INSTR_FNC_ADD:	state <= S6_EXECUTE;
//							INSTR_FNC_OR:	state <= S6_EXECUTE;
//							INSTR_FNC_SLL:	state <= S12_EXECUTE;
//							
//							
//						endcase
//						
//					end
//					
//					INSTR_OPC_LW:	state <= S2_MEM_ADR;
//					
//					INSTR_OPC_SW:	state <= S2_MEM_ADR;
//					
////					INSTR_OPC_ADD:	state <= S6_EXECUTE;
////					INSTR_OPC_OR:	state <= S6_EXECUTE;
////					//INSTR_OPC_SLL:	state <= S12_EXECUTE;
////					INSTR_OPC_SLL:	state <= S6_EXECUTE;
//					
//					INSTR_OPC_ADDI:state <= S9_ADDI_EXECUTE;
//					
//					INSTR_OPC_ANDI:state <= S11_ANDI_EXECUTE;
//					
//					INSTR_OPC_SD:	state <= S13_EXECUTE;
//				
//				endcase	
//													
//				end
//				
//			S2_MEM_ADR: begin
//				
//				case(Opcode)
//					INSTR_OPC_LW:	state <= S3_MEM_READ;
//					INSTR_OPC_SW:	state <= S5_MEM_WRITE;
//				endcase	
//				
//				end
//				
//			S3_MEM_READ: begin
//				state <= S4_MEM_WRITEBACK;
//				end
//				
//			S4_MEM_WRITEBACK: begin
//				state <= S0_FETCH;
//				end
//				
//			S5_MEM_WRITE: begin
//				state <= S0_FETCH;
//				end
//				
//			S6_EXECUTE: begin
//				state <= S7_ALU_WRITEBACK;
//				end
//				
//			S12_EXECUTE: begin
//				state <= S7_ALU_WRITEBACK;
//				end
//				
//			S13_EXECUTE: begin
//				state <= S14_ALU_WRITEBACK_2;
//				end
//				
//			S7_ALU_WRITEBACK: begin
//				state <= S0_FETCH;
//				end
//				
//			S14_ALU_WRITEBACK_2: begin
//				if(TxSent == 1'b1)
//					state <= S0_FETCH;
//				//else
//					//state <= S14_ALU_WRITEBACK_2;
//				end
//				
//			S8_BRANCH: begin
//				// Not required
//				end
//			
//			S9_ADDI_EXECUTE: begin
//				state <= S10_ADDI_WRITEBACK;
//				end
//			
//			S10_ADDI_WRITEBACK: begin
//				state <= S0_FETCH;
//				end
//			
//			S11_ANDI_EXECUTE: begin
//				state <= S10_ADDI_WRITEBACK;
//				end
//
//			
//			default:
//				state <= S0_FETCH;
//		
//		endcase
//	
//	
//end
//
//// Output logic
//always @(state) begin
//	
//	// Default values
//	MemtoReg = 1'b0;	// MUXs Selectors
//	RegDst	= 1'b0;	//
//	IorD		= 1'b0;	//
//	PCSrc		= 1'b0;	//
//	//ALUSrcA	= 1'b0;	// Added
//	ALUSrcA	= 2'b00;	//
//	ALUSrcB	= 2'b00;	//
//	IRWrite	= 1'b0;	// Registers Enablers
//	MemWrite	= 1'b0;	//
//	PCWrite	= 1'b0;	//
//	//Branch	= 1'b0;	//
//	RegWrite	= 1'b0;	//
//	ALUOp		= 2'b00;	//
//	TxSend	= 1'b0;
//		
//	case(state)
//	
//		S0_FETCH: begin
//			IorD			= 1'b0;
//			PCSrc			= 1'b0;
//			//ALUSrcA		= 1'b0;
//			ALUSrcA		= 2'b00;	// Added
//			ALUSrcB		= 2'b01;
//			IRWrite		= 1'b1;
//			MemWrite		= 1'b0;
//			PCWrite		= 1'b1;
//			RegWrite		= 1'b0;
//			ALUOp			= 2'b00;
//			end
//			
//		S1_DECODE: begin
//			IRWrite		= 1'b0;
//			MemWrite		= 1'b0;
//			PCWrite		= 1'b0;
//			RegWrite		= 1'b0;
//			end
//		
//		S2_MEM_ADR: begin
//			//ALUSrcA		= 1'b1;
//			ALUSrcA		= 2'b01;	// Added
//			ALUSrcB		= 2'b10;
//			ALUOp			= 2'b00;
//			end
//		
//		S3_MEM_READ: begin
//			IorD			= 1'b1;
//			end
//			
//		S4_MEM_WRITEBACK: begin
//			MemtoReg		= 1'b1;
//			RegDst		= 1'b0;			
//			RegWrite		= 1'b1;
//			end
//			
//		S5_MEM_WRITE: begin
//			IorD			= 1'b1;
//			MemWrite		= 1'b1;
//			end
//				
//		S6_EXECUTE: begin
//			//ALUSrcA		= 1'b1;
//			ALUSrcA		= 2'b01;	// Added
//			ALUSrcB		= 2'b00;
//			ALUOp			= 2'b10;
//			end
//			
//		S12_EXECUTE: begin
//			//ALUSrcA		= 1'b1;
//			ALUSrcA		= 2'b10;	// Added * sll
//			ALUSrcB		= 2'b11;
//			ALUOp			= 2'b10;
//			end
//			
//		S13_EXECUTE: begin
//			//ALUSrcA		= 1'b1;
//			ALUSrcA		= 2'b10;	// Added * sll
//			ALUSrcB		= 2'b11;
//			ALUOp			= 2'b10;
//			TxSend		= 1'b1;
//			end
//			
//		
//		S7_ALU_WRITEBACK: begin
//			MemtoReg		= 1'b0;
//			RegDst		= 1'b1;			
//			RegWrite		= 1'b1;
//			end
//			
//		S8_BRANCH: begin
//			// Not required
//			end
//		
//		S9_ADDI_EXECUTE: begin
//			//ALUSrcA		= 1'b1;
//			ALUSrcA		= 2'b01;	// Added
//			ALUSrcB		= 2'b10;
//			ALUOp			= 2'b00;
//			end
//		
//		S10_ADDI_WRITEBACK: begin
//			MemtoReg		= 1'b0;
//			RegDst		= 1'b0;			
//			RegWrite		= 1'b1;
//			end
//			
//		S11_ANDI_EXECUTE: begin
//			//ALUSrcA		= 1'b1;
//			ALUSrcA		= 2'b01;	// Added
//			ALUSrcB		= 2'b10;
//			ALUOp			= 2'b10;
//			end
//			
//		default: begin
//			// Default values
//			MemtoReg = 1'b0;	// MUXs Selectors
//			RegDst	= 1'b0;	//
//			IorD		= 1'b0;	//
//			PCSrc		= 1'b0;	//
//			//ALUSrcA	= 1'b0;	//
//			ALUSrcA	= 2'b00;	// Added
//			ALUSrcB	= 2'b00;	//
//			IRWrite	= 1'b0;	// Registers Enablers
//			MemWrite	= 1'b0;	//
//			PCWrite	= 1'b0;	//
//			//Branch	= 1'b0;	//
//			RegWrite	= 1'b0;	//
//			ALUOp		= 2'b00;	//
//			TxSend	= 1'b0;
//			end
//		
//		
//			
//	endcase
//
//end
//endmodule

// experimental stuff
//	MemtoReg = MemtoReg;	// MUXs Selectors
//	RegDst	= RegDst;	//
//	IorD		= IorD;		//
//	PCSrc		= PCSrc;		//
//	ALUSrcA	= ALUSrcA;	//
//	ALUSrcB	= ALUSrcB;	//
//	IRWrite	= IRWrite;	// Registers Enablers
//	MemWrite	= MemWrite;	//
//	PCWrite	= PCWrite;	//
//	//Branch	= Branch;	//
//	RegWrite	= RegWrite;	//
//	ALUOp		= ALUOp;		//