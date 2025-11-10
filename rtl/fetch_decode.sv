`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif


`include "define_state.h"

module fetch_decode_unit (
	input logic clock,
	input logic resetn,
    input logic [31:0] instruction,
    input logic [31:0] program_counter,
    input logic valid_in,

    input logic stall,
    input logic flush, 

    output logic [31:0] instruction_out,
    output logic [31:0] next_pc,
    output logic valid_out
);

always_ff @(posedge clock or negedge resetn) begin
    if (~resetn) begin  //NOP (Bubble)
        instruction_out <= 32'h00000013;
        next_pc <= 32'h00000000;
        valid_out <= 1'b0;
    end else if (flush) begin //NOP (Bubble)
        instruction_out <= 32'h00000013;
        next_pc <= program_counter;
        valid_out <= 1'b0; 
    end else if (~stall) begin // If everything is good, pass the next instruction to the decode phase 
        instruction_out <= instruction;
        next_pc <= program_counter;
        valid_out <= valid_in; 
    end 
    // else stall, hold all current values in the register 
end

endmodule