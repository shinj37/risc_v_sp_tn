`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif


`include "define_state.h"

module mem_wb_unit (
	input logic clock,
	input logic resetn

    input logic write_back_in,

    input logic [31:0] data_mem_in,
    input logic [4:0] read_rd_in,
    input logic [31:0] data_address_in,

    output logic write_back_out,
    output logic [31:0] data_address_out,
    output logic [4:0] read_rd_out,
    output logic [31:0] data_mem_out,
);
