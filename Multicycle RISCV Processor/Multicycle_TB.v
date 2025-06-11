`timescale 1ns/1ps
module Multicycle_TB;

    reg clk, rst;
    integer cycle;

    Multicycle_Top uut(.clk(clk), .rst(rst));

    always #10 clk = ~clk;  // 50 MHz

    initial begin
        $dumpfile("multicycle.vcd");
        $dumpvars(1, uut);
        clk = 0;
        rst = 1;
        cycle = 0;
        #15 rst = 0;

        #2000;
        $display("Final Reg[5] = %h", uut.rf.registers[5]);
        $writememh("mem_multi.hex", uut.memory.mem);
        $finish;
    end

    always @(posedge clk) begin
        cycle = cycle + 1;
        $display("Cycle %0d | State: %b | PC: 0x%h | IR: 0x%h | Reg[2]: 0x%h",
                  cycle, uut.control.state, uut.PC, uut.Instr, uut.rf.registers[2]);
    end

endmodule
