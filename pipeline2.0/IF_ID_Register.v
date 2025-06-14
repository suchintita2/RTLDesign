module IF_ID_Register(
  input wire clk, rst, EN, Flush,
  input wire [31:0] PCF, InstrF, PCPlus4F,
  output reg [31:0] PCD, InstrD, PCPlus4D
);
  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      PCD <= 0; InstrD <= 0; PCPlus4D <= 0;
    end else if (EN) begin
      if (Flush) begin
        InstrD <= 0;
      end else begin
        PCD <= PCF;
        InstrD <= InstrF;
        PCPlus4D <= PCPlus4F;
      end
    end
  end
endmodule
