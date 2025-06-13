module Data_Memory(clk, rst, WE, WD, A, RD);
    input clk, rst, WE;
    input [31:0] WD, A;
    output [31:0] RD;

    reg [31:0] mem [0:1023];
    wire [9:0] addr = A[11:2];  // Word address (assuming 4KB memory)

    always @(posedge clk) begin
        if (WE)
            mem[addr] <= WD;
    end

    assign RD = mem[addr];

    initial begin
        mem[1] = 32'h00000020;

        // Initialize other addresses as needed
    end
endmodule
