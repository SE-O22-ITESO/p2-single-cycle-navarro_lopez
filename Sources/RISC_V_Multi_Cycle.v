`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes the top desing RTL model to implement the micro-architecture
//   for a 32bit Multicycle microprocessor to support executution for a RISC-V ISA
//   module RV32I Base Integer Instructions plus multiply instructions
// Date: February 22, 2023
//////////////////////////////////////////////////////////////////////////////////
module RISC_V_Multi_Cycle(

	// Inputs
	input clk,
//	input Ref_Clk,
	input rst,
	// GPIO
	input [9:0] GPIO_In,
	output [9:0] GPIO_Out,
	// UART
	output UART_Tx,
	input UART_Rx, 
	output UART_Tx_Fw,
	output UART_Rx_Fw,
	// Heard beat
	output Heard_beat
	
);

// ====================================================
// = Assignments            
// ====================================================
// Copy UART signals to other pins for debug purposes
assign UART_Tx_Fw = UART_Tx;
assign UART_Rx_Fw = UART_Rx;
assign GPIO_Out[9] = clk;
assign GPIO_Out[8] = 1'b0;

// ====================================================
// = Parameters            
// ====================================================
// System parameters
localparam ADDR_LENGTH		= 32;
localparam DATA_LENGTH		= 32;
localparam ADDR_PROGRAM_MIN	= 32'h 0040_0000;
// Data memory parameters
localparam DATA_FILE			= "..//Quartus_Project//Memory_Files//data.dat";
localparam DATA_DEPTH		=	16; // 2 data
// Instruction memory parameters
localparam INSTR_FILE		= "..//Quartus_Project//Memory_Files//gpio-copy-in2out.dat";
localparam INSTR_DEPTH		=	06;
//localparam INSTR_FILE		= "..//Quartus_Project//Memory_Files//lw-sw-example.dat";
//localparam INSTR_DEPTH		=	03;
//localparam INSTR_FILE		= "..//Quartus_Project//Memory_Files//instr.dat";
//localparam INSTR_DEPTH		=	13;

// ====================================================
// = PLL     
// ====================================================
// Wiring
//wire clk;		// Low freq desing clock
//wire clk_PLL;	// 1 MHz Clock from PLL
//
//PLL_Intel_FPGA_0002 PLL(
//	.refclk   (Ref_Clk),   //  refclk.clk
//	.rst      (~rst),      //   reset.reset
//	.outclk_0 (clk_PLL) // outclk0.clk
//	//.locked   (locked)    //  locked.export
//	
//);

// ====================================================
// = Heard beat
// ====================================================
// Heard beat to monitor system functionality. 
// Half second for a 50 MHz clock: 25'd25_000_000
// Half second for a 1 MHz clock: 20'd250_000
Heard_Bit #(.Half_Period_Counts(25'd25_000_000) ) Heard_monitor (
	//.clk				(clk_PLL), // Use this when clock from PLL
	.clk					(clk), // Use when clock is 50MHz
	.rst					(~rst),
	.enable				(1'b1),
	.heard_bit_out		(Heard_beat)
);

// ====================================================
// = Control Unit      
// ====================================================
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
// = RISC-V Modules   
// ====================================================
// Wiring
wire [DATA_LENGTH-1:0] pc_next;
wire [DATA_LENGTH-1:0] pc_curr;
wire [DATA_LENGTH-1:0] pc_old;
wire [DATA_LENGTH-1:0] mem_addr;
wire [DATA_LENGTH-1:0] mem_data;
wire [DATA_LENGTH-1:0] data;
wire [DATA_LENGTH-1:0] MMD_address_out;
wire [DATA_LENGTH-1:0] MMD_data_in_0;
wire [DATA_LENGTH-1:0] MMD_data_out_0;
wire MMD_select_0;
wire [DATA_LENGTH-1:0] MMD_data_in_1;
wire MMD_select_1;
wire [DATA_LENGTH-1:0] MMD_data_in_2;
wire [DATA_LENGTH-1:0] MMD_data_out_2;
wire MMD_select_2;
wire [DATA_LENGTH-1:0] MMD_data_in_3;
wire [DATA_LENGTH-1:0] MMD_data_out_3;
wire MMD_select_3;
wire MMD_write_3;

wire [DATA_LENGTH-1:0] a_reg_w;
wire [DATA_LENGTH-1:0] b_reg_w;
wire [DATA_LENGTH-1:0] alu_out;

// PC Register
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
// Addr Multiplexer
Mux_2_1_Param #(
	.DATA_LENGTH (DATA_LENGTH)
	)
	Addr_Mux(
	.a			(pc_curr), 		// 0: PC
	.b			(alu_out), 		// 1: ALUOut
	.sel		(CU_AddrSrc),
	.out		(mem_addr)
);
// ====================================================
// = Memory map decoder      
// ====================================================
Memory_Map_Decoder Mem_Map_Decoder(
	// UP Interface
	.MemRead		(CU_MemRead),		// Input data MemRead from uP Control Unit
	.MemWrite	(CU_MemWrite),		// Input data MemWrite from uP Control Unit
	.AddrIn		(mem_addr),			// Input data Addr from uP
	.DataIn		(b_reg_w),			// Input data BReg from uP	
	.DataOut		(mem_data),			// Output data Instr/Data to uP
	// Address out
	.AddrOut		(MMD_address_out),	// Output address to selected device
	// Data Memory interface	
	.DataIn0		(MMD_data_in_0),	// Input data Q from Data memory
	.DataOut0	(MMD_data_out_0),	// Ouput data to Data memory
	.Select0		(MMD_select_0),	// Output chip select to Data memory 
	// Instruction Memory interface
	.DataIn1		(MMD_data_in_1),	// Input data Q from Instruction memory
	.Select1		(MMD_select_1),	// Output chip select to Instruction memory 
	// GPIO interface
	.DataIn2		(MMD_data_in_2),	// Input data Q from GPIO
	.DataOut2	(MMD_data_out_2),	// Ouput data to GPIO
	.Select2		(MMD_select_2),		// Output chip select to GPIO
	// UART interface
	.DataIn3		(MMD_data_in_3),	// Input data from UART
	.DataOut3	(MMD_data_out_3),	// Ouput data to UART
	.Select3		(MMD_select_3),		// Output chip select to UART
	.Write3		(MMD_write_3)		// Output write to UART
);
// ====================================================
// = Data Memory          
// ====================================================
single_port_ram #(
	.DATA_WIDTH(DATA_LENGTH),
	.DATA_DEPTH(DATA_DEPTH),
	.DATA_PATH(DATA_FILE)
	)
	Data_Memory(
	//.data	(b_reg_w),
	//.addr	(mem_addr),
	//.we	(CU_MemWrite),
	//.q		(mem_data)
	.addr			(MMD_address_out),
	.q				(MMD_data_in_0),
	.data			(MMD_data_out_0),
	.we			(CU_MemWrite),
	.re			(CU_MemRead),
	.clk			(clk)
);
// ====================================================
// = Instruction Memory          
// ====================================================
single_port_ram #(
	.DATA_WIDTH(DATA_LENGTH),
	.DATA_DEPTH(INSTR_DEPTH),
	.DATA_PATH(INSTR_FILE)
	)
	Instr_Memory(
	.addr			(MMD_address_out),
	.q				(MMD_data_in_1),
	//.data	(MMD_data_out_1), Read-only memory
	.we			(1'b0),
	.re			(MMD_select_1),
	//.re			(CU_MemRead),
	.clk			(clk)
);

// ====================================================
// = GPIO Port          
// ====================================================
GPIO_Port GPIO_Port(
	.Address			(MMD_address_out),
	.DataIn			(MMD_data_out_2),
	.DataOut			(MMD_data_in_2),
	.Select			(MMD_select_2),
	.GPIO_In			(GPIO_In),
	.GPIO_Out		(GPIO_Out[7:0]),
	.clk				(clk),
	.rst				(~rst)
);

// ====================================================
// = UART Full Duplex Port        
// ====================================================
UART_Full_Duplex UART_Port(
	.Address			(MMD_address_out),
	.DataIn			(MMD_data_out_3),
	.DataOut			(MMD_data_in_3),
	.Select			(MMD_select_3),
	.Write			(MMD_write_3),
	.clk				(clk),
	.rst				(~rst),
	.tx				(UART_Tx),
	.rx				(UART_Rx)
);

// OldPC Register
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
// Instr Register
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
// Data Register
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

// Writeback Multiplexer
Mux_2_1_Param #(
	.DATA_LENGTH (DATA_LENGTH)
	)
	WritebackSrc_Mux(
	.a		(data),			// 0: DataReg
	.b		(alu_out), 		// 1: ALUOut
	.sel	(CU_WritebackSrc),
	.out	(wd3)
);

Register_File Reg_File(
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
// A Register
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
// B Register
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
wire [DATA_LENGTH-1:0] imm_ext;
// ALUSrcA Multiplexer
Mux_4_1_Param #(
	.DATA_LENGTH (DATA_LENGTH)
	)
	ALUSrcA_Mux(
	.a		(pc_curr),	// 0: PC
	.b		(pc_old), 	// 1: OldPC
	.c		(a_reg_w),	// 2: A Reg
	.d		(32'd0), 	// 3: 0
	.sel	(CU_ALUSrcA),
	.out	(src_a)
);
// ALUSrcB Multiplexer
Mux_4_1_Param #(
	.DATA_LENGTH (DATA_LENGTH)
	)	
	ALUSrcB_Mux(
	.a		(b_reg_w),		// 00: B Reg
	.b		(32'd4),			// 01: 4
	.c		(imm_ext),		// 10: ImmExt
	.d		(32'd0),			// 11: 0
	.sel	(CU_ALUSrcB),
	.out	(src_b)
);

// Immediate Generator
Immediate_Generator ImmGen(
	.Instr	(Instr),
	.ImmExt	(imm_ext)
);

// ALU
ALU_RISCV_Param #(
	.DATA_LENGTH	(DATA_LENGTH),
	.OUT_LENGTH		(DATA_LENGTH)
	) 
	ALU (
	.A				(src_a),
	.B				(src_b),
	.ALUOp		(CU_ALUOp),
	.ALUResult	(alu_result),
	.Comp			(CU_Comp)
);

// ALU Register
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

// PCSrc_Mux
Mux_2_1_Param #(
	.DATA_LENGTH (DATA_LENGTH)
	)
	PCSrc_Mux(
	.a		(alu_result),	// 0
	.b		(alu_out), 		// 1
	.sel	(CU_PCSrc),
	.out	(pc_next)
);


endmodule
