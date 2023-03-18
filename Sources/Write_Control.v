`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes a write register control RTL model 
// Date: November 13, 2022
//////////////////////////////////////////////////////////////////////////////////
module Write_Control (

	// Inputs
	input we,
	input [4:0]addr,

	// Outputs
	output reg [31:0]reg_en

);

// Parameters
localparam REG_ZERO =  5'd0;
localparam REG_AT =  5'd1;
localparam REG_V0 =  5'd2;
localparam REG_V1 =  5'd3;
localparam REG_A0 =  5'd4;
localparam REG_A1 =  5'd5;
localparam REG_A2 =  5'd6;
localparam REG_A3 =  5'd7;
localparam REG_T0 =  5'd8;
localparam REG_T1 =  5'd9;
localparam REG_T2 =  5'd10;
localparam REG_T3 =  5'd11;
localparam REG_T4 =  5'd12;
localparam REG_T5 =  5'd13;
localparam REG_T6 =  5'd14;
localparam REG_T7 =  5'd15;
localparam REG_S0 =  5'd16;
localparam REG_S1 =  5'd17;
localparam REG_S2 =  5'd18;
localparam REG_S3 =  5'd19;
localparam REG_S4 =  5'd20;
localparam REG_S5 =  5'd21;
localparam REG_S6 =  5'd22;
localparam REG_S7 =  5'd23;
localparam REG_T8 =  5'd24;
localparam REG_T9 =  5'd25;
localparam REG_K0 =  5'd26;
localparam REG_K1 =  5'd27;
localparam REG_GP =  5'd28;
localparam REG_SP =  5'd29;
localparam REG_FP =  5'd30;
localparam REG_RA =  5'd31;


always @ (we, addr) begin
	
	// Init output to zero to avoid latches
	reg_en = {32{1'b0}};
	
	case(addr)
	
		REG_ZERO: reg_en[0] = we;
		REG_AT: reg_en[1] = we;
		REG_V0: reg_en[2] = we;
		REG_V1: reg_en[3] = we;
		REG_A0: reg_en[4] = we;
		REG_A1: reg_en[5] = we;
		REG_A2: reg_en[6] = we;
		REG_A3: reg_en[7] = we;
		REG_T0: reg_en[8] = we;
		REG_T1: reg_en[9] = we;
		REG_T2: reg_en[10] = we;
		REG_T3: reg_en[11] = we;
		REG_T4: reg_en[12] = we;
		REG_T5: reg_en[13] = we;
		REG_T6: reg_en[14] = we;
		REG_T7: reg_en[15] = we;
		REG_S0: reg_en[16] = we;
		REG_S1: reg_en[17] = we;
		REG_S2: reg_en[18] = we;
		REG_S3: reg_en[19] = we;
		REG_S4: reg_en[20] = we;
		REG_S5: reg_en[21] = we;
		REG_S6: reg_en[22] = we;
		REG_S7: reg_en[23] = we;
		REG_T8: reg_en[24] = we;
		REG_T9: reg_en[25] = we;
		REG_K0: reg_en[26] = we;
		REG_K1: reg_en[27] = we;
		REG_GP: reg_en[28] = we;
		REG_SP: reg_en[29] = we;
		REG_FP: reg_en[30] = we;
		REG_RA: reg_en[31] = we;
		default:reg_en = {32{1'b0}};
	endcase

end

endmodule