`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes the top desing RTL model 
//   
// Date: March 5, 2023
//////////////////////////////////////////////////////////////////////////////////
module GPIO_Port(
	
	// Address
	input [31:00] Address,	// Data addr
	
	// GPIO interface
	input [31:00] DataIn, 	// Data in from CPU
	output [31:00] DataOut,	// Data out to CPU
	input Select,				// Slect control

	input	[7:0]	GPIO_Port_In, 			// SWitches
	output reg [7:0] GPIO_Port_Out,	// LEDs
	
	input	clk,
	input	rst
	
);

localparam GPIO_PORT_IN_ADDR	= 2'h1;
localparam GPIO_PORT_OUT_ADDR	= 2'h0;

reg [7:0] GPIO_REG_OUT;
assign DataOut = {24'b0,GPIO_REG_OUT};

//always @ (posedge rst, posedge clk) begin
always @ (posedge rst, negedge clk) begin

	if(rst) begin
		GPIO_REG_OUT	= 8'b0;
		GPIO_Port_Out	= 8'b0;
		end
		
	else if(Select) begin	
		
		case(Address[1:0])
		
			GPIO_PORT_IN_ADDR: GPIO_REG_OUT = GPIO_Port_In;
				
			GPIO_PORT_OUT_ADDR: GPIO_Port_Out = DataIn[7:0];	
		
		endcase

	end
	
	else begin
		GPIO_REG_OUT = GPIO_REG_OUT;
		GPIO_Port_Out = GPIO_Port_Out;
		end
		
	
end

endmodule