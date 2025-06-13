module ALU_Decoder(
    input [1:0] ALUOp,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [2:0] ALUControl
);
    always @(*) begin
        case(ALUOp)
            2'b00: ALUControl = 3'b000;  // ADD (for load/store)
            2'b01: ALUControl = 3'b001;  // SUB (for branch)
            2'b10: begin                 // R-type instructions
                case({funct7[5], funct3})
                    4'b0000: ALUControl = 3'b000; // ADD
                    4'b1000: ALUControl = 3'b001; // SUB
                    4'b0111: ALUControl = 3'b010; // AND
                    4'b0110: ALUControl = 3'b011; // OR
                    4'b0010: ALUControl = 3'b101; // SLT
                    default: ALUControl = 3'b000; // Default to ADD
                endcase
            end
            default: ALUControl = 3'b000;
        endcase
    end
endmodule
