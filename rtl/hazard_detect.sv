module hazard_detection_unit (
    // ID stage info (current instruction being decoded)
    input logic [4:0] id_rs1,
    input logic [4:0] id_rs2,
    
    // EX stage info (instruction currently in execute)
    input logic [4:0] ex_rd,
    input logic ex_mem_read,  // Is it a load instruction?
    input logic ex_reg_write,
    
    // MEM stage info (for branch handling)
    input logic mem_branch,
    input logic mem_zero,
    
    // Outputs
    output logic stall_id, // Stall IF and ID stages
    output logic stall_if,
    output logic flush_ex,   // Flush EX stage (for branch)
    output logic flush_id    // Flush ID stage (for branch)
);

always_comb begin
    stall_id = 1'b0;
    stall_if = 1'b0;
    flush_ex = 1'b0;
    flush_id = 1'b0;
    
    //Load use hazard
    if (ex_mem_read && ex_reg_write && (ex_rd != 5'b0)) begin
        if ((ex_rd == id_rs1) || (ex_rd == id_rs2)) begin
            stall_if = 1'b1;
            stall_id = 1'b1;
            flush_ex = 1'b1; // Insert bubble in EX
        end
    end

    // BRANCH CONTROL HAZARD
    // If branch in MEM stage is taken, flush earlier stages
    if (mem_branch && mem_zero) begin
        flush_ex = 1'b1;  // Flush ID/EX register
        flush_id = 1'b1;  // Flush IF/ID register
    end
end

endmodule
