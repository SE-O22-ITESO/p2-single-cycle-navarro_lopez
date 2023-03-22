`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes a FSM RTL model used to handle UART TX cadance, timings, 
//   and enablement for other models 
// Date: October 24, 2022
//////////////////////////////////////////////////////////////////////////////////
module FSM_UART_Tx (

	// Inputs
	input				clk,
	input				rst,
	input				tx_send,
	input				end_bit_time,
	input		[3:0]	tx_bit_count,
	
	// Outputs
	output reg	[2:0]	tx_state_out,
	output reg		tx_cntr_en,
	output reg		bit_tmr_en,
	output reg		tx_sent
);

// ====================================================
// = Parameters         
// ====================================================

// Machine states
localparam IDLE			= 3'd0;
localparam START_BIT		= 3'd1;
localparam TX_DATA		= 3'd2;
localparam PARITY_BIT	= 3'd3;
localparam STOP_BIT		= 3'd4;
localparam TX_SENT		= 3'd5;

// Constants
localparam TX_IDLE 		= 1'b1;
localparam TX_START		= 1'b0;
localparam TX_STOP		= 1'b1;

// ====================================================
// = State Machine         
// ====================================================

// Registers
reg [2:0] tx_state;

// Next state logic & Present state FF's
always @(posedge rst, posedge clk) begin
	
	if (rst) 
		tx_state <= IDLE;
	
	else
		
		case(tx_state)
		
			IDLE:
				if(tx_send == 1'b1) 			// If tx_send button pressed
					tx_state <= START_BIT;	// Jump to START_BIT
				
			START_BIT:
				if(end_bit_time == 1'b1)	// If end_bit_time is reached
					tx_state <= TX_DATA;		// then jump to TX_DATA
			
			TX_DATA:
				if(tx_bit_count == 4'd8)	// If tx_bit_count is 8
					tx_state <= PARITY_BIT;	// then jump to PARITY_BIT
			
			PARITY_BIT:
				if(end_bit_time == 1'b1)	// If end_bit_time is reached
					tx_state <= STOP_BIT;	// then jump to STOP_BIT
					
			STOP_BIT:
				if(end_bit_time == 1'b1)	// If end_bit_time is reached
					//tx_state <= IDLE;			// then jump to IDLE
					tx_state	<= TX_SENT;		// then jump to TX_SENT
			
			TX_SENT:	
				tx_state <= IDLE;				// Inconditionally jump to IDLE
			
			default:
				tx_state <= IDLE;				// Default IDLE
				
		endcase
		
	
end

// Output logic
always @(tx_state) begin

	case(tx_state)
	
		IDLE:
			begin
			tx_state_out	= IDLE;
			tx_cntr_en		= 1'b0;
			bit_tmr_en		= 1'b0;
			//tx_sent			= 1'b0;
			tx_sent			= 1'b1;
			end
			
		START_BIT:
			begin
			tx_state_out	= START_BIT;
			tx_cntr_en		= 1'b0;
			bit_tmr_en		= 1'b1;
			tx_sent			= 1'b0;
			end
			
		TX_DATA:
			begin
			tx_state_out	= TX_DATA;
			tx_cntr_en		= 1'b1;
			bit_tmr_en		= 1'b1;
			tx_sent			= 1'b0;
			end
		
		PARITY_BIT:
			begin
			tx_state_out	= PARITY_BIT;
			tx_cntr_en		= 1'b0;
			bit_tmr_en		= 1'b1;
			tx_sent			= 1'b0;
			end
			
		STOP_BIT:
			begin
			tx_state_out	= STOP_BIT;
			tx_cntr_en		= 1'b0;
			bit_tmr_en		= 1'b1;
			tx_sent			= 1'b0;
			end
			
		TX_SENT:
			begin
			tx_state_out	= TX_SENT;
			tx_cntr_en		= 1'b0;
			bit_tmr_en		= 1'b0;
			tx_sent			= 1'b1;
			end
							
		default:
			begin
			tx_state_out	= IDLE;
			tx_cntr_en		= 1'b0;
			bit_tmr_en		= 1'b0;
			tx_sent			= 1'b0;
			end
			
	endcase

end


endmodule
