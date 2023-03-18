//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes an arithmetical logical unit (ALU) RTL model able to operate two 
//   inputs with 9 different functions, outputs are operation result and flags carry, 
//   overflow, negative and zero
// Date: March 5, 2023
//////////////////////////////////////////////////////////////////////////////////
module ALU_RISCV_Param #(
	
	// Parameters
	parameter DATA_LENGTH = 8,		// Input bus length
	parameter OUT_LENGTH = 8		// Output bus length
	
	) (
	
	// Inputs
	input signed 		[DATA_LENGTH-1:0] A, B, 	// Operands A and B
	input 		 		[3:0] ALUOp,			// ALU Operation control signal
	
	// Outputs
	output reg signed [OUT_LENGTH-1:0] ALUResult,	// Operation resutl
	output reg			[1:0] Comp				//Comparison flag
	//output reg 			Zero				// Operation flags

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
localparam ALU_MUL	= 4'd07; // ALUResult = (A * B) [31:0]
localparam ALU_DIV 	= 4'd08; // ALUResult = A / B
localparam ALU_NA		= 4'd15; // ALUResult = 0

localparam CMP_EQU	= 2'd0;	// Comp: A == B
localparam CMP_LST	= 2'd1;	// Comp: A < B
localparam CMP_GRT	= 2'd2;	// Comp: A > B
localparam CMP_NA		= 2'd3;	// Comp: 

always @ (A, B, ALUOp) begin


	case(ALUOp)
	
		ALU_ADD:	begin // Add
					ALUResult = A + B;
					end
					
		ALU_SUB:	begin // Subtract
					ALUResult = A - B;
					end
		
		ALU_XOR:	begin // Bitwise XOR
					ALUResult = A ^ B;
					end
					
		ALU_OR:	begin // Bitwise OR
					ALUResult = A | B;
					end
		
		ALU_AND:	begin // Bitwise AND
					ALUResult = A & B;
					end
					
		ALU_SLL:	begin	// Shift left logical
					ALUResult = A << B[5:0];
					end
					
		ALU_SRL:	begin	// Shift right logical
					ALUResult = A >> B[5:0];
					end
					
		ALU_MUL:	begin	// Multiplication
					ALUResult = (A * B);
					end
					
		ALU_DIV:	begin	// Divition
					ALUResult = (A / B);
					end
					
		ALU_NA:	begin	// No Operation
					ALUResult = {OUT_LENGTH{1'b0}};
					end
					
		default: begin
					ALUResult = {OUT_LENGTH{1'b0}};
					end
	
	endcase
	
	     if(A == B) Comp = CMP_EQU;
	else if(A <  B) Comp = CMP_LST;
	else if(A >  B) Comp = CMP_GRT;
	else				 Comp = CMP_NA;
	
end

endmodule

//
//localparam ALU_ADD	= 3'b010;
//localparam ALU_SUB	= 3'b110;
//localparam ALU_AND	= 3'b000;
//localparam ALU_OR		= 3'b001;
//localparam ALU_SLT	= 3'b111;
//localparam ALU_SLL	= 3'b011;

//		ALU_SLT:	begin // Set less than
//					ALUResult = (A < B)?1:0;
//					end

//	// Zero detect
//	Zero = ((ALUResult == {OUT_LENGTH{1'b0}}) == 1'b1);