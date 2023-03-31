`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Angel Ramses Navarro Lopez
// Module Description:
//   This module describes a binary to 7 segment display decder RTL model.
// Date: 09/16/2022
//////////////////////////////////////////////////////////////////////////////////

module Decoder_Bin_hex_7seg(
	// Inputs
	 input  wire W,
    input  wire X,
    input  wire Y,
    input  wire Z,
	 
	 // Outputs
    output wire Seg_A,
    output wire Seg_B,
    output wire Seg_C,
    output wire Seg_D,
    output wire Seg_E,
    output wire Seg_F,
    output wire Seg_G
);
    // Segments outputs
    assign Seg_A = (~W & ~X & ~Y &  Z) | (~W &  X & ~Y & ~Z) | ( W & ~X &  Y &  Z) | ( W &  X & ~Y &  Z);
    assign Seg_B = (~W &  X & ~Y &  Z) | ( W &  X &  ~Y &  ~Z) | (X &  Y &  ~Z) | ( W &  X &  Y) | ( W &  Y &  Z);
    assign Seg_C = (~W & ~X &  Y & ~Z) | ( W &  X & ~Y & ~Z) | ( W &  X &  Y);
    assign Seg_D = (~W & ~X & ~Y &  Z) | (~W &  X & ~Y & ~Z) | ( X &  Y &  Z) | ( W & ~X &  Y & ~Z);
    assign Seg_E = (~W &  Z) | (~W &  X & ~Y) | (~X & ~Y &  Z);
    assign Seg_F = (~W & ~X &  Z) | (~W &  Y &  Z) | (~W & ~X &  Y) | ( W &  X & ~Y &  Z);
    assign Seg_G = (~W & ~X & ~Y) | (~W &  X &  Y &  Z) | ( W &  X & ~Y & ~Z);
    
endmodule