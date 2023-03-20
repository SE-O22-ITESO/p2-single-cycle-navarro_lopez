`timescale 1ns / 1ps
module UART_Full_Duplex (

	input [31:0] Address,
	input [31:0] DataIn,
	output reg [31:0] DataOut,
	input Select,
	input Write,
	input clk,
	input rst,
	output tx,
	input rx
);
// ====================================================
// = Parameters            
// ====================================================
localparam BYTE_RATE_ADDR	= 2'h0;
localparam TX_DATA_ADDR		= 2'h1;
localparam RX_DATA_ADDR		= 2'h2;
localparam SETUP_ADDR		= 2'h3;

// Registers
reg [31:0] Byte_Rate_Reg;
reg [7:0] Tx_Data_Reg;
reg [7:0] Rx_Data_Reg;
reg [31:0] Setup_Reg;

// Questa issues error if wires not declared first
wire Tx_Send_w;
wire Tx_Sent_w;
wire Rx_Flag_w;
wire Rx_Flag_Clr_w;
wire Rx_Parity_w;

// Read and write event registers logic
always @ (posedge rst, posedge clk, posedge Select) begin

	if(rst) begin
		DataOut					<= 32'b0;
		Byte_Rate_Reg 			<= 32'b0;
		Tx_Data_Reg				<=  8'b0;
		Rx_Data_Reg				<=  8'b0;
		Setup_Reg				<= 32'b0;
		
	end
	
	else if(Select) begin
	
		if(Write) begin
			
			case(Address[1:0])
				BYTE_RATE_ADDR: Byte_Rate_Reg <= DataIn;
				TX_DATA_ADDR:	 Tx_Data_Reg	<= DataIn[7:0];
				//RX_DATA_ADDR:   Rx_Data_Reg	<= DataIn[7:0];
				SETUP_ADDR:		 Setup_Reg		<= DataIn;
				default: begin
					DataOut					<= 32'b0;
					Byte_Rate_Reg 			<= 32'b0;
					Tx_Data_Reg				<=  8'b0;
					Rx_Data_Reg				<=  8'b0;
					Setup_Reg				<= 32'b0;
				end
			endcase
			
		end else begin
		
			case(Address[1:0])
				BYTE_RATE_ADDR: DataOut <= Byte_Rate_Reg;
				TX_DATA_ADDR:   DataOut <= Tx_Data_Reg[7:0];
				RX_DATA_ADDR:   DataOut <= Rx_Data_Reg[7:0];
				SETUP_ADDR:		 DataOut <= Setup_Reg;
				default: begin
					DataOut					<= 32'b0;
					Byte_Rate_Reg 			<= 32'b0;
					Tx_Data_Reg				<=  8'b0;
					Rx_Data_Reg				<=  8'b0;
					Setup_Reg				<= 32'b0;
				end
			endcase
		
		end
		
		Setup_Reg[0:0] <= Tx_Send_w;
		Setup_Reg[3:3] <= Tx_Sent_w;
		Setup_Reg[4:4] <= Rx_Flag_w;
		Setup_Reg[5:5] <= Rx_Flag_Clr_w;
		Setup_Reg[6:6] <= (^{Rx_Data_Reg,Rx_Parity_w});
			
	end
	
	else begin
		DataOut					<= 32'b0;
		Byte_Rate_Reg 			<= 32'b0;
		Tx_Data_Reg				<= 8'b0;
		Rx_Data_Reg				<= 8'b0;
		Setup_Reg				<= 32'b0;
	end

end

// ====================================================
// = UART Transmission module            
// ====================================================
// Wiring
//wire Tx_Send_w;
//wire Tx_Sent_w;

UART_Tx UART_Tx_Module (
	.clk				(clk),
	.rst				(rst),
	.tx_send			(Tx_Send_w),
	.tx_data			(Tx_Data_Reg[7:0]),
	.byte_rate		(Byte_Rate_Reg),
	.tx				(tx),
	.tx_sent			(Tx_Sent_w)
);

// ====================================================
// = UART Reception module           
// ====================================================
// Wiring
wire [7:0] Rx_Data_w;
//wire Rx_Flag_w;
//wire Rx_Flag_Clr_w;
//wire Rx_Parity_w;
//assign parity_error = (^{Rx_Data_Reg, parity_w});

UART_Rx UART_Rx_Module (
	.clk				(clk),
	.rst				(rst),
	.rx_flag_clr	(Rx_Flag_Clr_w),
	.rx				(rx),
	.byte_rate		(Byte_Rate_Reg),
	.parity			(Rx_Parity_w),
	.rx_flag			(Rx_Flag_w),
	.Rx_SR			(Rx_Data_w)
);


endmodule