module ALU (
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [3:0] ALUControl,
    output Zero,
    output reg [31:0] ALUResult
);

    always @(*) begin
        case (ALUControl)
            4'b0000: ALUResult = SrcA & SrcB;  // AND
            4'b0001: ALUResult = SrcA | SrcB;  // OR
            4'b0010: ALUResult = SrcA + SrcB;  // ADD
            4'b0110: ALUResult = SrcA - SrcB;  // SUB
            4'b0111: ALUResult = (SrcA < SrcB) ? 32'b1 : 32'b0; // SLT
            4'b1100: ALUResult = ~(SrcA | SrcB); // NOR
            default: ALUResult = 32'b0;
        endcase
    end

    assign Zero = (ALUResult == 32'b0);
endmodule
