module control_unit (
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    
    // WB stage controls
    output logic reg_write,
    output logic mem_to_reg,
    
    // M stage controls  
    output logic mem_read,
    output logic mem_write,
    output logic branch,
    
    // EX stage controls
    output logic alu_src,
    output logic [3:0] alu_control
);

always_comb begin
    // Set defaults
    reg_write = 1'b0;
    mem_to_reg = 1'b0;
    mem_read = 1'b0;
    mem_write = 1'b0;
    branch = 1'b0;
    alu_src = 1'b0;
    alu_control = 4'b0000;
    
    case (opcode)
        7'b0110011: begin // R-type (ADD, SUB, AND, OR)
            reg_write = 1'b1;
            alu_src = 1'b0; // Use rs2
            case ({funct7, funct3})
                10'b0000000_000: alu_control = 4'b0010; // ADD
                10'b0100000_000: alu_control = 4'b0110; // SUB
                10'b0000000_111: alu_control = 4'b0000; // AND
                10'b0000000_110: alu_control = 4'b0001; // OR
                default: alu_control = 4'b0010;
            endcase
        end
        
        7'b0010011: begin // I-type (ADDI, etc.)
            reg_write = 1'b1;
            alu_src = 1'b1; // Use immediate
            alu_control = 4'b0010; // ADD
        end
        
        7'b0000011: begin // Load (LD)
            reg_write = 1'b1;
            mem_to_reg = 1'b1;
            mem_read = 1'b1;
            alu_src = 1'b1;
            alu_control = 4'b0010; // ADD for address calc
        end
        
        7'b0100011: begin // Store (SD)
            mem_write = 1'b1;
            alu_src = 1'b1;
            alu_control = 4'b0010; // ADD for address calc
        end
        
        7'b1100011: begin // Branch (BEQ)
            branch = 1'b1;
            alu_control = 4'b0110; // SUB for comparison
        end
        
        default: begin
            // Keep defaults (NOP)
        end
    endcase
end

endmodule
