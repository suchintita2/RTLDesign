// ALU Control Unit
module alu_control_unit (
    input      [1:0]            alu_op,     // From main Control Unit
    input      [2:0]            funct3,     // From instruction
    input                       funct7_5,   // Bit 5 of funct7 (for SUB/SRA)
    output reg [3:0]            alu_control // To the ALU
);
    // Define ALU operations
    parameter ALU_ADD  = 4'b0000;
    parameter ALU_SUB  = 4'b0001;
    parameter ALU_AND  = 4'b0010;
    parameter ALU_OR   = 4'b0011;
    parameter ALU_XOR  = 4'b0100;
    parameter ALU_SLT  = 4'b0101;
    parameter ALU_SLTU = 4'b0110;
    parameter ALU_SLL  = 4'b0111;
    parameter ALU_SRL  = 4'b1000;
    parameter ALU_SRA  = 4'b1001;
    
    always @(*) begin
        case (alu_op)
            2'b00: // For Loads and Stores
                alu_control = ALU_ADD;
            2'b01: // For Branches
                alu_control = ALU_SUB;
            2'b10: begin // For R-Type
                case (funct3)
                    3'b000: alu_control = funct7_5 ? ALU_SUB : ALU_ADD; // ADD/SUB
                    3'b001: alu_control = ALU_SLL;
                    3'b010: alu_control = ALU_SLT;
                    3'b011: alu_control = ALU_SLTU;
                    3'b100: alu_control = ALU_XOR;
                    3'b101: alu_control = funct7_5 ? ALU_SRA : ALU_SRL; // SRL/SRA
                    3'b110: alu_control = ALU_OR;
                    3'b111: alu_control = ALU_AND;
                    default: alu_control = 4'bxxxx;
                endcase
            end
            2'b11: begin // For I-Type
                 case (funct3)
                    3'b000: alu_control = ALU_ADD;  // ADDI
                    3'b010: alu_control = ALU_SLT;  // SLTI
                    3'b011: alu_control = ALU_SLTU; // SLTIU
                    3'b100: alu_control = ALU_XOR;  // XORI
                    3'b110: alu_control = ALU_OR;   // ORI
                    3'b111: alu_control = ALU_AND;  // ANDI
                    3'b001: alu_control = ALU_SLL;  // SLLI
                    3'b101: alu_control = funct7_5 ? ALU_SRA : ALU_SRL; // SRLI/SRAI
                    default: alu_control = 4'bxxxx;
                 endcase
            end
            default: alu_control = 4'bxxxx;
        endcase
    end

endmodule
