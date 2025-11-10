`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif


module imm_gen (
    input  logic [31:0] instruction,
    output logic [63:0] immediate
);

    logic [6:0] opcode;
    assign opcode = instruction[6:0];
    
    always_comb begin
        case (opcode)
            // I-type: ADDI, SLTI, XORI, ORI, ANDI, SLLI, SRLI, SRAI, LB, LH, LW, LD, LBU, LHU, LWU, JALR
            7'b0010011, 7'b0000011, 7'b1100111: begin
                immediate = {{52{instruction[31]}}, instruction[31:20]};
            end
            
            // S-type: SB, SH, SW, SD
            7'b0100011: begin
                immediate = {{52{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            
            // B-type: BEQ, BNE, BLT, BGE, BLTU, BGEU
            7'b1100011: begin
                immediate = {{51{instruction[31]}}, instruction[31], instruction[7], 
                             instruction[30:25], instruction[11:8], 1'b0};
            end
            
            // U-type: LUI, AUIPC
            7'b0110111, 7'b0010111: begin
                immediate = {{32{instruction[31]}}, instruction[31:12], 12'b0};
            end
            
            // J-type: JAL
            7'b1101111: begin
                immediate = {{43{instruction[31]}}, instruction[31], instruction[19:12], 
                             instruction[20], instruction[30:21], 1'b0};
            end
            
            // Default (R-type has no immediate)
            default: begin
                immediate = 64'b0;
            end
        endcase
    end

endmodule