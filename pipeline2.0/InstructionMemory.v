module InstructionMemory (
    input [31:0] Address,
    output [31:0] Instruction
);

    reg [31:0] mem [0:1023]; // 1KB memory

    // Initialize with some sample instructions
    initial begin
        $readmemh("memfile.hex", mem);
end

    assign Instruction = mem[Address[11:2]]; // Word-aligned access
endmodule
