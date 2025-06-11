module MEM_WB_Register(
    input clk, rst,
    input RegWrite_M,
    input [1:0] ResultSrc_M,
    input [31:0] ALUResult_M, ReadData_M, PCTarget_M,
    input [4:0] Rd_M,
    output reg RegWrite_W,
    output reg [1:0] ResultSrc_W,
    output reg [31:0] ALUResult_W, ReadData_W, PCTarget_W,
    output reg [4:0] Rd_W
);
    always @(posedge clk) begin
        if (~rst) begin
            RegWrite_W <= 1'b0;
            ResultSrc_W <= 2'b0;
            ALUResult_W <= 32'b0;
            ReadData_W <= 32'b0;
            PCTarget_W <= 32'b0;
            Rd_W <= 5'b0;
        end
        else begin
            RegWrite_W <= RegWrite_M;
            ResultSrc_W <= ResultSrc_M;
            ALUResult_W <= ALUResult_M;
            ReadData_W <= ReadData_M;
            PCTarget_W <= PCTarget_M;
            Rd_W <= Rd_M;
        end
    end
endmodule