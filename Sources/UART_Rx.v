`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Cuauhtemoc Aguilera
// Module Description:
//   This module describes a structural RTL model to instantiate all modules
//   for UART RX module
// Date: October 24, 2022
//////////////////////////////////////////////////////////////////////////////////
module UART_Rx (

	// Inputs
	input 			clk,
	//input 			n_rst,
	input 			rst,
	input				rx_flag_clr,
	input 			rx,
	input [31:0]	byte_rate,
	
	//Outputs
	output 			parity,
	output			rx_flag,
	output 	[8:0]	Rx_SR
	
);
	

// Wiring
wire /*rst,*/ rst_sr_w, rst_bit_counter_w, rst_BR_w;
wire sample_bit_w;
wire end_bit_time_w, end_half_time_w;
wire bit_count_enable_w, enable_out_reg_w;
wire [3:0] count_bits_w;
wire [8:0] Q_SR_w1, Q_SR_w2 /*synthesis keep*/;


//assign rst = ~n_rst;
assign rst_sr_w = rst;
assign Rx_SR = Q_SR_w2;
//assign 

Shift_Register_R_Param #(.width(4'd9)) shift_reg (

	.clk					(clk),
	.rst					(rst_sr_w),
	.enable				(sample_bit_w),
	.d						(rx),
	.Q						(Q_SR_w1)
);

Reg_Param #(.width(4'd9)) rx_ff (

	.clk					(clk),
	.rst					(rst),
	.enable				(enable_out_reg_w),
	.D						(Q_SR_w1),
	.Q						(Q_SR_w2)
				 
);

FF_D_enable rx_flag_ff (

	.clk					(clk),
	.rst					(rx_flag_clr | rst),
	.enable				(enable_out_reg_w),
	.d						(1'b1),
	.q						(rx_flag)
				 
);

FF_D_enable ff_par (

	.clk					(clk),
	.rst					(rst_sr_w),
	.enable				(enable_out_reg_w),
	.d						(Q_SR_w1[4'd8]),
	.q						(parity)
				 
);


// For a baud rate of 9600 baudios: bit time 104.2 us, half time 52.1 us
// For a clock frequency of 50 MHz bit time = 5210 T50MHz;
//Bit_Rate_Pulse #(.delay_counts(16'd5_210)) BR_pulse (
//
//	.clk					(clk),
//	.rst					(rst_BR_w), 
//   .enable				(1'd1),
//	.end_bit_time		(end_bit_time_w),
//	.end_half_time		(end_half_time_w)
//	
//);


Bit_Rate_Pulse_NoParam BR_pulse (

	.clk					(clk),
	.rst					(rst_BR_w), 
   .enable				(1'd1),
	.delay_counts		(byte_rate),
	.end_bit_time		(end_bit_time_w),
	.end_half_time		(end_half_time_w)
	
);
			   
FSM_UART_Rx FSM_Rx (

	.rx					(rx),
	.clk					(clk),
	.rst					(rst),
	.end_half_time_i	(end_half_time_w),
	.end_bit_time_i	(end_bit_time_w),
	.Rx_bit_Count		(count_bits_w), 
	.sample_o			(sample_bit_w),
	.bit_count_enable	(bit_count_enable_w),
	.rst_BR				(rst_BR_w),
	.rst_bit_counter	(rst_bit_counter_w),
	.enable_out_reg	(enable_out_reg_w)
	
);			   
		
Counter_Param #(.n(3'd4)) Counter_bits (

	.clk					(clk),
	.rst					(rst_bit_counter_w),
	.enable				(bit_count_enable_w),
	.Q						(count_bits_w)
	
);

endmodule		