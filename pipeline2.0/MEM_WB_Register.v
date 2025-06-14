module MEM_WB_Register(
  input wire clk,
  input wire RegWriteM,
  input wire [1:0] ResultSrcM,
  input wire [31:0] ReadDataW, ALUResultM, PCPlus4M,
  input wire [4:0] RdM,
  output reg RegWriteW,
  output reg [1:0] ResultSrcW,
  output reg [31:0] ResultW, PCPlus4W,
  output reg [4:0] RdW
);
  always @(posedge clk) begin
    RegWriteW <= RegWriteM;
    ResultSrcW <= ResultSrcM;
    ResultW <= ReadDataW;  // selected later via Mux3to1
    PCPlus4W <= PCPlus4M;
    RdW <= RdM;
  end
endmodule
