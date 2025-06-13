module Register_File(
    input wire clk,
    input wire rst,
    input wire WE3,        // RegWrite signal
    input wire [4:0] A1,   // Read Address 1 (Rs1)
    input wire [4:0] A2,   // Read Address 2 (Rs2)
    input wire [4:0] A3,   // Write Address (Rd)
    input wire [31:0] WD3, // Write Data
    output wire [31:0] RD1, // Read Data 1
    output wire [31:0] RD2  // Read Data 2
);

    reg [31:0] registers [31:0];
    integer i; // Declare at module level

    // Write logic (synchronous)
    always @(posedge clk) begin
    if (~rst) begin  // Changed from 'rst' to '~rst'
        // Reset all registers to 0
        for (i = 0; i < 32; i = i + 1)
            registers[i] <= 32'b0;
    end else if (WE3 && A3 != 0) begin
        registers[A3] <= WD3;
    end
end

    // Read logic (combinational) - RISC-V x0 always returns 0
    assign RD1 = (A1 == 0) ? 32'b0 : registers[A1];
    assign RD2 = (A2 == 0) ? 32'b0 : registers[A2];

    // Initialize registers for simulation
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'b0;
    end

endmodule
