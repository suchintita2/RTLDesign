module ALU(
    input wire [31:0] A,
    input wire [31:0] B,
    input wire [2:0] ALUControl,
    output reg [31:0] Result,
    output wire Zero
);
    wire [31:0] sum;
    wire cout;
    
    assign {cout, sum} = (ALUControl[0]) ? A + (~B + 1) : A + B;
    
    always @(*) begin
        case (ALUControl)
            3'b000: Result = sum;           // ADD
            3'b001: Result = sum;           // SUB
            3'b010: Result = A & B;         // AND
            3'b011: Result = A | B;         // OR
            3'b101: Result = {{31{1'b0}}, sum[31]}; // SLT
            default: Result = 32'b0;
        endcase
    end
    
    assign Zero = (Result == 32'b0);
endmodule
