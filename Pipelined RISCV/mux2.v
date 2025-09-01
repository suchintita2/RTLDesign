// Mux2: Selects one of two inputs
module mux2 #(
    parameter WIDTH = 32 // Make the module reusable for different data widths
) (
    input      [WIDTH-1:0]      d0,        // Input 0
    input      [WIDTH-1:0]      d1,        // Input 1
    input                       s,         // Select signal
    output     [WIDTH-1:0]      y          // Output
);

    // If s=0, y=d0; if s=1, y=d1
    assign y = s ? d1 : d0;

endmodule
