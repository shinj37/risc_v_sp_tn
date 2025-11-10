`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif
`include "define_state.h"

module mem_wb_unit (
    input logic clock,
    input logic resetn,
    
    // Hazard control signals
    input logic stall,      // Stall signal (hold current values)
    input logic flush,      // Flush signal (insert bubble/NOP)
    
    // WB control signals input
    input logic mem_to_reg_in,
    input logic reg_write_in,
    
    // Data inputs from MEM stage
    input logic [31:0] data_mem_in,         // Data read from memory
    input logic [4:0] read_rd_in,           // Destination register address
    input logic [31:0] data_address_in,     // ALU result/address
    
    // WB control signals output
    output logic mem_to_reg_out,
    output logic reg_write_out,
    
    // Data outputs to WB stage
    output logic [31:0] data_address_out,   // ALU result
    output logic [4:0] read_rd_out,         // Destination register
    output logic [31:0] data_mem_out        // Memory data
);

    always_ff @(posedge clock or negedge resetn) begin
        if (~resetn) begin
            // Reset all control signals to safe defaults
            mem_to_reg_out <= 1'b0;
            reg_write_out <= 1'b0;      // No register write
            
            // Reset data paths
            data_address_out <= 32'b0;
            read_rd_out <= 5'b0;
            data_mem_out <= 32'b0;
        end
        else if (flush) begin
            // Flush: Insert a bubble (NOP) by clearing control signals
            // Most critical: prevent writing invalid data to registers
            mem_to_reg_out <= 1'b0;
            reg_write_out <= 1'b0;      // No register write (CRITICAL!)
            
            // Clear data paths (optional - could keep for debugging)
            data_address_out <= 32'b0;
            read_rd_out <= 5'b0;
            data_mem_out <= 32'b0;
        end
        else if (~stall) begin
            // Normal operation: latch new values
            // Latch control signals
            mem_to_reg_out <= mem_to_reg_in;
            reg_write_out <= reg_write_in;
            
            // Latch data signals
            data_address_out <= data_address_in;
            read_rd_out <= read_rd_in;
            data_mem_out <= data_mem_in;
        end
        // else: stall == 1, hold current values (do nothing)
    end

endmodule