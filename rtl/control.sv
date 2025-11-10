`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif
`include "define_state.h"

module control_unit (
    input logic [31:0] instruction,
    
    output logic reg_write_out,
    output logic mem_to_reg_out,
    output logic mem_read_out,
    output logic mem_write_out,
    output logic alu_src_out,
    output logic reg_dst_out,
    output logic [1:0] alu_op_out,
    output logic branch_out,
);




endmodule