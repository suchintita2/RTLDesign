module Data_Memory(clk, rst, WE, WD, A, RD);
    input clk, rst, WE;
    input [31:0] A, WD;
    output [31:0] RD;

    reg [31:0] mem [1023:0];

    wire [31:0] word_addr = A[31:2];

    always @(posedge clk) begin
        if (WE) begin
            mem[word_addr] <= WD;
        end
    end

    assign RD = (~rst) ? 32'd0 : mem[word_addr];

    initial begin
        mem[7] = 32'h00000020;
    end
endmodule
