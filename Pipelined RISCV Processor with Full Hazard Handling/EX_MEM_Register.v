module EX_MEM_Register(
    input clk, rst,
    input RegWrite_E, MemWrite_E, Branch_E, Jump_E,
    input [1:0] ResultSrc_E,
    input [31:0] ALUResult_E, WriteData_E, PCTarget_E,
    input [4:0] Rd_E,
    output reg RegWrite_M, MemWrite_M, Branch_M, Jump_M,
    output reg [1:0] ResultSrc_M,
    output reg [31:0] ALUResult_M, WriteData_M, PCTarget_M,
    output reg [4:0] Rd_M
);
    always @(posedge clk) begin
        if (~rst) begin
            RegWrite_M <= 1'b0;
            MemWrite_M <= 1'b0;
            Branch_M <= 1'b0;
            Jump_M <= 1'b0;
            ResultSrc_M <= 2'b0;
            ALUResult_M <= 32'b0;
            WriteData_M <= 32'b0;
            PCTarget_M <= 32'b0;
            Rd_M <= 5'b0;
        end
        else begin
            RegWrite_M <= RegWrite_E;
            MemWrite_M <= MemWrite_E;
            Branch_M <= Branch_E;
            Jump_M <= Jump_E;
            ResultSrc_M <= ResultSrc_E;
            ALUResult_M <= ALUResult_E;
            WriteData_M <= WriteData_E;
            PCTarget_M <= PCTarget_E;
            Rd_M <= Rd_E;
        end
    end
endmodule