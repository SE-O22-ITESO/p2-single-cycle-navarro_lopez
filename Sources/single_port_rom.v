// Quartus II Verilog Template
// Single port ROM with single read/write address 
module single_port_rom #(
	parameter DATA_WIDTH = 8,
	parameter DATA_DEPTH = 6,
	parameter DATA_PATH = "")
(	input [(DATA_WIDTH-1):0] data,
	input [(DATA_WIDTH-1):0] addr,
	input we, re, clk,							// <-- Implement read enable flag
	output [(DATA_WIDTH-1):0] q );
// Declare the RAM array
//reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
//reg [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];
reg [DATA_WIDTH-1:0] ram[DATA_DEPTH-1:0];

initial
	begin
		//$readmemh("hex_memory_file.mem", rom);
		//$readmemh("Memory_Files//program.dat", rom);
		$readmemh(DATA_PATH, ram);
		//$readmemh("..//Sources//tex.dat", rom);
		//$readmemb("..//Sources//bin_memory_file.mem", rom);
	end

always @ (posedge clk)
	begin
		// Write
		if (we)
			//ram[addr] <= data;
			ram[addr] <= data;
	end
// Reading continuously
//assign q = ram[addr];
//assign q = rom[addr];

assign q = re?ram[addr]:32'hDEAD_BEEF;
endmodule
