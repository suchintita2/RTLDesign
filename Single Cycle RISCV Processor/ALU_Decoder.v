module ALU_Decoder(
    input [1:0] ALUOp,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [2:0] ALUControl
);
    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 3'b000;  // ADD (for lw/sw)
            2'b01: ALUControl = 3'b001;  // SUB (for branches)

            2'b10: begin  // R-type or I-type
                case (funct3)
                    3'b000: ALUControl = (funct7[5]) ? 3'b001 : 3'b000; // SUB : ADD
                    3'b111: ALUControl = 3'b010; // AND
                    3'b110: ALUControl = 3'b011; // OR
                    3'b100: ALUControl = 3'b100; // XOR
                    3'b001: ALUControl = 3'b101; // SLL
                    3'b101: ALUControl = (funct7[5]) ? 3'b111 : 3'b110; // SRA : SRL
                    3'b010: ALUControl = 3'b000; // SLT (treated as SUB or handled in ALU)
                    3'b011: ALUControl = 3'b000; // SLTU
                    default: ALUControl = 3'b000;
                endcase
            end

            default: ALUControl = 3'b000; // Fallback to ADD
        endcase
    end
endmodule
