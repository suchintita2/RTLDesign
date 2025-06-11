module PC_Module(
    input clk,
    input rst,
    input Stall,           // New input: when 1, PC holds its value
    output reg [31:0] PC,
    input [31:0] PC_Next
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            PC <= 32'b0;         // Asynchronous reset: set PC to 0 on reset
        else if (!Stall)
            PC <= PC_Next;       // Update PC only if not stalled
        // else: hold current PC (do nothing)
    end
endmodule

