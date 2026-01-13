`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif
`include "define_state.h"

module execute (
    // Control signals from ID/EX register
    input logic [3:0] alu_control,
    input logic alu_src,
    
    // Data from ID/EX register
    input logic [31:0] rs1_data,
    input logic [31:0] rs2_data,
    input logic [31:0] immediate,
    input logic [31:0] pc,
    
    // Forwarding inputs
    input logic [1:0] forward_a,
    input logic [1:0] forward_b,
    input logic [31:0] mem_forward_data,  // From EX/MEM register
    input logic [31:0] wb_forward_data,   // From MEM/WB register
    
    // Outputs
    output logic [31:0] alu_result,
    output logic [31:0] rs2_data_out,  // For store instructions
    output logic zero,
    output logic [31:0] branch_target
);

    logic [31:0] alu_input_a;
    logic [31:0] alu_input_b_temp;
    logic [31:0] alu_input_b;
    
    // Forwarding MUX for ALU input A (rs1)
    always_comb begin
        case (forward_a)
            2'b00: alu_input_a = rs1_data;           // No forwarding
            2'b01: alu_input_a = wb_forward_data;    // Forward from WB
            2'b10: alu_input_a = mem_forward_data;   // Forward from MEM
            default: alu_input_a = rs1_data;
        endcase
    end
    
    // Forwarding MUX for ALU input B temp (rs2)
    always_comb begin
        case (forward_b)
            2'b00: alu_input_b_temp = rs2_data;
            2'b01: alu_input_b_temp = wb_forward_data;
            2'b10: alu_input_b_temp = mem_forward_data;
            default: alu_input_b_temp = rs2_data;
        endcase
    end
    
    // ALU source MUX (register vs immediate)
    always_comb begin
        alu_input_b = alu_src ? immediate[31:0] : alu_input_b_temp;
    end
    
    // ALU operation
    always_comb begin
        case (alu_control)
            4'b0010: alu_result = alu_input_a + alu_input_b;           // ADD
            4'b0110: alu_result = alu_input_a - alu_input_b;           // SUB
            4'b0000: alu_result = alu_input_a & alu_input_b;           // AND
            4'b0001: alu_result = alu_input_a | alu_input_b;           // OR
            4'b0111: alu_result = (alu_input_a < alu_input_b) ? 32'b1 : 32'b0; // SLT
            4'b1100: alu_result = ~(alu_input_a | alu_input_b);        // NOR
            default: alu_result = 32'b0;
        endcase
    end
    
    // Zero flag (for branches)
    assign zero = (alu_result == 32'b0);
    
    // Branch target address calculation
    assign branch_target = pc + immediate[31:0];
    
    // Pass through rs2 for store instructions (needs forwarding applied)
    assign rs2_data_out = alu_input_b_temp;

endmodule
