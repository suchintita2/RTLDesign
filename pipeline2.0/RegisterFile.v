module RegisterFile (
    input clk,
    input reset,
    input RegWrite,            // Write enable
    input [4:0] ReadReg1,      // Read register 1
    input [4:0] ReadReg2,      // Read register 2
    input [4:0] WriteReg,      // Write register
    input [31:0] WriteData,    // Write data
    output [31:0] ReadData1,   // Read data 1
    output [31:0] ReadData2    // Read data 2
);

    reg [31:0] registers [0:31]; // 32 registers x 32 bits

    // Initialize registers to 0 on reset
    integer i;
    always @(posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end
    end

    // Read operations (asynchronous)
    assign ReadData1 = registers[ReadReg1];
    assign ReadData2 = registers[ReadReg2];

    // Write operation (synchronous)
    always @(posedge clk) begin
        if (RegWrite && WriteReg != 0) // Register 0 is always 0
            registers[WriteReg] <= WriteData;
    end
endmodule
