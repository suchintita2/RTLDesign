module ALU(A, B, Result, ALUControl, OverFlow, Carry, Zero, Negative);
    input [31:0] A, B;
    input [2:0] ALUControl;
    output reg [31:0] Result;
    output OverFlow, Carry, Zero, Negative;

    wire [31:0] Sum;
    wire Cout;
    assign Sum = A + B;

    always @(*) begin
        case (ALUControl)
            3'b000: Result = A + B;              // ADD, ADDI
            3'b001: Result = A - B;              // SUB
            3'b010: Result = A & B;              // AND
            3'b011: Result = A | B;              // OR
            3'b101: Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT
            default: Result = 32'd0;
        endcase
    end

    assign OverFlow = ((A[31] ^ B[31]) == 0 && (A[31] ^ Result[31]) == 1);
    assign Carry = Cout;
    assign Zero = (Result == 32'b0);
    assign Negative = Result[31];
endmodule