`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif
`include "define_state.h"

module execute_mem_unit (
    input logic clock,
    input logic resetn,
    
    // Hazard control signals
    input logic stall,      // Stall signal (hold current values)
    input logic flush,      // Flush signal (insert bubble/NOP)
    
    // Inputs
    // M signals
    input logic mem_read_in,
    input logic mem_write_in,
    input logic branch_in,
    
    // Zero control 
    input logic zero_ctrl_in,
    
    // WB control signals
    input logic mem_to_reg_in,
    input logic reg_write_in,
    
    // Input results
    input logic [31:0] alu_result_in,
    input logic [31:0] alu_in_2_in,
    input logic [4:0] reg_rd_in,
    
    // Outputs
    output logic zero_ctrl_out,
    
    // M Signals
    output logic mem_read_out, 
    output logic mem_write_out,
    output logic branch_out,
    
    // WB control signals
    output logic mem_to_reg_out,
    output logic reg_write_out,
    
    // Output results
    output logic [4:0] reg_rd_out,
    output logic [31:0] alu_result_out,
    output logic [31:0] alu_in_2_out
);

    always_ff @(posedge clock or negedge resetn) begin
        if (~resetn) begin
            // Reset all control signals to safe defaults
            zero_ctrl_out <= 1'b0;
            mem_read_out <= 1'b0;
            mem_write_out <= 1'b0;
            branch_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
            reg_write_out <= 1'b0;
            
            // Reset data paths
            reg_rd_out <= 5'b0;
            alu_result_out <= 32'b0;
            alu_in_2_out <= 32'b0;
        end
        else if (flush) begin
            // Flush: Insert a bubble (NOP) by clearing control signals
            // This is critical for branch mispredictions
            zero_ctrl_out <= 1'b0;
            mem_read_out <= 1'b0;       // No memory read
            mem_write_out <= 1'b0;      // No memory write (CRITICAL!)
            branch_out <= 1'b0;         // No branch
            mem_to_reg_out <= 1'b0;
            reg_write_out <= 1'b0;      // No register write
            
            // Clear data paths (optional - could keep for debugging)
            reg_rd_out <= 5'b0;
            alu_result_out <= 32'b0;
            alu_in_2_out <= 32'b0;
        end
        else if (~stall) begin
            // Normal operation: latch new values
            // Latch control signals
            zero_ctrl_out <= zero_ctrl_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            branch_out <= branch_in;
            mem_to_reg_out <= mem_to_reg_in;
            reg_write_out <= reg_write_in;
            
            // Latch data signals
            reg_rd_out <= reg_rd_in;
            alu_result_out <= alu_result_in;
            alu_in_2_out <= alu_in_2_in;
        end
        // else: stall == 1, hold current values (do nothing)
    end

endmodule