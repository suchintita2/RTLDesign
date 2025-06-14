module Register_File(
  input wire clk,
  input wire [4:0] A1, A2, A3,
  input wire [31:0] WD3,
  input wire WE3,
  output wire [31:0] RD1, RD2
);
  reg [31:0] rf[31:0];

  initial begin
    integer i;
    for (i = 0; i < 32; i = i + 1)
      rf[i] = 0;
  end

  assign RD1 = (A1 == 0) ? 32'b0 : rf[A1];
  assign RD2 = (A2 == 0) ? 32'b0 : rf[A2];

  always @(posedge clk)
    if (WE3 && A3 != 0) rf[A3] <= WD3;

  // Debug output for simulation
  always @(posedge clk) begin
    $display("[Cycle %0t] x1=%h x2=%h x4=%h x5=%h x6=%h x7=%h x11=%h", $time,
             rf[1], rf[2], rf[4], rf[5], rf[6], rf[7], rf[11]);
  end
endmodule
