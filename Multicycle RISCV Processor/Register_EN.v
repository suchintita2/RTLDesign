module Register_EN(
    input wire clk,
    input wire rst,
    input wire EN,
    input wire [31:0] D,
    output reg [31:0] Q
);
    always @(posedge clk) begin
        if (~rst)
            Q <= 32'b0;
        else if (EN)
            Q <= D;
    end
endmodule
