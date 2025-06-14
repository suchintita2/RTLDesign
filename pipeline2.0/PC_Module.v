module PC_Module(input wire clk, rst, EN, input wire [31:0] PC_Next, output reg [31:0] PC);
  always @(posedge clk) begin
    if (!rst)
      PC <= 0;
    else if (EN)
      PC <= PC_Next;
  end
endmodule
