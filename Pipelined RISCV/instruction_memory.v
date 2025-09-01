// Instruction Memory (modeled as a ROM)
module instruction_memory (
    input      [31:0]           address,     // Input: PC address
    output     [31:0]           instruction  // Output: Instruction data
);
    // Declare a memory array to store the program (e.g., 1024 words)
    reg [31:0] mem [0:1023];

    // Pre-load the memory with a simple program at initialization.
    // This is a non-synthesizable block for simulation purposes.
    initial begin
        // Program:
        // addi x2, x0, 5      // x2 = 5
        // addi x3, x0, 10     // x3 = 10
        // add  x4, x2, x3     // x4 = 5 + 10 = 15
        // sw   x4, 12(x0)     // mem[12] = 15
        mem[0] = 32'h00500113;
        mem[1] = 32'h00A00193;
        mem[2] = 32'h00310233;
        mem[3] = 32'h00F02623;
    end
    
    // Asynchronous read. The address from the PC is a byte address.
    // To convert it to a word address for our 32-bit memory array,
    // we drop the two least significant bits (divide by 4).
    assign instruction = mem[address[31:2]];

endmodule
