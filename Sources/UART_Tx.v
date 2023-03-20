`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes a structural RTL model to instantiate all modules
//   for UART TX module
// Date: October 24, 2022
//////////////////////////////////////////////////////////////////////////////////
module UART_Tx (

	// Inputs
	input 			clk,
	input 			rst,
	input 			tx_send,
	input	[7:0]		tx_data,
	input [31:0]	byte_rate,
	
	// Outputs
	output			tx,
	output			tx_sent
	
);

// ====================================================
// = Parameters         
// ====================================================

localparam DATA_BITS_LENGTH			= 4;// This param issues an error, it is expected


// Wiring
wire end_bit_time_w;
wire [DATA_BITS_LENGTH-1:0] tx_count_bits_w;
wire tx_cntr_en_w /*, tx_cntr_rst_w*/;
wire bit_tmr_en_w /*, bit_tmr_rst_w*/;
wire [31:0] count;
//wire [BIT_RATE_LENGTH-1:0] count;

// Baud bit rate generator
Counter_2_Limit_w_ovf Bit_Rate (
	.limit		(byte_rate),
	.rst			(~bit_tmr_en_w),
	.enable		(bit_tmr_en_w),
	.clk			(clk),
	.Q				(count),
	.overflow	(end_bit_time_w)
);

// Cou
Counter_Param #(.n(DATA_BITS_LENGTH)) tx_bits_counter (

	.clk					(clk),
	.rst					(~tx_cntr_en_w),
	.enable				(tx_cntr_en_w & end_bit_time_w),
	.Q						(tx_count_bits_w)
	
);


// Wiring
wire [2:0] tx_state_w;
wire tx_parity_w;

assign tx_parity_w = ^ tx_data;


TX_Data_Mux tx_data_mux_module(
	
	.tx_state		(tx_state_w),
	.tx_data			(tx_data),
	.tx_data_index	(tx_count_bits_w),
	.tx_parity		(tx_parity_w),
	.end_bit_time	(end_bit_time_w),
	.clk				(clk),
	.rst				(rst),
	
	.tx				(tx)
	
);

// FSM
FSM_UART_Tx FSM_Tx (
	
	.clk					(clk),
	.rst					(rst),
	.tx_send				(tx_send),
	.end_bit_time		(end_bit_time_w),
	.tx_bit_count		(tx_count_bits_w),
	
	.tx_state_out		(tx_state_w),
	.tx_cntr_en			(tx_cntr_en_w),
	.bit_tmr_en			(bit_tmr_en_w),
	.tx_sent				(tx_sent)
);


endmodule
