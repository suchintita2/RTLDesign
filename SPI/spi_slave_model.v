module spi_slave_model(
    input sclk, ss, mosi,
    output reg miso,
    input [7:0] response_data,
    output reg [7:0] received_data,
    output reg data_ready
);
    reg [7:0] tx_shift_reg;
    reg [7:0] rx_shift_reg;
    reg [2:0] bit_count;
    
    always @(posedge ss) begin
        // Initialize when slave select goes high (end of transaction)
        tx_shift_reg <= response_data;
        bit_count <= 0;
        miso <= response_data[7];
        if (bit_count == 0) begin
            received_data <= rx_shift_reg;
            data_ready <= 1'b1;
        end
    end
    
    always @(posedge sclk) begin
        if (!ss) begin
            // Shift data on clock edge
            tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
            miso <= tx_shift_reg[7];
            rx_shift_reg <= {rx_shift_reg[6:0], mosi};
            bit_count <= bit_count + 1;
        end
    end
    
    always @(posedge sclk) begin
        if (bit_count == 3'b000) 
            data_ready <= 1'b0;
    end
endmodule
