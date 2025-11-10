`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif


`include "define_state.h"

module topmodule (
	input logic clock,
	input logic resetn
);



// Internal signal declarations
logic wr_en, read_en; //data memory write and read enable
logic [31:0] data_address, data_write, data_read;
logic reg_wr_en; //register file write enable
logic [4:0] read_reg1, read_reg2, write_reg1;
logic [31:0] reg_write, reg_read_data1, reg_read_data2;
logic [31:0] inst_address, inst_data;
logic [6:0] opcode;
logic [63:0] immediate;
logic ALU_src, Branch, Mem_to_reg, ALU_op, Mem_write;
logic [31:0] sum_result;
logic [3:0] operation;
logic [3:0] functField;

logic [31:0] ALU_in1, ALU_in2;
logic [31:0] ALU_result;

logic [31:0] PC_in;
logic [31:0] PC_out; 

logic zero_ctrl; 
logic [31:0] next_PC;
top_control instr_state; 


immGen immediate_unit (
	.instruction(inst_data),
	.immediate(immediate)
);

program_counter PC_unit (
	.clock(clock),
	.resetn(resetn),

	.PC_in(PC_in),
	.PC_out(PC_out)
);

data_mem datamemory_unit (
	.resetn(resetn),
	.clock(clock),
	
	.wr_en(Mem_write),
	.read_en(read_en),
	
	.address(data_address),
	.write_data(data_write),
	.read_data(data_read)
);

inst_mem instruct_unit (
	.resetn(resetn),
	.clock(clock),
	
	.inst_address(PC_out),
	.inst_data(inst_data)
);

reg_file register_unit (
	.resetn(resetn),
	.clock(clock),
	
	.reg_wr_en(reg_wr_en),
	.opcode(opcode),
	
	.instruction(inst_data),
	
	.read_data1(reg_read_data1),
	.read_data2(reg_read_data2),
	
	.write_data(reg_write)
);

fetch_decode fetch_decode_unit (
	.resetn(resetn),
	.clock(clock),

	.instruction(inst_data),
    .program_counter(PC_out),
    .valid_in(valid_in),

	.stall(stall),
    .flush(flush), 

    .instruction_out(instruction_out),
    .next_pc(pc_incr),
    .valid_out(valid_out)
);

decode_execute decode_execute_unit (

);

control control_unit (
	

)

always_ff @(posedge clock or negedge resetn ) begin
	if (!resetn) begin
		inst_address <= 32'h00000000;
		data_address <= 32'h00000000;
		read_reg1 <= 5'b00000;
		read_reg2 <= 5'b00000;
		write_reg1 <= 5'b00000;
		reg_write <= 32'h00000000;
		data_write <= 32'h00000000;
		operation <= 4'b0000;
		functField <= 4'b0000;
	end else begin
		read_reg1 <= inst_data[19:15];
		read_reg2 <= inst_data[24:20];
		write_reg1 <= inst_data[11:7];
		
		// Extract opcode
		opcode <= inst_data[6:0];
		functField <= inst_data[14:12];
		// State definitions
		case (opcode)
			7'b01100011: begin
				instr_state <= R_format;
			end
			7'b00000111: begin
				instr_state <= id;
			end
			7'b0100011: begin
				instr_state <= sd;
			end
			7'b1100011: begin
				instr_state <= beq;
			end
			default: begin
				instr_state <= R_format;
			end
		endcase


		case (instr_state) //Control signals
			R_format: begin
				ALU_src <= 0;
				Mem_to_reg <= 0;
				reg_wr_en <= 1;
				read_en <= 0;
				Mem_write <= 0;
				Branch <= 0;
				ALU_op <= 2'b10;
			end

			id: begin
				ALU_src <= 1;
				Mem_to_reg <= 1;
				reg_wr_en <= 1;
				read_en <= 1;
				Mem_write <= 0;
				Branch <= 0;
				ALU_op <= 2'b00;
			end
			
			sd: begin
				ALU_src <= 1;
				Mem_to_reg <= 1'bx;
				reg_wr_en <= 1'b0;
				read_en <= 1'b0;
				Mem_write <= 1'b1;
				Branch <= 0;
				ALU_op <= 2'b00;
			end

			beq: begin
				ALU_src <= 0;
				Mem_to_reg <= 1'bx;
				reg_wr_en <= 1'b0;
				read_en <= 1'b0;
				Mem_write <= 1'b0;
				Branch <= 1;
				ALU_op <= 2'b01;
			end	

			default: begin
				ALU_src <= 1'bx;
				Branch <= 1'bx;
				Mem_to_reg <= 1'bx;
				ALU_op <= 2'bxx;
				Mem_write <= 1'bx;
				read_en <= 1'bx;
				reg_wr_en <= 1'bx;
			end
		endcase

		case (ALU_op) //ALU control signals
			2'b00: begin
				operation <= 4'b0010; //ADD, load double word
			end
			2'bx1: begin
				operation <= 4'b0110; //SUB, branch if equal
			end
			2'b1x: begin
				case (functField)
					4'b0000: begin
						operation <= 4'b0010; //ADD
					end
					4'b0110: begin
						operation <= 4'b0001; //OR
					end
					4'b1000: begin
						operation <= 4'b0110; //SUB
					end
					4'b0111: begin
						operation <= 4'b0000; //AND
					end
				endcase
			end
		endcase

		if (ALU_src) begin
			ALU_in2 <= immediate;
		end else begin
			ALU_in2 <= reg_read_data2;
		end
		ALU_in1 <= reg_read_data1;

		case (operation)
			4'b0010: begin
				ALU_result <= ALU_in1 + ALU_in2;t
			end
			4'b0110: begin
				ALU_result <= ALU_in1 - ALU_in2;
				if (ALU_result == 32'h0) zero_ctrl <= 1'b1;
			end
			4'b0001: begin
				ALU_result <= ALU_in1 | ALU_in2;
				if (ALU_result == 32'h0) zero_ctrl <= 1'b1;
			end
			4'b0000: begin
				ALU_result <= ALU_in1 & ALU_in2;
				if (ALU_result == 32'h0) zero_ctrl <= 1'b1;
			end
		endcase

		data_address <= ALU_result;
		data_write <= reg_read_data2;
		// Memory read is handled by the data_mem module 

		reg_write <= (Mem_to_reg) ? data_read : ALU_result;
		
		PC_in <= (Branch && zero_ctrl) ? sum_result : next_PC; 
		
	end
end

	always_comb begin
		sum_result = pc_incr + (immediate[31:0]<<1); 
		next_PC = PC_out + 32'h4; 
	end

endmodule