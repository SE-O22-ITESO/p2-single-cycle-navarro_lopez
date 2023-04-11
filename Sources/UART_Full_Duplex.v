`timescale 1ns / 1ps
module UART_Full_Duplex (

	input [31:0] Address,
	input [31:0] DataIn,
	//output reg [31:0] DataOut,
	output [31:0] DataOut,
	input Select,
	input Write,
	input clk,
	input rst,
	output tx,
	input rx,
	output [7:0] tx_data,
	output [7:0] rx_data,
	output [7:0] byte_rate
);
// ====================================================
// = Parameters            
// ====================================================
localparam BYTE_RATE_ADDR	= 3'h4;
localparam RX_DATA_ADDR		= 3'h3;
localparam TX_DATA_ADDR		= 3'h2;
localparam FLAGS_ADDR		= 3'h1;
localparam SETUP_ADDR		= 3'h0;

localparam CLK_FREQ			= 32'd50_000_000;
localparam BAUD_RATE			= 32'd9_600;
localparam BYTE_RATE 		= CLK_FREQ/BAUD_RATE;

localparam BYTE_RATE_DFT_VAL	= BYTE_RATE;
//localparam BYTE_RATE_DFT_VAL	= 32'h1b2;
localparam TX_DATA_DFT_VAL		= 8'h5a;
localparam SETUP_DFT_VAL		= 32'h2;

// Registers
reg [31:0] Byte_Rate_Reg;
reg [7:0] Tx_Data_Reg;
reg [7:0] Rx_Data_Reg;
reg [31:0] Flags_Reg;
reg [31:0] Setup_Reg;

wire [7:0] Rx_Data_w;

assign tx_data = Tx_Data_Reg;
assign rx_data = Rx_Data_Reg;
assign byte_rate = Byte_Rate_Reg[7:0];

reg [31:0] Output;

always @ (Select, Address, Byte_Rate_Reg, Rx_Data_Reg, Tx_Data_Reg, Flags_Reg, Setup_Reg) begin

	case(Address[2:0])
		BYTE_RATE_ADDR:	Output <= Byte_Rate_Reg;
		RX_DATA_ADDR:		Output <= Rx_Data_Reg[7:0];
		TX_DATA_ADDR:		Output <= Tx_Data_Reg[7:0];
		FLAGS_ADDR:			Output <= Flags_Reg;
		SETUP_ADDR:		 	Output <= Setup_Reg;
		default:				Output <= 32'b0;
	endcase
	
end

assign DataOut = Output;

// Read and write event registers logic
//always @ (posedge rst, negedge clk/*, posedge Select*/) begin
always @ (posedge rst, posedge clk/*, posedge Select*/) begin
//wire clk_sel;
//or(clk_sel,clk,Select);
//
//always @ (posedge rst, posedge clk_sel) begin

	if(rst) begin
		//DataOut					<= 32'b0;
		Byte_Rate_Reg 			<= BYTE_RATE_DFT_VAL;
		Tx_Data_Reg				<= TX_DATA_DFT_VAL;
		Setup_Reg				<= SETUP_DFT_VAL;
		
//		Byte_Rate_Reg 			<= 32'b0;
//		Tx_Data_Reg				<= 8'b0;
//		Setup_Reg				<= 32'b0;
		//Rx_Data_Reg				<=  8'b0;
		//Flags_Reg				<= 32'b0;
		
	end
	
//	else if(Select) begin
	
//		if(Write) begin // Write
	else if(Write) begin
			case(Address[2:0])
				BYTE_RATE_ADDR: Byte_Rate_Reg <= DataIn;
				//RX_DATA_ADDR:   Rx_Data_Reg	<= Rx_Data_w;
				TX_DATA_ADDR:	 Tx_Data_Reg	<= DataIn[7:0];
				//FLAGS_ADDR:		 Flags_Reg		<= DataIn;
				SETUP_ADDR:		 Setup_Reg		<= DataIn;
//				default: begin
//					DataOut					<= 32'b0;
//					Byte_Rate_Reg 			<= 32'b0;
//					Tx_Data_Reg				<=  8'b0;
//					//Rx_Data_Reg				<=  8'b0;
//					//Flags_Reg				<= 32'b0;
//					Setup_Reg				<= 32'b0;
//				end
			endcase
			
//		end else begin // Read
//		
//			case(Address[2:0])
//				BYTE_RATE_ADDR:	DataOut <= Byte_Rate_Reg;
//				RX_DATA_ADDR:		DataOut <= Rx_Data_Reg[7:0];
//				TX_DATA_ADDR:		DataOut <= Tx_Data_Reg[7:0];
//				FLAGS_ADDR:			DataOut <= Flags_Reg;
//				SETUP_ADDR:		 	DataOut <= Setup_Reg;
//				// Dont un-comment these default settings
////				default: begin
////					DataOut					<= 32'b0;
////					Byte_Rate_Reg 			<= 32'b0;
////					Tx_Data_Reg				<=  8'b0;
////					//Rx_Data_Reg				<=  8'b0;
////					Setup_Reg				<= 32'b0;
////				end
//			endcase
//		
//		end
		
			
	end else begin
	
		//DataOut					<= DataOut;
		Byte_Rate_Reg 			<= Byte_Rate_Reg;
		Tx_Data_Reg				<= Tx_Data_Reg;
		//Rx_Data_Reg				<= 8'b0;
		//Flags_Reg				<= 32'b0;
		Setup_Reg				<= Setup_Reg;
	
//		DataOut					<= 32'b0;
//		Byte_Rate_Reg 			<= 32'b0;
//		Tx_Data_Reg				<= 8'b0;
//		//Rx_Data_Reg				<= 8'b0;
//		//Flags_Reg				<= 32'b0;
//		Setup_Reg				<= 32'b0;
	end

end

// ====================================================
// = UART Transmission module            
// ====================================================
// Wiring
wire Tx_Send_w;
//wire [1:0] Tx_Bytes_w;
wire Tx_Sent_w;
wire Rx_Flag_w;
wire Rx_Flag_Clr_w;
wire Rx_Parity_Err_w;
wire Rx_Parity_w;

assign Tx_Send_w = Setup_Reg[0];
assign Rx_Flag_Clr_w = Setup_Reg[3];


UART_Tx UART_Tx_Module (
	.clk				(clk),
	.rst				(rst),
	.tx_send			(Tx_Send_w),
	.tx_data			(Tx_Data_Reg[7:0]),
	.byte_rate		(Byte_Rate_Reg),
	.tx				(tx),
	.tx_sent			(Tx_Sent_w)
	
);


always @(rst, Rx_Parity_Err_w, Rx_Flag_w, Tx_Sent_w) begin
	
	if(rst) begin
		Flags_Reg	<= 32'b0;
	end else begin
		Flags_Reg <= {29'b0,Rx_Parity_Err_w,Rx_Flag_w,Tx_Sent_w};
	end
end

// ====================================================
// = UART Reception module           
// ====================================================
// Wiring
//wire [7:0] Rx_Data_w;
assign Rx_Parity_Err_w = (^{Rx_Data_Reg, Rx_Parity_w});

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


always @ (rst, Rx_Data_w) begin
	
	if(rst)
		Rx_Data_Reg = 8'b0;
	else
 		Rx_Data_Reg = Rx_Data_w;
end


endmodule