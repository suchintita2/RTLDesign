module Register_File(
    input clk, rst,
    input WE3,
    input [4:0] A1, A2, A3,
    input [31:0] WD3,
    output [31:0] RD1, RD2
);
    reg [31:0] Register [31:0];
    
    assign RD1 = Register[A1];
    assign RD2 = Register[A2];
integer i;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            for(i=0; i<32; i=i+1)
                Register[i] <= 32'b0;
        end
        else if(WE3 && A3 != 5'd0) begin
            Register[A3] <= WD3;
$display("Write Reg[%0d] <= 0x%h", A3, WD3);
end
    end
endmodule
