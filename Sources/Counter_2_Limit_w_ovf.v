`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes a counter with limit detection RTL model 
// Date: October 24, 2022
//////////////////////////////////////////////////////////////////////////////////
module Counter_2_Limit_w_ovf (
    
	 // Inputs
	 input [31:0] limit,
	 input rst,
    input enable,
    input clk,
	 
	 // Outputs
    output reg [31:0] Q,
    output overflow
	 
);

assign overflow = (Q==limit)? 1'b1 : 1'b0;

always @(posedge rst, posedge clk)
  begin
    if(rst)
        Q <= {32{1'b0}};
    else
        if (enable)
            if (Q==limit)
                Q <= {32{1'b0}};
            else
                Q <= Q + 1'b1;
        else
            Q <= Q;
  end 
endmodule
