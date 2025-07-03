module ALU(A, B, Result, ALUControl, OverFlow, Carry, Zero, Negative);
    input [31:0] A, B;
    input [2:0] ALUControl;
    output reg [31:0] Result;
    output OverFlow, Carry, Zero, Negative;

    wire [32:0] Sum;
    
    assign Sum = {1'b0, A} + {1'b0, B};

    always @(*) begin
        case (ALUControl)
            3'b000: Result = A + B;                                              // ADD, ADDI
            3'b001: Result = A - B;                                              // SUB, BEQ comparison
            3'b010: Result = A & B;                                              // AND, ANDI
            3'b011: Result = A | B;                                              // OR, ORI
            3'b100: Result = A ^ B;                                              // XOR, XORI
            3'b101: Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;         // SLT, SLTI
            3'b110: Result = A << B[4:0];                                        // SLL, SLLI
            3'b111: Result = A >> B[4:0];                                        // SRL, SRLI
            default: Result = 32'd0;
        endcase
    end

    assign OverFlow = ((A[31] == B[31]) && (A[31] != Result[31])) && (ALUControl == 3'b000);
    assign Carry = Sum[32] && (ALUControl == 3'b000);
    assign Zero = (Result == 32'b0);
    assign Negative = Result[31];
endmodule
