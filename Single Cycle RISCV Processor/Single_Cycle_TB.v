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
#5 rst = 0;

        // Run for fixed time
        #1000;
        $display("Final Reg[5] = %h", uut.Register_File.Register[5]);
        $writememh("mem_single.hex", uut.Data_Memory.mem);
        $finish;
    end

always @(posedge clk) begin
    cycle = cycle + 1;
$display("Cycle %0d | PC: 0x%h | Instr: 0x%h | x1: 0x%h | x2: 0x%h | x4: 0x%h | x5: 0x%h | x7: 0x%h | x11: 0x%h",
         cycle, uut.PC_Top, uut.RD_Instr,
         uut.Register_File.Register[1],
         uut.Register_File.Register[2],
         uut.Register_File.Register[4],
         uut.Register_File.Register[5],
         uut.Register_File.Register[7],
         uut.Register_File.Register[11]);    
$display("PC: 0x%h | Instr: 0x%h | ALUResult: 0x%h | ReadData: 0x%h | Result: 0x%h | RegWrite: %b | ResultSrc: %b | ALUControl: %b",
         uut.PC_Top, uut.RD_Instr, uut.ALUResult, uut.ReadData, uut.Result, uut.RegWrite, uut.ResultSrc, uut.ALUControl_Top);

end
        
endmodule
