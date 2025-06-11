`timescale 1ns/1ps
module Pipelined_TB;

    reg clk, rst;
    integer cycle;

    Pipelined_Processor_Top uut(.clk(clk), .rst(rst));

    always #2.5 clk = ~clk;  // 200 MHz

    initial begin
        $dumpfile("pipelined.vcd");
        $dumpvars(1, uut);
        clk = 0;
        rst = 1;
        cycle = 0;
        #10 rst = 0;

        #1000;
        $display("Final Reg[5] = %h", uut.Register_File.Register[5]);
        $writememh("mem_pipe.hex", uut.Data_Memory.mem);
        $finish;
    end

    always @(posedge clk) begin
        cycle = cycle + 1;
        $display("Cycle %0d | IF_PC: 0x%h | ID_Inst: 0x%h | EX_ALU: 0x%h | MEM_Addr: 0x%h | WB_Data: 0x%h",
                  cycle, uut.PC_F, uut.Instr_D, uut.ALUResult_E, uut.ALUResult_M, uut.Result_W);
        if (uut.Stall_F || uut.Stall_D)
            $display("Pipeline stalled at cycle %0d", cycle);
    end

endmodule
