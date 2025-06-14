module Data_Memory(
  input wire clk, WE,
  input wire [31:0] A, WD,
  output wire [31:0] RD
);
  reg [31:0] RAM [0:255];

  initial begin
    integer i;
    for (i = 0; i < 256; i = i + 1)
      RAM[i] = 0;
  end

  always @(posedge clk)
    if (WE) RAM[A[9:2]] <= WD;

  assign RD = RAM[A[9:2]];

  // Debug output for memory writes
  always @(posedge clk) begin
    if (WE)
      $display("[Cycle %0t] Memory[%h] <= %h", $time, A, WD);
  end
endmodule
