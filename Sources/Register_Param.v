//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes a type D flip flop register RTL model
// Date: March 9, 2023
//////////////////////////////////////////////////////////////////////////////////

module Register_Param #(
	parameter LENGTH = 8,
	parameter RST_VAL = {LENGTH{1'b0}}
	) (
	
	// Inputs
	input  		[LENGTH-1:0] d, 			// Data input to FF
	input  		rst,						// Reset signal
	input			clk,						// Clock signal
	input			en,						// Enable signal
	
	// Outputs
	output reg [LENGTH-1:0] q				// Data output from FF

);

always @ (posedge rst, posedge clk) begin

	     if(rst)	q <= RST_VAL;
	else if(en)		q <= d;
	else				q <= q;

end

endmodule