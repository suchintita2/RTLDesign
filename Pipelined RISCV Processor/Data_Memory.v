module Data_Memory(clk, rst, WE, WD, A, RD);
    input clk, rst, WE;
    input [31:0] A, WD;
    output [31:0] RD;

    reg [31:0] mem [0:1023];
        integer i;

    always @(posedge clk) begin
        if (WE && rst) begin
            mem[A[31:2]] <= WD;
            $display("[MEM] mem[0x%0h] <= 0x%08h", A, WD);
        end
if (A[1:0] != 2'b00) begin
    $display("?? Misaligned store at Addr=%h", A);
end
    end

    assign RD = (rst == 0) ? 32'd0 : mem[A[31:2]];

    initial begin
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 32'd0;
mem[5] = 32'h11;
    end
endmodule