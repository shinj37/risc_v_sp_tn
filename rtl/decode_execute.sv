`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif
`include "define_state.h"

module decode_execute_unit (
    input logic clock,
    input logic resetn,
    
    // Hazard control signals
    input logic stall,      // Stall signal (hold current values)
    input logic flush,      // Flush signal (insert bubble/NOP)
    
    // Control signals input (WB and MEM stage controls)
    // M signals
    input logic mem_read_in,
    input logic mem_write_in,
    input logic branch_in,
    
    // WB control signals
    input logic mem_to_reg_in,
    input logic reg_write_in,
    
    // EX signals
    input logic alu_src_in,
    input logic [1:0] alu_op_in,
    input logic reg_dst_in,
    
    // Data inputs from ID stage
    input logic [31:0] instruction,
    input logic [31:0] immediate,
    input logic [31:0] reg_read_data1,  // ALU input 1 data
    input logic [31:0] reg_read_data2,  // ALU input 2 data
    input logic [4:0] reg_rs_1_in,      // Source register 1 address (for forwarding)
    input logic [4:0] reg_rs_2_in,      // Source register 2 address (for forwarding)
    input logic [4:0] reg_rd_in,        // Destination register address
    
    // Control signals output (EX and MEM stage)
    output logic reg_write_out,
    output logic mem_to_reg_out,
    output logic mem_read_out,
    output logic mem_write_out,
    output logic alu_src_out,
    output logic reg_dst_out,
    output logic [1:0] alu_op_out,
    output logic branch_out,
    
    // Data outputs to EX stage
    output logic [31:0] instruction_out,
    output logic [31:0] immediate_out,
    output logic [31:0] reg_read_data1_out,
    output logic [31:0] reg_read_data2_out,
    output logic [4:0] reg_rs_1_out,
    output logic [4:0] reg_rs_2_out,
    output logic [4:0] register_rd_out
);

    always_ff @(posedge clock or negedge resetn) begin
        if (~resetn) begin
            // Reset all control signals to safe defaults (no memory access, no write)
            reg_write_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
            mem_read_out <= 1'b0;
            mem_write_out <= 1'b0;
            alu_src_out <= 1'b0;
            reg_dst_out <= 1'b0;
            alu_op_out <= 2'b00;
            branch_out <= 1'b0;
            
            // Reset data paths to zero
            instruction_out <= 32'b0;
            immediate_out <= 32'b0;
            reg_read_data1_out <= 32'b0;
            reg_read_data2_out <= 32'b0;
            reg_rs_1_out <= 5'b0;
            reg_rs_2_out <= 5'b0;
            register_rd_out <= 5'b0;
        end
        else if (flush) begin
            // Flush: Insert a bubble (NOP) by clearing control signals
            // This prevents any state changes in later stages
            reg_write_out <= 1'b0;      // No register write
            mem_to_reg_out <= 1'b0;
            mem_read_out <= 1'b0;       // No memory read
            mem_write_out <= 1'b0;      // No memory write
            alu_src_out <= 1'b0;
            reg_dst_out <= 1'b0;
            alu_op_out <= 2'b00;
            branch_out <= 1'b0;         // No branch
            
            // Clear data paths (optional - could keep data for debugging)
            instruction_out <= 32'b0;
            immediate_out <= 32'b0;
            reg_read_data1_out <= 32'b0;
            reg_read_data2_out <= 32'b0;
            reg_rs_1_out <= 5'b0;
            reg_rs_2_out <= 5'b0;
            register_rd_out <= 5'b0;
        end
        else if (~stall) begin
            // Normal operation: latch new values
            // Latch control signals
            reg_write_out <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            alu_src_out <= alu_src_in;
            reg_dst_out <= reg_dst_in;
            alu_op_out <= alu_op_in;
            branch_out <= branch_in;
            
            // Latch data signals
            instruction_out <= instruction;
            immediate_out <= immediate;
            reg_read_data1_out <= reg_read_data1;
            reg_read_data2_out <= reg_read_data2;
            reg_rs_1_out <= reg_rs_1_in;
            reg_rs_2_out <= reg_rs_2_in;
            register_rd_out <= reg_rd_in;
        end
        // else: stall == 1, hold current values (do nothing)
    end

endmodule