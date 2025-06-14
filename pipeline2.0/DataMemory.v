module DataMemory (
    input clk,
    input MemWrite,
    input [31:0] Address,
    input [31:0] WriteData,
    output [31:0] ReadData
);

    reg [31:0] mem [0:1023]; // 1KB memory

    // Read operation (asynchronous)
    assign ReadData = mem[Address[11:2]]; // Word-aligned access

    // Write operation (synchronous)
    always @(posedge clk) begin
        if (MemWrite)
            mem[Address[11:2]] <= WriteData;
    end
endmodule
