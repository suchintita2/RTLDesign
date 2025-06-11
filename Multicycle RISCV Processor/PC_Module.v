module PC_Module(
    input wire clk,
    input wire rst,
    input wire EN,   // PCWrite enable signal
    input wire [31:0] PC_Next,
    output reg [31:0] PC
);
    always @(posedge clk) begin
        if (~rst)
            PC <= 32'b0;
        else if (EN)
            PC <= PC_Next;
    end
endmodule
