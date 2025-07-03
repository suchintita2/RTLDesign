module writeback_cycle(
    input clk, rst,
    input [1:0] ResultSrcW,
    input [31:0] PCPlus4W, ALU_ResultW, ReadDataW,
    output [31:0] ResultW
);
    assign ResultW = (ResultSrcW == 2'b00) ? ALU_ResultW :
                     (ResultSrcW == 2'b01) ? ReadDataW :
                     (ResultSrcW == 2'b10) ? PCPlus4W :
                     32'b0;
endmodule
