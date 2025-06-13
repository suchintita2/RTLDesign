`timescale 1ns/1ps

module Multicycle_TB;

  reg clk, rst;
  integer cycle;

  // Instantiate your top module
  Multicycle_Top uut(.clk(clk), .rst(rst));

  // Clock generation (50MHz)
  always #10 clk = ~clk;

  initial begin
    $dumpfile("multicycle.vcd");
    $dumpvars(1, uut);

    clk = 0;
    rst = 0;
    cycle = 0;

    #20 rst = 1;

    // Run for sufficient time
    #2000;

    $display("\nFinal Register States:");
    $display("x1 (link, JAL) = 0x%08h", uut.rf.registers[1]);
    $display("x2 = 0x%08h", uut.rf.registers[2]);
    $display("x4 = 0x%08h", uut.rf.registers[4]);
    $display("x5 = 0x%08h", uut.rf.registers[5]);
    $display("x7 = 0x%08h", uut.rf.registers[7]);
    $display("x11 = 0x%08h", uut.rf.registers[11]);

    // Save memory contents for inspection
    $writememh("mem_multi.hex", uut.memory.mem);

    $finish;
  end

  // Print on every rising clock edge
  always @(posedge clk) begin
    cycle = cycle + 1;
    $display("\nCycle %0d | State: %02d | PC: 0x%08h | Instr: 0x%08h", 
      cycle, uut.control.state, uut.PC, uut.Instr);
    $display("  OldPC:    0x%08h | ALUResult: 0x%08h | ALUOut: 0x%08h | Result: 0x%08h",
      uut.OldPC, uut.ALUResult, uut.ALUOut, uut.Result);
    $display("  x1(link): 0x%08h | x2: 0x%08h | x4: 0x%08h | x5: 0x%08h | x7: 0x%08h | x11: 0x%08h",
      uut.rf.registers[1], uut.rf.registers[2], uut.rf.registers[4], uut.rf.registers[5],
      uut.rf.registers[7], uut.rf.registers[11]);
    $display("  ALUSrcA: %b | ALUSrcB: %02b | ALUControl: %03b | RegWrite: %b | MemWrite: %b | ResultSrc: %02b | Zero: %b",
      uut.control.ALUSrcA, uut.control.ALUSrcB, uut.control.ALUControl,
      uut.control.RegWrite, uut.control.MemWrite, uut.control.ResultSrc, uut.Zero);
  end

endmodule
