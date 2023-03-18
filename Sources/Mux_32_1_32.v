`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes a Multiplexer 32 inputs 1 output 32 bit length RTL model 
// Date: November 13, 2022
//////////////////////////////////////////////////////////////////////////////////
module Mux_32_1_32 
(

// Inputs
	
	input [1023:0]in,
	input [4:0]addr,

// Outputs
	output reg [31:0]out

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



always @(in, addr) begin

	// Init output to zero to avoid latches
	out = {32{1'b0}};

	case(addr)
		REG_ZERO: out = in[31:0];
		REG_AT: out = in[63:32];
		REG_V0: out = in[95:64];
		REG_V1: out = in[127:96];
		REG_A0: out = in[159:128];
		REG_A1: out = in[191:160];
		REG_A2: out = in[223:192];
		REG_A3: out = in[255:224];
		REG_T0: out = in[287:256];
		REG_T1: out = in[319:288];
		REG_T2: out = in[351:320];
		REG_T3: out = in[383:352];
		REG_T4: out = in[415:384];
		REG_T5: out = in[447:416];
		REG_T6: out = in[479:448];
		REG_T7: out = in[511:480];
		REG_S0: out = in[543:512];
		REG_S1: out = in[575:544];
		REG_S2: out = in[607:576];
		REG_S3: out = in[639:608];
		REG_S4: out = in[671:640];
		REG_S5: out = in[703:672];
		REG_S6: out = in[735:704];
		REG_S7: out = in[767:736];
		REG_T8: out = in[799:768];
		REG_T9: out = in[831:800];
		REG_K0: out = in[863:832];
		REG_K1: out = in[895:864];
		REG_GP: out = in[927:896];
		REG_SP: out = in[959:928];
		REG_FP: out = in[991:960];
		REG_RA: out = in[1023:992];
		default: out = {32{1'b0}};
	endcase

end

endmodule
