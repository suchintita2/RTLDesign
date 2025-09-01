// Adder: Performs 32-bit addition
module adder (
    input      [31:0]           a,         // First operand
    input      [31:0]           b,         // Second operand
    output     [31:0]           y          // Result (a + b)
);

    // Combinational logic for addition
    assign y = a + b;

endmodule
