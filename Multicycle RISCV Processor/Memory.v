module Memory(
    input wire clk,
    input wire rst,
    input wire WE,      // MemWrite signal
    input wire [31:0] A,  // Address
    input wire [31:0] WD, // Write Data
    output wire [31:0] RD  // Read Data
);
    reg [31:0] mem [1023:0];
    
    always @(posedge clk) begin
        if(WE)
            mem[A[31:2]] <= WD;
    end
    
    assign RD = (~rst) ? 32'd0 : mem[A[31:2]];
    
    // Initialize memory (for simulation)
    initial begin
        $readmemh("memfile.hex", mem);
        // Add any additional initial values if needed
        mem[28] = 32'h00000020;
    end
endmodule
