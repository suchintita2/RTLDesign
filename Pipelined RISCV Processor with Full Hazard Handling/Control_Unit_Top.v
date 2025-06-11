module Control_Unit_Top(Op, RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, Jump, funct3, funct7, ALUControl);
    input [6:0] Op, funct7;
    input [2:0] funct3;
    output RegWrite, ALUSrc, MemWrite, Branch, Jump;
    output [1:0] ImmSrc, ResultSrc;
    output [2:0] ALUControl;

    wire [1:0] ALUOp;

    Main_Decoder Main_Decoder(
        .Op(Op),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .Jump(Jump),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp)
    );

    ALU_Decoder ALU_Decoder(
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .op(Op),
        .ALUControl(ALUControl)
    );
endmodule
