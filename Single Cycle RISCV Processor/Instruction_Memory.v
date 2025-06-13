module Instruction_Memory(rst,A,RD);

  input rst;
  input [31:0]A;
  output [31:0]RD;

  reg [31:0] mem [1023:0];
  
assign RD = mem[A[31:2]];integer i;
  initial begin
    $readmemh("memfile.hex",mem);
for(i=0; i<11; i=i+1)
	$display("mem[%0d] = %h",i,mem[i]);
  end
endmodule
