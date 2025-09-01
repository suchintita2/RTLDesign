// Register File
module register_file (
    input                       clk,
    input                       we3,         // Write Enable from WB stage
    input        [4:0]          a1, a2, a3,  // Read addresses (from ID), Write address (from WB)
    input        [31:0]         wd3,         // Write Data from WB stage
    output       [31:0]         rd1, rd2     // Read Data for ID stage
);

    reg [31:0] registers [0:31];

    // Asynchronous read for rd1 and rd2
    assign rd1 = (a1 == 5'b0) ? 32'b0 : registers[a1];
    assign rd2 = (a2 == 5'b0) ? 32'b0 : registers[a2];

    // Synchronous write
    always @(posedge clk) begin
        if (we3 && (a3 != 5'b0)) begin // Only write if enabled and not to x0
            registers[a3] <= wd3;
        end
    end
endmodule
