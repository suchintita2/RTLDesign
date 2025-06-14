module EX_MEM_Register(
  input wire clk,
  input wire RegWriteE, MemWriteE,
  input wire [1:0] ResultSrcE,
  input wire [31:0] ALUResultE, WriteDataE, PCPlus4E,
  input wire [4:0] RdE,
  output reg RegWriteM, MemWriteM,
  output reg [1:0] ResultSrcM,
  output reg [31:0] ALUResultM, WriteDataM, PCPlus4M,
  output reg [4:0] RdM
);
  always @(posedge clk) begin
    RegWriteM <= RegWriteE;
    MemWriteM <= MemWriteE;
    ResultSrcM <= ResultSrcE;
    ALUResultM <= ALUResultE;
    WriteDataM <= WriteDataE;
    PCPlus4M   <= PCPlus4E;
    RdM <= RdE;
  end
endmodule
