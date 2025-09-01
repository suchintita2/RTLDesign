// PC Register: Holds the address of the current instruction
module pc (
    input                       clk,
    input                       reset,
    input                       stall_f,   // Stall signal from Hazard Unit
    input      [31:0]           pc_in,     // The next PC value from the mux
    output reg [31:0]           pc_out     // The current PC value
);

    always @(posedge clk) begin
        if (reset) begin
            pc_out <= 32'h00000000; // Reset to address 0
        end else if (!stall_f) begin
            pc_out <= pc_in;       // Update PC if not stalled
        end
        // If stalled, the register holds its current value
    end

endmodule
