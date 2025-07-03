module Register_File(clk,rst,WE3,WD3,A1,A2,A3,RD1,RD2);

    input clk,rst,WE3;
    input [4:0]A1,A2,A3;
    input [31:0]WD3;
    output [31:0]RD1,RD2;

    reg [31:0] Register [31:0];
integer i;
always @(posedge clk) begin
    if (WE3 && A3 != 5'd0) begin
        Register[A3] <= WD3;
        $display("[WB] Register x%0d <= 0x%08h", A3, WD3);
    end
end
    assign RD1 = (rst==1'b0) ? 32'd0 : Register[A1];
    assign RD2 = (rst==1'b0) ? 32'd0 : Register[A2];

    initial begin
        Register[0] = 32'h00000000;
for(i=0; i<32; i=i+1)
Register[i] = 32'd0;

Register[1] = 32'd17;
    end

endmodule
