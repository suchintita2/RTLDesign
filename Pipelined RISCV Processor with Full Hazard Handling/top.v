module TopPipelineCPU(
    input clk,
    input rst,
    // Debug outputs
    output RegWrite_WB,
    output [4:0] WriteReg_WB,
    output [31:0] WriteData_WB,
    output MemWrite_MEM,
    output [31:0] MemAddr_MEM,
    output [31:0] MemWriteData_MEM,
    output [31:0] x2, x4, x5,
    output [31:0] mem1, mem8
);

    // Instantiate your CPU (change name/ports as needed)
    PipelineCPU Pipelined_Processor_Top (
        .clk(clk),
        .rst(rst)
        // ... other connections as needed
    );

    // Wire out debug signals from your CPU
    // You must ensure these are declared as wires/outputs in your PipelineCPU
    assign RegWrite_WB      = cpu.RegWrite_WB;
    assign WriteReg_WB      = cpu.WriteReg_WB;
    assign WriteData_WB     = cpu.WriteData_WB;
    assign MemWrite_MEM     = cpu.MemWrite_MEM;
    assign MemAddr_MEM      = cpu.MemAddr_MEM;
    assign MemWriteData_MEM = cpu.MemWriteData_MEM;

    // Expose some registers for viewing
    assign x2 = cpu.Register_File.Register[2];
    assign x4 = cpu.Register_File.Register[4];
    assign x5 = cpu.Register_File.Register[5];

    // Expose some memory locations for viewing
    assign mem1 = cpu.Data_Memory.mem[1]; // mem at address 0x04
    assign mem8 = cpu.Data_Memory.mem[8]; // mem at address 0x20

endmodule
