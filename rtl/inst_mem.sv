`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

module inst_mem (
	input logic clock,
	input logic resetn,
	
	input logic [31:0] inst_address,
	output logic [31:0] inst_data
);

logic [31:0] mem [0:255];  // example: 256 instructions

assign inst_data = mem[inst_address[9:2]];  // word-aligned address (ignore low 2 bits)

endmodule