// ====================================================
// = Control Unit      
// ====================================================
// Wiring
//wire CU_reg_dst; MIPs
//wire CU_PCWrite_cond;
//wire CU_mem_to_reg;
//wire [2:0] CU_alu_control;
//wire [1:0] CU_ALUOp; CU internal signal

Control_Unit Control_Unit(
	//.Opcode		(Instr[31:26]), MIPs
	//.Funct		(Instr[05:00]), MIPs
	//.RegDst		(CU_reg_dst),
	//.Branch	(CU_branch), // Unused
	//.PCWriteCond(CU_PCWrite_cond),
	//.ALUOp		(CU_ALUOp), CU internal signal
	//.IRWrite		(CU_IRWrite),
	//.ALUControl		(CU_alu_control),
	
Control_Unit Control_Unit(
	//.Opcode		(Instr[31:26]), MIPs
	//.Funct		(Instr[05:00]), MIPs
	//.RegDst		(CU_reg_dst),
	//.Branch	(CU_branch), // Unused
	//.PCWriteCond(CU_PCWrite_cond),
	//.ALUOp		(CU_ALUOp), CU internal signal
	//.IRWrite		(CU_IRWrite),
	//.ALUControl		(CU_alu_control),
	);
	
// ====================================================
// = RISC-V Modules   
// ====================================================
//wire pc_reg_en;
//wire pc_and_out;
//and (pc_and_out, alu_zero, CU_PCWrite_cond);
//or (pc_reg_en, CU_PCWrite, pc_and_out);


// ====================================================
// = Data Memory          
// ====================================================
// Wiring
//wire dm_we;
//wire dm_re;
//
//and(dm_we, mmd_select_0,CU_MemWrite);
//and(dm_re, mmd_select_0,CU_MemRead);

// ====================================================
// = Instruction Memory          
// ====================================================
//wire im_re;
//and(im_re, mmd_select_1,CU_MemRead);

// ====================================================
// = UART Full Duplex Port        
// ====================================================
// Wiring
//wire [DATA_BITS-1:0] rx_data_w;
//wire [7:0] tx_data /*synthesis keep*/;
UART_Half_Tx UART_Tx_Module(
	.Address				(mmd_address_out),
	.DataIn				(mmd_data_out_3),
	.DataOut				(mmd_data_in_3),
	.Select				(mmd_select_3),
	
	//.tx_data			(tx_data),
	//.tx_send			(cu_tx_send),
	//.baud_rate		(921_600), // Fast baud rate
	//.clk_freq		(50_000_000), //Clock Freq Hz
	//.clk_freq		(100_000_000), //Clock Freq Hz
	.clk				(clk),
	.rst				(~rst),
	.tx				(tx),
	.rx				(rx)
	//.tx_sent			(cu_tx_sent)
);
// ====================================================
// = Register File           
// ====================================================
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
// ====================================================
// = ALU         
// ====================================================
//wire [15:0] sign_imm_sh; // No used
//wire [15:0] sign_imm;
//wire [DATA_LENGTH-1:0] sign_imm;
//wire alu_zero;
//wire [1:0]alu_comp;

