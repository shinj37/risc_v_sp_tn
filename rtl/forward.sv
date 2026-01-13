

module forwarding_unit (
    // Instruction in EX (needs operands)
    input logic [4:0] ex_rs1,
    input logic [4:0] ex_rs2,
    
    // Instruction in MEM (just computed result)
    input logic [4:0] mem_rd,
    input logic mem_reg_write,
    
    // Instruction in WB (about to write back)
    input logic [4:0] wb_rd,
    input logic wb_reg_write,
    
    // Forwarding selects
    output logic [1:0] forward_a, // For rs1
    output logic [1:0] forward_b  // For rs2
);

always_comb begin
    forward_a = 2'b00; // No forwarding
    forward_b = 2'b00;
    
    // MEM-to-EX forwarding (priority)
    if (mem_reg_write && (mem_rd != 5'b0) && (mem_rd == ex_rs1))
        forward_a = 2'b10;
    if (mem_reg_write && (mem_rd != 5'b0) && (mem_rd == ex_rs2))
        forward_b = 2'b10;
    
    // WB-to-EX forwarding (only if MEM doesn't forward)
    if (wb_reg_write && (wb_rd != 5'b0) && (wb_rd == ex_rs1) && 
        !(mem_reg_write && (mem_rd == ex_rs1) && (mem_rd != 5'b0)))
        forward_a = 2'b01;
        
    if (wb_reg_write && (wb_rd != 5'b0) && (wb_rd == ex_rs2) &&
        !(mem_reg_write && (mem_rd == ex_rs2) && (mem_rd != 5'b0)))
        forward_b = 2'b01;
end

endmodule
