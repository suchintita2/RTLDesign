module Instruction_Memory(input wire rst, input wire [31:0] A, output wire [31:0] RD);  // PC is byte-addressed; instr mem is word-addressed (4-byte aligned)
  reg [31:0] mem [0:255];

  initial begin
    $readmemh("memfile.hex", mem);
  end

  assign RD = mem[A[9:2]];
endmodule
