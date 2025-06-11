`timescale 1ns/1ps
module Single_Cycle_TB;

    reg clk, rst;
    integer cycle;

    Single_Cycle_Top uut(.clk(clk), .rst(rst));

    // Clock: 100MHz
    always #5 clk = ~clk;

    initial begin
        $dumpfile("single_cycle.vcd");
        $dumpvars(1, uut);
        clk = 0;
        rst = 1;
        cycle = 0;
        #15 rst = 0;

        // Run for fixed time
        #1000;
        $display("Final Reg[5] = %h", uut.Register_File.Register[5]);
        $writememh("mem_single.hex", uut.Data_Memory.mem);
        $finish;
    end

    always @(posedge clk) begin
        cycle = cycle + 1;
        $display("Cycle %0d | PC: 0x%h | Instr: 0x%h | Reg[2]: 0x%h",
                  cycle, uut.PC_Top, uut.RD_Instr, uut.Register_File.Register[2]);
    end

endmodule
