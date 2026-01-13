`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

module immGen (
    input  logic [31:0] instruction,
    output logic [63:0] immediate
);

 logic [6:0] opcode;
 
always_comb begin
    case (instruction[6:0])
        7'b0110011: immediate = 64'h0; // R-type
        7'b0010011, 7'b0000011: // I-type
            immediate = {{52{instruction[31]}}, instruction[31:20]};
        7'b0100011: // S-type
            immediate = {{52{instruction[31]}}, instruction[31:25], instruction[11:7]};
        7'b1100011: // B-type
            immediate = {{51{instruction[31]}}, instruction[31], 
                        instruction[30:25], instruction[11:8], instruction[7], 1'b0};
        default: immediate = 64'h0;
    endcase
end
endmodule
