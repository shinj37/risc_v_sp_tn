`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

module data_mem (
	input logic clock,
	input logic resetn,
	input logic wr_en,
	input logic read_en,
	input logic [31:0] address,
	input logic [31:0] write_data,
	output logic [31:0] read_data
);

logic [31:0] mem [0:255]; 

always_ff @(posedge clock or negedge resetn) begin
	if (!resetn) begin
		integer i;
		for (i = 0; i < 256; i++) mem[i] <= 32'd0;
	end else if (wr_en) begin
		mem[address[9:2]] <= write_data;
	end	
end

assign read_data = (read_en) ? mem[address[9:2]] : 32'd0;

endmodule