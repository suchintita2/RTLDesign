module Main_Decoder(
    input [6:0] Op,
    output RegWrite, ALUSrc, MemWrite, Branch,
    output [1:0] ImmSrc, ResultSrc, ALUOp
);
    // Add I-type (0010011) support for RegWrite and ALUSrc
    assign RegWrite = (Op == 7'b0000011 | Op == 7'b0110011 | Op == 7'b0010011 | Op == 7'b1101111);
    assign ImmSrc = (Op == 7'b0100011) ? 2'b01 :
                    (Op == 7'b1100011) ? 2'b10 :
(Op == 7'b1101111) ? 2'b11:
                    2'b00;
    assign ALUSrc = (Op == 7'b0000011 | Op == 7'b0100011 | Op == 7'b0010011);
    assign MemWrite = (Op == 7'b0100011);
    assign ResultSrc = (Op == 7'b0000011) ? 2'b01 :
                       (Op == 7'b1101111) ? 2'b10 :
                       2'b00;
    assign Branch = (Op == 7'b1100011);
    assign ALUOp = (Op == 7'b0110011) ? 2'b10 :
                   (Op == 7'b0010011) ? 2'b10 :
                   (Op == 7'b1100011) ? 2'b01 :
                   2'b00;
endmodule
