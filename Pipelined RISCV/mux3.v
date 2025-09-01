// Mux3: Selects one of three inputs
module mux3 #(
    parameter WIDTH = 32
) (
    input      [WIDTH-1:0]      d0,        // Input 0
    input      [WIDTH-1:0]      d1,        // Input 1
    input      [WIDTH-1:0]      d2,        // Input 2
    input      [1:0]            s,         // 2-bit select signal
    output reg [WIDTH-1:0]      y          // Output
);

    always @(*) begin
        case (s)
            2'b00:  y = d0;
            2'b01:  y = d1;
            2'b10:  y = d2;
            default: y = d0; // Default case to avoid latches
        endcase
    end

endmodule
