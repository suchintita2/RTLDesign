module Register_File(
  input wire clk,
  input wire [4:0] A1, A2, A3,
  input wire [31:0] WD3,
  input wire WE3,
  output wire [31:0] RD1, RD2
);
  reg [31:0] rf[31:0];
  assign RD1 = rf[A1];
  assign RD2 = rf[A2];
  always @(posedge clk)
    if (WE3) rf[A3] <= WD3;
endmodule
