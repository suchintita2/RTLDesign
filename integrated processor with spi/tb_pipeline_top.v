module tb_pipeline_top();
    reg clk, rst;
    wire sclk, ss, mosi, spi_interrupt;
    reg miso;
    wire [31:0] ResultW;
    
    // SPI slave model signals
    reg [7:0] slave_response;
    wire [7:0] slave_received;
    wire slave_data_ready;
    
    // DUT instantiation
    Pipeline_top dut(
        .clk(clk), 
        .rst(rst), 
        .miso(miso),
        .sclk(sclk), 
        .ss(ss), 
        .mosi(mosi),
        .spi_interrupt(spi_interrupt), 
        .ResultW(ResultW)
    );
    
    // SPI Slave Model
    spi_slave_model spi_slave(
        .sclk(sclk),
        .ss(ss),
        .mosi(mosi),
        .miso(miso),
        .response_data(slave_response),
        .received_data(slave_received),
        .data_ready(slave_data_ready)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Test sequence
    initial begin
        // Initialize
        clk = 0;
        rst = 0;
        slave_response = 8'h55;
        
        // Reset sequence
        #10 rst = 1;
        $display("Reset released at time %0t", $time);
        
        // Monitor SPI transactions
        $monitor("Time=%0t, SCLK=%b, SS=%b, MOSI=%b, MISO=%b, SPI_INT=%b", 
                 $time, sclk, ss, mosi, miso, spi_interrupt);
        
        // Wait for SPI transactions
        @(negedge ss);
        $display("SPI transaction started at time %0t", $time);
        
        // Change slave response for next transaction
        #1000 slave_response = 8'hAA;
        
        #10000 $finish;
    end
    
    // Display received data
    always @(posedge slave_data_ready) begin
        $display("Slave received: 0x%02h at time %0t", slave_received, $time);
    end
    
    // VCD dump for waveform analysis
    initial begin
        $dumpfile("pipeline_spi.vcd");
        $dumpvars(0, tb_pipeline_top);
    end
endmodule
