// Testbench for Pipelined_Processor_Top
`timescale 1ns/1ps

module Pipelined_Processor_TB;
  reg clk;
  reg rst;

  // Instantiate the processor
  Pipelined_Processor_Top uut (
    .clk(clk),
    .rst(rst)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns period clock
  end

  // Reset and simulation control
  initial begin
    $display("\n--- Starting Pipelined Processor Simulation ---\n");

    // Apply reset
    rst = 0;
    #20;
    rst = 1;

    // Let simulation run for enough time to execute all instructions
    #5000;

    $display("\n--- Simulation Finished ---\n");
    $finish;
  end

  // Optional waveform dump
  initial begin
    $dumpfile("pipelined_processor.vcd");
    $dumpvars(0, Pipelined_Processor_TB);
  end
endmodule
