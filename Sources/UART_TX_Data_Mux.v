`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes transmission data multiplexor RTL model used for UART TX 
//   module
// Date: October 24, 2022
//////////////////////////////////////////////////////////////////////////////////
module TX_Data_Mux (
	
	// Inputs
	input [2:0]		tx_state,
	input [7:0]		tx_data,
	input [2:0]		tx_data_index,
	input				tx_parity,
	input 			end_bit_time,
	input				clk,
	input				rst,
	
	// Outputs
	output reg		tx
	
);

// Machine states
localparam IDLE			= 3'd0;
localparam START_BIT		= 3'd1;
localparam TX_DATA		= 3'd2;
localparam PARITY_BIT	= 3'd3;
localparam STOP_BIT		= 3'd4;

// Constants
localparam TX_IDLE 		= 1'b1;
localparam TX_START		= 1'b0;
localparam TX_STOP		= 1'b1;

always @ (posedge rst, posedge clk /*posedge end_bit_time*/) begin
	
	if(rst)
		
		tx = TX_IDLE;
	
	else begin
	
		if(end_bit_time) begin
		
				case(tx_state)
					IDLE:			tx = TX_IDLE;
					START_BIT:	tx = TX_START;
					TX_DATA:		tx = tx_data[tx_data_index];
					PARITY_BIT:	tx = tx_parity;
					STOP_BIT:	tx = TX_STOP;
					default:		tx = TX_IDLE;
				
				endcase
		
		end
		
	end

end

endmodule