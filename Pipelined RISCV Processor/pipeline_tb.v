`timescale 1ns / 1ps

module tb;

  reg clk = 0;
  reg rst = 0;
  integer cycle = 0;

  wire [31:0] ResultW, ALUResultW, ReadDataW, PCPlus4W, PCF_out;
  wire RegWriteW;
  wire [4:0] RDW;
  wire [1:0] ResultSrcW;

  // Instantiate the DUT
  Pipeline_top uut (
    .clk(clk),
    .rst(rst),
    .ResultW(ResultW),
    .ALUResultW(ALUResultW),
    .ReadDataW(ReadDataW),
    .PCPlus4W(PCPlus4W),
    .RegWriteW(RegWriteW),
    .RDW(RDW),
    .ResultSrcW(ResultSrcW),
    .PCF_out(PCF_out)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Reset
  initial begin
    $display("=== Starting Simulation ===");
    $dumpfile("pipeline.vcd");
    $dumpvars(0, tb);

    #15 rst = 1;
  end

  // Monitor output
  always @(posedge clk) begin
    cycle = cycle + 1;
    $display("\nCycle %0d", cycle);
    $display("PC = 0x%08x", PCF_out);
    $display("RegWriteW = %b | RDW = x%0d | ResultW = 0x%08x", RegWriteW, RDW, ResultW);
    $display("ResultSrcW = %b | ALU = 0x%08x | Mem = 0x%08x | PC+4 = 0x%08x",
              ResultSrcW, ALUResultW, ReadDataW, PCPlus4W);
$display("x1 = %h, x2 = %h, x4 = %h, x5 = %h, x7 = %h, x11 = %h",
                 uut.Decode.rf.Register[1],
                 uut.Decode.rf.Register[2],
                 uut.Decode.rf.Register[4],
                 uut.Decode.rf.Register[5],
                 uut.Decode.rf.Register[7],
                 uut.Decode.rf.Register[11]);

    if (RegWriteW) begin
      case (RDW)
        1: $display("  --> x1 updated = 0x%08x", ResultW);
        2: $display("  --> x2 updated = 0x%08x", ResultW);
        3: $display("  --> x3 updated = 0x%08x", ResultW);
        4: $display("  --> x4 updated = 0x%08x", ResultW);
        5: $display("  --> x5 updated = 0x%08x", ResultW);
        6: $display("  --> x6 updated = 0x%08x", ResultW);
        7: $display("  --> x7 updated = 0x%08x", ResultW);
      endcase
    end

    if (cycle > 50) begin
      $display("=== Simulation Ended ===");
      $finish;
    end
  end

endmodule