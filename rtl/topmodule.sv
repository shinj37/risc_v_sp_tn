`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

module topmodule (
    input logic clock,
    input logic resetn
);

// ==================== IF Stage Signals ====================
logic [31:0] pc_current;
logic [31:0] pc_next;
logic [31:0] if_instruction;

// ==================== IF/ID Pipeline Register Signals ====================
logic [31:0] if_id_instruction;
logic [31:0] if_id_pc;
logic if_id_valid;

// ==================== ID Stage Signals ====================
logic [6:0] opcode;
logic [2:0] funct3;
logic [6:0] funct7;
logic [4:0] rs1_addr, rs2_addr, rd_addr;
logic [31:0] rs1_data, rs2_data;
logic [63:0] immediate;

// Control signals from control unit
logic ctrl_reg_write;
logic ctrl_mem_to_reg;
logic ctrl_mem_read;
logic ctrl_mem_write;
logic ctrl_branch;
logic ctrl_alu_src;
logic [3:0] ctrl_alu_control;

// ==================== ID/EX Pipeline Register Signals ====================
logic [31:0] id_ex_rs1_data;
logic [31:0] id_ex_rs2_data;
logic [31:0] id_ex_immediate;
logic [31:0] id_ex_pc;
logic [4:0] id_ex_rs1;
logic [4:0] id_ex_rs2;
logic [4:0] id_ex_rd;
logic [3:0] id_ex_alu_control;
logic id_ex_alu_src;
logic id_ex_mem_read;
logic id_ex_mem_write;
logic id_ex_branch;
logic id_ex_mem_to_reg;
logic id_ex_reg_write;

// ==================== EX Stage Signals ====================
logic [31:0] ex_alu_result;
logic ex_zero;
logic [31:0] ex_branch_target;
logic [31:0] ex_rs2_data;
logic [1:0] forward_a, forward_b;

// ==================== EX/MEM Pipeline Register Signals ====================
logic [31:0] ex_mem_alu_result;
logic [31:0] ex_mem_rs2_data;
logic [31:0] ex_mem_branch_target;
logic ex_mem_zero;
logic [4:0] ex_mem_rd;
logic ex_mem_mem_read;
logic ex_mem_mem_write;
logic ex_mem_branch;
logic ex_mem_mem_to_reg;
logic ex_mem_reg_write;

// ==================== MEM Stage Signals ====================
logic [31:0] mem_read_data;
logic pc_src; // Branch taken signal

// ==================== MEM/WB Pipeline Register Signals ====================
logic [31:0] mem_wb_alu_result;
logic [31:0] mem_wb_mem_data;
logic [4:0] mem_wb_rd;
logic mem_wb_mem_to_reg;
logic mem_wb_reg_write;

// ==================== WB Stage Signals ====================
logic [31:0] wb_write_data;

// ==================== Hazard Control Signals ====================
logic stall_if, stall_id;
logic flush_if_id, flush_id_ex;

// ==================== Extract instruction fields ====================
assign opcode = if_id_instruction[6:0];
assign funct3 = if_id_instruction[14:12];
assign funct7 = if_id_instruction[31:25];
assign rs1_addr = if_id_instruction[19:15];
assign rs2_addr = if_id_instruction[24:20];
assign rd_addr = if_id_instruction[11:7];

// ==================== PC Logic ====================
assign pc_src = ex_mem_branch & ex_mem_zero;

always_comb begin
    if (pc_src) begin
        pc_next = ex_mem_branch_target;
    end else begin
        pc_next = pc_current + 32'd4;
    end
end

program_counter pc_reg (
    .clock(clock),
    .resetn(resetn),
    .PC_in(pc_next),
    .PC_out(pc_current)
);

// ==================== IF Stage ====================
inst_mem imem (
    .resetn(resetn),
    .clock(clock),
    .inst_address(pc_current),
    .inst_data(if_instruction)
);

// ==================== IF/ID Pipeline Register ====================
fetch_decode_unit if_id_reg (
    .resetn(resetn),
    .clock(clock),
    .instruction(if_instruction),
    .program_counter(pc_current),
    .valid_in(1'b1),
    .stall(stall_if),
    .flush(flush_if_id), 
    .instruction_out(if_id_instruction),
    .next_pc(if_id_pc),
    .valid_out(if_id_valid)
);

// ==================== ID Stage ====================
reg_file regfile (
    .resetn(resetn),
    .clock(clock),
    .reg_wr_en(mem_wb_reg_write),
    .opcode(opcode),
    .instruction(if_id_instruction),
    .read_data1(rs1_data),
    .read_data2(rs2_data),
    .write_data(wb_write_data)
);

immGen imm_gen (
    .instruction(if_id_instruction),
    .immediate(immediate)
);

control_unit ctrl (
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .reg_write(ctrl_reg_write),
    .mem_to_reg(ctrl_mem_to_reg),
    .mem_read(ctrl_mem_read),
    .mem_write(ctrl_mem_write),
    .branch(ctrl_branch),
    .alu_src(ctrl_alu_src),
    .alu_control(ctrl_alu_control)
);

// ==================== Hazard Detection ====================
hazard_detection_unit hazard_unit (
    .id_rs1(rs1_addr),
    .id_rs2(rs2_addr),
    .ex_rd(id_ex_rd),
    .ex_mem_read(id_ex_mem_read),
    .ex_reg_write(id_ex_reg_write),
    .mem_branch(ex_mem_branch),
    .mem_zero(ex_mem_zero),
    .stall_if(stall_if),
    .stall_id(stall_id),
    .flush_ex(flush_id_ex),
    .flush_id(flush_if_id)
);

// ==================== ID/EX Pipeline Register ====================
decode_execute_unit id_ex_reg (
    .clock(clock),
    .resetn(resetn),
    .stall(stall_id),
    .flush(flush_id_ex),
    
    .mem_read_in(ctrl_mem_read),
    .mem_write_in(ctrl_mem_write),
    .branch_in(ctrl_branch),
    .mem_to_reg_in(ctrl_mem_to_reg),
    .reg_write_in(ctrl_reg_write),
    .alu_src_in(ctrl_alu_src),
    .alu_op_in(ctrl_alu_control[1:0]),
    .reg_dst_in(1'b0), // Not used in RV32I
    .pc_in(if_id_pc),
    
    .instruction(if_id_instruction),
    .immediate(immediate),
    .reg_read_data1(rs1_data),
    .reg_read_data2(rs2_data),
    .reg_rs_1_in(rs1_addr),
    .reg_rs_2_in(rs2_addr),
    .reg_rd_in(rd_addr),
    
    .reg_write_out(id_ex_reg_write),
    .mem_to_reg_out(id_ex_mem_to_reg),
    .mem_read_out(id_ex_mem_read),
    .mem_write_out(id_ex_mem_write),
    .alu_src_out(id_ex_alu_src),
    .reg_dst_out(),
    .alu_op_out(),
    .branch_out(id_ex_branch),
    .pc_out(id_ex_pc),
    
    .instruction_out(),
    .immediate_out(id_ex_immediate),
    .reg_read_data1_out(id_ex_rs1_data),
    .reg_read_data2_out(id_ex_rs2_data),
    .reg_rs_1_out(id_ex_rs1),
    .reg_rs_2_out(id_ex_rs2),
    .register_rd_out(id_ex_rd)
);

// Store alu_control separately since we need full 4 bits
always_ff @(posedge clock or negedge resetn) begin
    if (~resetn) begin
        id_ex_alu_control <= 4'b0000;
    end else if (flush_id_ex) begin
        id_ex_alu_control <= 4'b0000;
    end else if (~stall_id) begin
        id_ex_alu_control <= ctrl_alu_control;
    end
end

// ==================== Forwarding Unit ====================
forwarding_unit fwd_unit (
    .ex_rs1(id_ex_rs1),
    .ex_rs2(id_ex_rs2),
    .mem_rd(ex_mem_rd),
    .mem_reg_write(ex_mem_reg_write),
    .wb_rd(mem_wb_rd),
    .wb_reg_write(mem_wb_reg_write),
    .forward_a(forward_a),
    .forward_b(forward_b)
);

// ==================== EX Stage ====================
execute ex_stage (
    .alu_control(id_ex_alu_control),
    .alu_src(id_ex_alu_src),
    .rs1_data(id_ex_rs1_data),
    .rs2_data(id_ex_rs2_data),
    .immediate(id_ex_immediate),
    .pc(id_ex_pc),
    .forward_a(forward_a),
    .forward_b(forward_b),
    .mem_forward_data(ex_mem_alu_result),
    .wb_forward_data(wb_write_data),
    .alu_result(ex_alu_result),
    .rs2_data_out(ex_rs2_data),
    .zero(ex_zero),
    .branch_target(ex_branch_target)
);

// ==================== EX/MEM Pipeline Register ====================
execute_mem_unit ex_mem_reg (
    .clock(clock),
    .resetn(resetn),
    .stall(1'b0),
    .flush(1'b0),
    
    .mem_read_in(id_ex_mem_read),
    .mem_write_in(id_ex_mem_write),
    .branch_in(id_ex_branch),
    .zero_ctrl_in(ex_zero),
    .mem_to_reg_in(id_ex_mem_to_reg),
    .reg_write_in(id_ex_reg_write),
    .alu_result_in(ex_alu_result),
    .alu_in_2_in(ex_rs2_data),
    .reg_rd_in(id_ex_rd),
    .branch_target_in(ex_branch_target),
    
    .zero_ctrl_out(ex_mem_zero),
    .mem_read_out(ex_mem_mem_read),
    .mem_write_out(ex_mem_mem_write),
    .branch_out(ex_mem_branch),
    .mem_to_reg_out(ex_mem_mem_to_reg),
    .reg_write_out(ex_mem_reg_write),
    .reg_rd_out(ex_mem_rd),
    .alu_result_out(ex_mem_alu_result),
    .alu_in_2_out(ex_mem_rs2_data),
    .branch_target_out(ex_mem_branch_target)
);

// ==================== MEM Stage ====================
data_mem dmem (
    .resetn(resetn),
    .clock(clock),
    .wr_en(ex_mem_mem_write),
    .read_en(ex_mem_mem_read),
    .address(ex_mem_alu_result),
    .write_data(ex_mem_rs2_data),
    .read_data(mem_read_data)
);

// ==================== MEM/WB Pipeline Register ====================
mem_wb_unit mem_wb_reg (
    .clock(clock),
    .resetn(resetn),
    .stall(1'b0),
    .flush(1'b0),
    
    .mem_to_reg_in(ex_mem_mem_to_reg),
    .reg_write_in(ex_mem_reg_write),
    .data_mem_in(mem_read_data),
    .read_rd_in(ex_mem_rd),
    .data_address_in(ex_mem_alu_result),
    
    .mem_to_reg_out(mem_wb_mem_to_reg),
    .reg_write_out(mem_wb_reg_write),
    .data_address_out(mem_wb_alu_result),
    .read_rd_out(mem_wb_rd),
    .data_mem_out(mem_wb_mem_data)
);

// ==================== WB Stage ====================
assign wb_write_data = mem_wb_mem_to_reg ? mem_wb_mem_data : mem_wb_alu_result;

endmodule
