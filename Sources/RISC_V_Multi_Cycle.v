`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes the top desing RTL model to implement the micro-architecture
//   for a 32bit Multi-cycle microprocessor (MIPs) to support executution for a RISC-V ISA
//   module RV32I Base Integer Instructions plus multiply instructions
// Date: February 22, 2023
//////////////////////////////////////////////////////////////////////////////////
module RISC_V_Multi_Cycle(

	// Inputs
//	input clk,
	input Ref_Clk,
	input rst,
	input [9:0] GPIO_Port_In,
	// Outputs
	output [9:0] GPIO_Port_Out
	
);

// ====================================================
// = Parameters            
// ====================================================
localparam ADDR_LENGTH		= 32;
localparam DATA_LENGTH		= 32;

localparam DATA_FILE			= "..//Quartus_Project//Memory_Files//data.dat";
localparam DATA_DEPTH		=	02; // 2 data

localparam INSTR_FILE		= "..//Quartus_Project//Memory_Files//instr.dat";
localparam INSTR_DEPTH		=	13; // 12 instructions

localparam ADDR_PROGRAM_MIN	= 32'h 0040_0000;
// ====================================================
// = PLL     
// ====================================================
// Wiring
wire clk;		// Low freq desing clock
wire clk_PLL;	// 1 MHz Clock from PLL

PLL_Intel_FPGA_0002 PLL(
	.refclk   (Ref_Clk),   //  refclk.clk
	.rst      (~rst),      //   reset.reset
	.outclk_0 (clk_PLL) // outclk0.clk
	//.locked   (locked)    //  locked.export
	
);

// ====================================================
// = Heard beat.       
// ====================================================
//Half second for a clk of 50 MHz 
//Heard_Bit #(.Half_Period_Counts(25'd25_000_000) ) PLL_clk (
Heard_Bit #(.Half_Period_Counts(20'd250_000) ) Div_PLL_clk (
	.clk					(clk_PLL),
	.rst					(~rst),
	.enable				(1'b1),
	.heard_bit_out		(clk)

);

assign GPIO_Port_Out[9] = clk;
assign GPIO_Port_Out[8] = 1'b0;


// ====================================================
// = Control Unit      
// ====================================================
// Wiring
//wire CU_reg_dst; MIPs
//wire CU_PCWrite_cond;
//wire CU_mem_to_reg;
//wire [2:0] CU_alu_control;
//wire [1:0] CU_ALUOp; CU internal signal
wire CU_PCWrite;
wire CU_AddrSrc;
wire CU_MemRead;
wire CU_MemWrite;
wire CU_WritebackSrc;
wire CU_IRWrite;

wire CU_PCSrc;
wire [3:0] CU_ALUOp;
wire [1:0] CU_ALUSrcA;
wire [1:0] CU_ALUSrcB;
wire CU_RegWrite;
wire [1:0] CU_Comp;


wire [DATA_LENGTH-1:0] Instr;

Control_Unit Control_Unit(
	//.Opcode		(Instr[31:26]), MIPs
	//.Funct		(Instr[05:00]), MIPs
	//.RegDst		(CU_reg_dst),
	//.Branch	(CU_branch), // Unused
	//.PCWriteCond(CU_PCWrite_cond),
	//.ALUOp		(CU_ALUOp), CU internal signal
	//.IRWrite		(CU_IRWrite),
	//.ALUControl		(CU_alu_control),
	
	.PCWrite			(CU_PCWrite),
	.AddrSrc			(CU_AddrSrc),	
	.MemRead			(CU_MemRead),
	.MemWrite		(CU_MemWrite),
	.WritebackSrc	(CU_WritebackSrc),
	.IRWrite			(CU_IRWrite),
	
	.Opcode			(Instr[06:00]),
	.Funct7			(Instr[31:25]),
	.Funct3			(Instr[14:12]),
	
	.PCSrc			(CU_PCSrc),
	.ALUOp			(CU_ALUOp),
	.ALUSrcA			(CU_ALUSrcA),
	.ALUSrcB			(CU_ALUSrcB),
	.RegWrite		(CU_RegWrite),
	.Comp				(CU_Comp),
		
	.clk				(clk),
	.rst				(~rst)
);



// ====================================================
// = Memory map decoder    
// ====================================================
// Wiring
wire [DATA_LENGTH-1:0] pc_next;
wire [DATA_LENGTH-1:0] pc_curr;
wire [DATA_LENGTH-1:0] pc_old;
wire [DATA_LENGTH-1:0] mem_addr;
wire [DATA_LENGTH-1:0] mem_data;
wire [DATA_LENGTH-1:0] data;
wire [DATA_LENGTH-1:0] mmd_address_out;
wire [DATA_LENGTH-1:0] mmd_data_in_0;
wire [DATA_LENGTH-1:0] mmd_data_out_0;
wire mmd_select_0;
wire [DATA_LENGTH-1:0] mmd_data_in_1;
wire mmd_select_1;
wire [DATA_LENGTH-1:0] mmd_data_in_2;
wire [DATA_LENGTH-1:0] mmd_data_out_2;
wire mmd_select_2;

wire [DATA_LENGTH-1:0] a_reg_w;
wire [DATA_LENGTH-1:0] b_reg_w;
wire [DATA_LENGTH-1:0] alu_out;
//wire pc_reg_en;
//wire pc_and_out;
//and (pc_and_out, alu_zero, CU_PCWrite_cond);
//or (pc_reg_en, CU_PCWrite, pc_and_out);

Register_Param #(
	.LENGTH	(DATA_LENGTH),
	.RST_VAL (ADDR_PROGRAM_MIN)
	)
	PC_Reg(
	.d			(pc_next),
	.rst		(~rst),
	.clk		(clk),
	.en		(CU_PCWrite),
	.q			(pc_curr)
	
);

Mux_2_1_Param #(
	.DATA_LENGTH (DATA_LENGTH)
	)
	Addr_Mux1(
	.a		(pc_curr), // 0
	.b		(alu_out), // 1
	.sel	(CU_AddrSrc),
	.out	(mem_addr)
);

Memory_Map_Decoder Mem_Map_Decoder(
	// UP Interface
	.MemRead		(CU_MemRead),		// Input data MemRead from uP Control Unit
	.MemWrite	(CU_MemWrite),	// Input data MemWrite from uP Control Unit
	.AddrIn		(mem_addr),			// Input data Addr from uP
	.DataIn		(b_reg_w),			// Input data BReg from uP	
	.DataOut		(mem_data),			// Output data Instr/Data to uP
	
	// Address out
	.AddrOut		(mmd_address_out),	// Output address to selected device
	
	// Data Memory interface	
	.DataIn0		(mmd_data_in_0),	// Input data Q from Data memory
	.DataOut0	(mmd_data_out_0),	// Ouput data to Data memory
	.Select0		(mmd_select_0),	// Output chip select to Data memory 
	
	// Instruction Memory interface
	.DataIn1		(mmd_data_in_1),	// Input data Q from Instruction memory
	.Select1		(mmd_select_1),	// Output chip select to Instruction memory 
	
	// GPIO interface
	.DataIn2		(mmd_data_in_2),	// Input data Q from GPIO
	.DataOut2	(mmd_data_out_2),	// Ouput data to GPIO
	.Select2		(mmd_select_2)		// Output chip select to GPIO
);
// Wiring
//wire dm_we;
//wire dm_re;
//
//and(dm_we, mmd_select_0,CU_MemWrite);
//and(dm_re, mmd_select_0,CU_MemRead);

single_port_ram #(
	.DATA_WIDTH(DATA_LENGTH),
	.DATA_DEPTH(DATA_DEPTH),
	.DATA_PATH(DATA_FILE)
	)
	//Inst_Data_Memory(
	Data_Memory(
	//.data	(b_reg_w),
	//.addr	(mem_addr),
	//.we	(CU_MemWrite),
	//.q		(mem_data)
	.addr	(mmd_address_out),
	.q		(mmd_data_in_0),
	.data	(mmd_data_out_0),
	.we	(CU_MemWrite),
	.re	(CU_MemRead),
	.clk	(clk)
);
//wire im_re;
//and(im_re, mmd_select_1,CU_MemRead);
single_port_ram #(
	.DATA_WIDTH(DATA_LENGTH),
	.DATA_DEPTH(INSTR_DEPTH),
	.DATA_PATH(INSTR_FILE)
	)
	Instr_Memory(
	.addr	(mmd_address_out),
	.q		(mmd_data_in_1),
	//.data	(mmd_data_out_1), Read-only memory
	.we	(1'b0),
	.re	(mmd_select_1),
	//.re	(CU_MemRead),
	.clk	(clk)
);

GPIO_Port GPIO_Port(
	.Address				(mmd_address_out),
	.DataIn				(mmd_data_out_2),
	.DataOut				(mmd_data_in_2),
	.Select				(mmd_select_2),
	.GPIO_Port_In		(GPIO_Port_In),
	.GPIO_Port_Out		(GPIO_Port_Out[7:0]),
	.clk					(clk),
	.rst					(~rst)
);


Register_Param #(
	.LENGTH	(DATA_LENGTH)
	)
	OldPC_Reg(
	.d			(pc_curr),
	.rst		(~rst),
	.clk		(clk),
	.en		(CU_IRWrite),
	.q			(pc_old)
);

Register_Param #(
	.LENGTH	(DATA_LENGTH)
	)
	Instr_Reg(
	.d			(mem_data),
	.rst		(~rst),
	.clk		(clk),
	.en		(CU_IRWrite),
	.q			(Instr)
);

Register_Param #(
	.LENGTH	(DATA_LENGTH)
	)
	Data_Reg(
	.d			(mem_data),
	.rst		(~rst),
	.clk		(clk),
	.en		(1'b1),
	.q			(data)
);

// ====================================================
// = Register File           
// ====================================================
// Wiring
wire	[4:0] a1;
wire	[4:0] a2;
wire	[4:0] a3;
wire	[DATA_LENGTH-1:0] wd3;
wire we3;
wire	[DATA_LENGTH-1:0] rd1;
wire	[DATA_LENGTH-1:0] rd2;
wire	[DATA_LENGTH-1:0] a_w;
wire	[DATA_LENGTH-1:0] b_w;

assign a1	= Instr[19:15]; // RS1
assign a2 	= Instr[24:20]; // RS2
assign a3	= Instr[11:07]; // RD
assign we3	= CU_RegWrite;

//wire [4:0] RegDst_a;
//wire [4:0] RegDst_b;
//assign RegDst_a = Instr[20:16];
//assign RegDst_b = Instr[15:11];

//Mux_2_1_Param #(       MIPs
//	.DATA_LENGTH (5)
//	//.DATA_LENGTH (DATA_LENGTH)
//	)
//	RegDst_Mux(
//	.a		(RegDst_a), // 0
//	.b		(RegDst_b), // 1
//	.sel	(CU_reg_dst),
//	.out	(a3)
//);

Mux_2_1_Param #(
	.DATA_LENGTH (DATA_LENGTH)
	)
	WritebackSrc_Mux(
	.a		(data),			// 0: DataReg
	.b		(alu_out), 		// 1: ALUOut
	.sel	(CU_WritebackSrc),
	.out	(wd3)
);

Register_File Register_File(
	.a1	(a1),
	.a2	(a2),
	.a3	(a3),
	.wd3	(wd3),
	.we3	(we3),
	.clk	(clk),
	.rst	(~rst),
	.rd1	(rd1),
	.rd2	(rd2)
	
);

Register_Param #(
	.LENGTH	(DATA_LENGTH)
	)
	A_Reg(
	.d			(rd1),
	.rst		(~rst),
	.clk		(clk),
	.en		(1'b1),
	.q			(a_reg_w)
);

Register_Param #(
	.LENGTH	(DATA_LENGTH)
	)
	B_Reg(
	.d			(rd2),
	.rst		(~rst),
	.clk		(clk),
	.en		(1'b1),
	.q			(b_reg_w)
);


// ====================================================
// = ALU         
// ====================================================
// Wiring
wire [DATA_LENGTH-1:0] src_a;
wire [DATA_LENGTH-1:0] src_b;
wire [DATA_LENGTH-1:0] alu_result;
//wire [15:0] sign_imm_sh; // No used
//wire [15:0] sign_imm;
//wire [DATA_LENGTH-1:0] sign_imm;
wire [DATA_LENGTH-1:0] imm_ext;
//wire alu_zero;
//wire [1:0]alu_comp;

Mux_4_1_Param #(
	.DATA_LENGTH (DATA_LENGTH)

)	ALU_src_A_Mux(
	.a		(pc_curr),	// 0: PC
	.b		(pc_old), 	// 1: OldPC
	.c		(a_reg_w),	// 2: A Reg
	.d		(32'd0), 	// 3: 0
	.sel	(CU_ALUSrcA),
	.out	(src_a)
);

Mux_4_1_Param #(
	.DATA_LENGTH (DATA_LENGTH)

)	ALU_src_B_Mux(
	.a		(b_reg_w),		// 00
	.b		(32'd4),			// 01
	.c		(imm_ext),		// 10
	.d		(32'd0),			// 11
	.sel	(CU_ALUSrcB),
	.out	(src_b)
);


Immediate_Generator ImmGen(
	.Instr	(Instr),
	.ImmExt	(imm_ext)
);

ALU_RISCV_Param #(
	.DATA_LENGTH	(DATA_LENGTH),
	.OUT_LENGTH		(DATA_LENGTH)

) ALU (
	.A				(src_a),
	.B				(src_b),
	.ALUOp		(CU_ALUOp),
	.ALUResult	(alu_result),
	.Comp			(CU_Comp)
);


Register_Param #(
	.LENGTH	(DATA_LENGTH)
	)
	ALU_Reg(
	.d			(alu_result),
	.rst		(~rst),
	.clk		(clk),
	.en		(1'b1),
	.q			(alu_out)
	
);

Mux_2_1_Param #(
	.DATA_LENGTH (DATA_LENGTH)

)	PC_src_Mux(
	.a		(alu_result),	// 0
	.b		(alu_out), 		// 1
	.sel	(CU_PCSrc),
	.out	(pc_next)
);



endmodule