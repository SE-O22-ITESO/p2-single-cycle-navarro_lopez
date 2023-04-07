`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes the top desing RTL model to implement the micro-architecture
//   for a 32bit Singlecycle microprocessor to support executution for a RISC-V ISA
//   module RV32I Base Integer Instructions plus multiply instructions
// Date: April 4, 2023
//////////////////////////////////////////////////////////////////////////////////
module RISC_V_Single_Cycle(

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
	// Displays
	output [13:0]Left_Disp,
	output [13:0]Middle_Disp,
	output [13:0]Right_Disp
	// Signal Tap CLK
	//output clk_PLL

);
// ====================================================
// = Assignments            
// ====================================================
// Copy UART signals to other pins for debug purposes
assign UART_Tx_Fw = UART_Tx;
assign UART_Rx_Fw = UART_Rx;
assign GPIO_Out[9] = clk;

// ====================================================
// = Parameters            
// ====================================================
// System parameters
localparam ADDR_LENGTH		= 32;
localparam DATA_LENGTH		= 32;
localparam ADDR_PROGRAM_MIN	= 32'h 0040_0000;
// Data memory parameters
localparam DATA_FILE			= "..//Quartus_Project//Memory_Files//data.dat";
localparam DATA_WIDTH		=	7;
// Instruction memory parameters
//localparam INSTR_FILE		= "..//Quartus_Project//Memory_Files//stack-pointer-lite.dat";
//localparam INSTR_DEPTH		=	15;
//localparam INSTR_FILE		= "..//Quartus_Project//Memory_Files//stack-pointer.dat";
//localparam INSTR_DEPTH		=	22;
//localparam INSTR_FILE		= "..//Quartus_Project//Memory_Files//jump-link-reg.dat";
//localparam INSTR_DEPTH		=	10;
localparam INSTR_FILE		= "..//Quartus_Project//Memory_Files//u-type.dat";
localparam INSTR_DEPTH		=	9;
//localparam INSTR_FILE		= "..//Quartus_Project//Memory_Files//r-i-type.dat";
//localparam INSTR_DEPTH		=	34;



// ====================================================
// = PLL     
// ====================================================
// Wiring
//wire clk;		// Low freq desing clock
//wire clk_PLL;	// 1 MHz Clock from PLL

//PLL_Intel_FPGA Signal_Tap_PLL(
//	//.refclk   (Ref_Clk),   //  refclk.clk
//	.refclk   (clk),   //  refclk.clk
//	.rst      (~rst),      //   reset.reset
//	.outclk_0 (clk_PLL) // outclk0.clk
//	//.locked   (locked)    //  locked.export
//	
//);

// ====================================================
// = Heard beat (System healt monitor)
// ====================================================
// Heard beat to monitor system functionality. 
// Half second for a 50 MHz clock: 25'd25_000_000
// Half second for a 1 MHz clock: 20'd250_000
Heard_Bit #(.Half_Period_Counts(25'd25_000_000) ) Heard_monitor (
	//.clk				(clk_PLL), // Use this when clock from PLL
	.clk					(clk), // Use when clock is 50MHz
	.rst					(~rst),
	.enable				(1'b1),
	.heard_bit_out		(GPIO_Out[8])
);


// ====================================================
// = Displays Decoders (Registers healt monitor)        
// ====================================================
// Wiring
wire [7:0] UART_Tx_Data_w;
wire [7:0] UART_Rx_Data_w;
wire [7:0] UART_Byte_Rate_w;
wire [7:0] Left_Disp_w;
wire [7:0] Middle_Disp_w;
wire [7:0] Right_Disp_w;

assign Left_Disp_w   = UART_Tx_Data_w;
assign Middle_Disp_w = UART_Rx_Data_w;
assign Right_Disp_w  = UART_Byte_Rate_w;

//assign Left_Disp_w   = (GPIO_In[8] == 1'b0)? UART_Tx_Data_w : 8'h00;
//assign Middle_Disp_w = (GPIO_In[8] == 1'b0)? UART_Rx_Data_w : GPIO_In[7:0];
//assign Right_Disp_w  = (GPIO_In[8] == 1'b0)? UART_Byte_Rate_w : GPIO_Out[7:0];

// Less significant nibble display (rigthmost) HEX4
Decoder_Bin_hex_7seg LSN_Left_Disp(
    .W				(Left_Disp_w[3]),
	 .X				(Left_Disp_w[2]),
	 .Y				(Left_Disp_w[1]),
	 .Z				(Left_Disp_w[0]),
	 .Seg_A			(Left_Disp[0]),
    .Seg_B			(Left_Disp[1]),
    .Seg_C			(Left_Disp[2]),
    .Seg_D			(Left_Disp[3]),
    .Seg_E			(Left_Disp[4]),
    .Seg_F			(Left_Disp[5]),
    .Seg_G			(Left_Disp[6])
);
// More significant nibble display (leftmost) HEX5
Decoder_Bin_hex_7seg MSN_Left_Disp(
    .W				(Left_Disp_w[7]),
	 .X				(Left_Disp_w[6]),
	 .Y				(Left_Disp_w[5]),
	 .Z				(Left_Disp_w[4]),
	 .Seg_A			(Left_Disp[7]),
    .Seg_B			(Left_Disp[8]),
    .Seg_C			(Left_Disp[9]),
    .Seg_D			(Left_Disp[10]),
    .Seg_E			(Left_Disp[11]),
    .Seg_F			(Left_Disp[12]),
    .Seg_G			(Left_Disp[13])
);

// Less significant nibble display (rigthmost) HEX2
Decoder_Bin_hex_7seg LSN_Middle_Disp(
    .W				(Middle_Disp_w[3]),
	 .X				(Middle_Disp_w[2]),
	 .Y				(Middle_Disp_w[1]),
	 .Z				(Middle_Disp_w[0]),
	 .Seg_A			(Middle_Disp[0]),
    .Seg_B			(Middle_Disp[1]),
    .Seg_C			(Middle_Disp[2]),
    .Seg_D			(Middle_Disp[3]),
    .Seg_E			(Middle_Disp[4]),
    .Seg_F			(Middle_Disp[5]),
    .Seg_G			(Middle_Disp[6])
);
// More significant nibble display (leftmost) HEX3
Decoder_Bin_hex_7seg MSN_Middle_Disp(
    .W				(Middle_Disp_w[7]),
	 .X				(Middle_Disp_w[6]),
	 .Y				(Middle_Disp_w[5]),
	 .Z				(Middle_Disp_w[4]),
	 .Seg_A			(Middle_Disp[7]),
    .Seg_B			(Middle_Disp[8]),
    .Seg_C			(Middle_Disp[9]),
    .Seg_D			(Middle_Disp[10]),
    .Seg_E			(Middle_Disp[11]),
    .Seg_F			(Middle_Disp[12]),
    .Seg_G			(Middle_Disp[13])
);

// Less significant nibble display (rigthmost) HEX0
Decoder_Bin_hex_7seg LSN_Right_Disp(
    .W				(Right_Disp_w[3]),
	 .X				(Right_Disp_w[2]),
	 .Y				(Right_Disp_w[1]),
	 .Z				(Right_Disp_w[0]),
	 .Seg_A			(Right_Disp[0]),
    .Seg_B			(Right_Disp[1]),
    .Seg_C			(Right_Disp[2]),
    .Seg_D			(Right_Disp[3]),
    .Seg_E			(Right_Disp[4]),
    .Seg_F			(Right_Disp[5]),
    .Seg_G			(Right_Disp[6])
);
// More significant nibble display (leftmost) HEX1
Decoder_Bin_hex_7seg MSN_Right_Disp(
    .W				(Right_Disp_w[7]),
	 .X				(Right_Disp_w[6]),
	 .Y				(Right_Disp_w[5]),
	 .Z				(Right_Disp_w[4]),
	 .Seg_A			(Right_Disp[7]),
    .Seg_B			(Right_Disp[8]),
    .Seg_C			(Right_Disp[9]),
    .Seg_D			(Right_Disp[10]),
    .Seg_E			(Right_Disp[11]),
    .Seg_F			(Right_Disp[12]),
    .Seg_G			(Right_Disp[13])
);


// ====================================================
// = RISC-V Modules   
// ====================================================
// ====================================================
// = Control Unit      
// ====================================================
//wire CU_PCWrite;
//wire CU_AddrSrc;
wire CU_MemRead;
wire CU_MemWrite;
wire [2:0]CU_WritebackSrc;
wire CU_IRWrite;
wire [1:0] CU_PCSrc;
wire [3:0] CU_ALUOp;
//wire [1:0] CU_ALUSrcA;
wire [1:0] CU_ALUSrcB;
wire CU_RegWrite;
wire [1:0] CU_Comp;
wire [DATA_LENGTH-1:0] Instr;

Control_Unit_Singlecycle Control_Unit(
	.MemRead			(CU_MemRead),
	.MemWrite		(CU_MemWrite),
	.Comp				(CU_Comp),
	.ALUOp			(CU_ALUOp),
	.PCSrc			(CU_PCSrc),
	.ALUSrcB			(CU_ALUSrcB),
	.RegWrite		(CU_RegWrite),
	.WritebackSrc	(CU_WritebackSrc),
	
	.Opcode			(Instr[06:00]),
	.Funct7			(Instr[31:25]),
	.Funct3			(Instr[14:12]),

	.clk				(clk),
	.rst				(~rst)
);

// Wiring
wire [DATA_LENGTH-1:0] PC_Next;
wire [DATA_LENGTH-1:0] PC;

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

wire [DATA_LENGTH-1:0] MemData;
wire [DATA_LENGTH-1:0] ALUResult;
wire [DATA_LENGTH-1:0] a_reg_w;
wire [DATA_LENGTH-1:0] b_reg_w;
wire [DATA_LENGTH-1:0] alu_out;
wire [DATA_LENGTH-1:0] rd2;
wire [DATA_LENGTH-1:0] PC_4;
wire [DATA_LENGTH-1:0] PC_Imm;
wire [DATA_LENGTH-1:0] RS1_Imm;
wire [DATA_LENGTH-1:0] Imm_Ext;


// PC Register
Register_Param #(
	.LENGTH	(DATA_LENGTH),
	.RST_VAL (ADDR_PROGRAM_MIN)
	)
	PC_Reg(
	.d			(PC_Next),
	.rst		(~rst),
	.clk		(clk),
	.en		(1'b1),
	.q			(PC)
	
);

// ====================================================
// = Memory map decoder      
// ====================================================

Memory_Map_Decoder_Singlecycle MMD (
	// uP Interface
	.MemRead 		(CU_MemRead),
	.MemWrite		(CU_MemWrite),
	.Addr0			(ALUResult),
	.DataIn			(rd2),
	.Data0			(MemData),
	.Addr1			(PC),
	.Data1			(Instr),
	// Address out
	.AddrOut			(MMD_address_out),
	// Device 0: Data Memory interface
	.DataIn0			(MMD_data_in_0),
	.DataOut0		(MMD_data_out_0),
	.Select0			(MMD_select_0),
	// Device 1: Instruction Memory interface
	.DataIn1			(MMD_data_in_1),
	.Select1			(MMD_select_1),
	// Device 2: GPIO interface
	.DataIn2			(MMD_data_in_2),
	.DataOut2		(MMD_data_out_2),
	.Select2			(MMD_select_2),
	// Device 3: UART interface
	.DataIn3			(MMD_data_in_3),
	.DataOut3		(MMD_data_out_3),
	.Select3			(MMD_select_3),
	.Write3			(MMD_write_3),
	
	.clk				(clk)
	
);


// ====================================================
// = Data Memory          
// ====================================================
single_port_ram #(
	.DATA_WIDTH(DATA_LENGTH),
	.DATA_DEPTH(DATA_WIDTH),
	//.DATA_DEPTH(DATA_DEPTH),
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
single_port_rom #(
	.DATA_WIDTH(DATA_LENGTH),
	.DATA_DEPTH(INSTR_DEPTH),
	.DATA_PATH(INSTR_FILE)
	)
	Instr_Memory(
	.addr			(MMD_address_out),
	.q				(MMD_data_in_1),
	//.data		(), Read-only memory
	.we			(1'b0),
	.re			(1'b1), // Read always
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
	.rx				(UART_Rx),
	.tx_data			(UART_Tx_Data_w),
	.rx_data			(UART_Rx_Data_w),
	.byte_rate		(UART_Byte_Rate_w)
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
//wire	[DATA_LENGTH-1:0] rd2;
wire	[DATA_LENGTH-1:0] a_w;
wire	[DATA_LENGTH-1:0] b_w;

assign a1	= Instr[19:15]; // RS1 Address
assign a2 	= Instr[24:20]; // RS2 Address
assign a3	= Instr[11:07]; // RD  Address
assign we3	= CU_RegWrite;

//Mux_2_1_Param #(
//	.DATA_LENGTH (DATA_LENGTH)
//	)
//	WritebackSrc_Mux(
//	.a		(MemData),		// 0: MemData
//	.b		(ALUResult), 	// 1: ALUResult
//	.sel	(CU_WritebackSrc),
//	.out	(wd3)
//);
// Writeback source multiplexor
Mux_8_1_Param #(
	.DATA_LENGTH (DATA_LENGTH)
	)
	WritebackSrc_Mux(
	.a		(MemData),		// 0: MemData
	.b		(ALUResult), 	// 1: ALUResult
	.c		(PC_4),			// 2: PC+4
	.d		(Imm_Ext),		// 3: Imm
	.e		(PC_Imm),		// 4: PC+Imm
	.f		(32'b0),			// 5: 0
	.g		(32'b0),			// 6: 0
	.h		(32'b0),			// 7: 0
	.sel	(CU_WritebackSrc),
	.out	(wd3)
);

// Register File
Register_File Reg_File(
	.a1	(a1),		// RAddr1
	.a2	(a2),		// RAddr2
	.a3	(a3),		// WAddr
	.wd3	(wd3),	// WData
	.we3	(we3),	// WE
	.clk	(clk),	//
	.rst	(~rst),
	.rd1	(rd1),	// RD1
	.rd2	(rd2)		//	RD2
	
);



// ====================================================
// = ALU         
// ====================================================
// Wiring
//wire [DATA_LENGTH-1:0] ALUsrc_a;
wire [DATA_LENGTH-1:0] ALUsrc_b;
//wire [DATA_LENGTH-1:0] ALUResult;
//wire [DATA_LENGTH-1:0] Imm_Ext;

// ALUSrcB Multiplexer
Mux_4_1_Param #(
	.DATA_LENGTH (DATA_LENGTH)
	)	
	ALUSrcB_Mux(
	.a		(rd2),			// 00: RS2
	.b		(Imm_Ext),		// 01: ImmExt
	.c		(32'd4),			// 10: 4
	.d		(32'd0),			// 11: 0
	.sel	(CU_ALUSrcB),
	.out	(ALUsrc_b)
);

// Immediate Generator
Immediate_Generator Imm_Gen(
	.Instr	(Instr),
	.ImmExt	(Imm_Ext)
);

// ALU
ALU_RISCV_Param #(
	.DATA_LENGTH	(DATA_LENGTH),
	.OUT_LENGTH		(DATA_LENGTH)
	) 
	ALU (
	.A				(rd1),		// A Src
	.B				(ALUsrc_b),	// B Src
	.ALUOp		(CU_ALUOp),	// AluOp
	.ALUResult	(ALUResult),// Result
	.Comp			(CU_Comp)	// Comp flag
);


// ====================================================
// = PC Next         
// ====================================================
assign PC_4 = PC + 3'd4;
assign PC_Imm = PC + Imm_Ext;
assign RS1_Imm = rd1 + Imm_Ext;

// PC Source Multiplexor
Mux_4_1_Param #(
	.DATA_LENGTH (DATA_LENGTH)
	)
	PCSrc_Mux(
	.a		(PC_4),		// 00: PC+4
	.b		(PC_Imm), 	// 01: PC+Imm
	.c		(RS1_Imm),	// 10: RS1+Imm
	.d		(PC),			// 11: PC
	
	.sel	(CU_PCSrc),
	.out	(PC_Next)
);



endmodule

// Exprerimental

//// ALUSrcA Multiplexer
//Mux_4_1_Param #(
//	.DATA_LENGTH (DATA_LENGTH)
//	)
//	ALUSrcA_Mux(
//	.a		(PC),			// 0: PC
//	.b		(pc_old), 	// 1: OldPC
//	.c		(a_reg_w),	// 2: A Reg
//	.d		(32'd0), 	// 3: 0
//	.sel	(CU_ALUSrcA),
//	.out	(src_a)
//);

	//.PCWrite			(CU_PCWrite),
	//.AddrSrc			(CU_AddrSrc),
	//.IRWrite			(CU_IRWrite),	
	//.ALUSrcA			(CU_ALUSrcA),