module Register_File(
    input wire clk,
    input wire rst,
    input wire WE3,    // RegWrite signal
    input wire [4:0] A1,  // Read Address 1
    input wire [4:0] A2,  // Read Address 2
    input wire [4:0] A3,  // Write Address
    input wire [31:0] WD3, // Write Data
    output wire [31:0] RD1, // Read Data 1
    output wire [31:0] RD2  // Read Data 2
);
    reg [31:0] registers [31:0];
    
    always @(posedge clk) begin
        if(WE3 && A3 != 0)  // Don't write to register 0
            registers[A3] <= WD3;
    end
    
    assign RD1 = (~rst) ? 32'd0 : registers[A1];
    assign RD2 = (~rst) ? 32'd0 : registers[A2];
    
    // Initialize registers (for simulation)
    initial begin
        registers[0] = 32'b0;  // $zero
        registers[5] = 32'h00000005;
        registers[6] = 32'h00000004;
    end
endmodule
