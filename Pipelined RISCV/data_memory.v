// Data Memory (modeled as RAM)
module data_memory (
    input                       clk,
    input                       mem_write,    // Control signal to enable writing
    input      [31:0]           address,      // Address from ALU result
    input      [31:0]           write_data,   // Data to be written
    output     [31:0]           read_data     // Data read from memory
);
    // Declare a memory array (e.g., 1024 words)
    reg [31:0] mem [0:1023];

    // Asynchronous read (combinational)
    // Converts byte address to word address
    assign read_data = mem[address[31:2]];

    // Synchronous write (sequential)
    // Data is written only on the positive edge of the clock
    always @(posedge clk) begin
        if (mem_write) begin
            mem[address[31:2]] <= write_data;
        end
    end

endmodule
