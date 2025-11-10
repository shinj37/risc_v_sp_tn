`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

module program_counter (
    input logic clock,
    input logic resetn,
    
    input logic [31:0] PC_in,
    output logic [31:0] PC_out
);

always_ff @(posedge clock or negedge resetn) begin
    if (!resetn) begin
        PC_out <= 32'h00000000;
    end else begin
        PC_out <= PC_in;
    end
end

endmodule