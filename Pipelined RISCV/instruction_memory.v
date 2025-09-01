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
        $readmemh("memfile.hex",mem);
    end
    
    // Asynchronous read. The address from the PC is a byte address.
    // To convert it to a word address for our 32-bit memory array,
    // we drop the two least significant bits (divide by 4).
    assign instruction = mem[address[31:2]];

endmodule
