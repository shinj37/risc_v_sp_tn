`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif


`include "define_state.h"

module execute_mem_unit (
	input logic clock,
	input logic resetn
    
    input logic mem_in,
    input logic write_back_in,

    input logic [31:0] alu_result_in,
    input logic [31:0] alu_in_2_in,
    input logic [4:0] reg_rd_in,

    output logic write_back_out,
    output logic [4:0] reg_rd_out,
    output logic [31:0] alu_result_out,
    output logic [31:0] alu_in_2_out,
);
