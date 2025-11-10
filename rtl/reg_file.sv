`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"



module reg_file (
	input logic clock,
	input logic resetn,
	input logic reg_wr_en, //register file write enable
	
	input logic [6:0] opcode, 
	
	input logic [31:0] instruction,
	input logic [31:0] write_data, //register file write data
	
	output logic [31:0] read_data1, //register file read data 1
	output logic [31:0] read_data2 //register file read data 2
);

logic [31:0] regs [31:0];
logic [4:0] rs1, rs2, rd;

reg_control reg_state;
assign read_data1 = regs[rs1];
assign read_data2 = regs[rs2];


always_ff @(posedge clock or negedge resetn) begin
    if (!resetn) begin
        // reset registers to 0
        integer i;
        for (i = 0; i < 32; i++) regs[i] <= 32'd0;
    end 
	//write the location with write data
    else begin
			 case (opcode) 
			7'h33: reg_state <= R_type; 
			7'h13: reg_state <= I_type;
			7'h03: reg_state <= I_type;
			7'h23: reg_state <= S_type;
			7'h63: reg_state <= SB_type; 
		endcase
	 case (reg_state) 
		R_type: begin
				rs2 <= instruction[24:20];
				rs1 <= instruction[19:15];
				rd <= instruction[11:7];
			end

			I_type: begin
				rs2 <= 5'bx;
				rs1 <= instruction[19:15];
				rd <= instruction[11:7];
			end
			
			S_type: begin
				rs2 <= instruction[24:20];
				rs1 <= instruction[19:15];
				rd <= 5'bx;
			end

			SB_type: begin
				rs2 <= instruction[24:20];
				rs1 <= instruction[19:15];
				rd <= 5'bx;
			end	

			default: begin
				rs2 <= 5'bx;
				rs1 <= 5'bx;
				rd <= 5'bx;
			end
		endcase
	 
	 
	 if (reg_wr_en && (rd != 5'd0)) begin
        regs[rd] <= write_data;
    end
end
end

endmodule
