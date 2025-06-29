module tb_spi_slave_control_select();

  // Inputs
  reg PCLK, PRESETn, mstr, spiswai, send_data;
  reg [1:0] spi_mode;
  reg [11:0] baud_rate_divisor;
  
  // Outputs
  wire ss, tip;
  wire receive_data;
  
  // Instantiate module
  spi_slave_control_select dut (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .mstr(mstr),
    .spiswai(spiswai),
    .send_data(send_data),
    .spi_mode(spi_mode),
    .baud_rate_divisor(baud_rate_divisor),
    .ss(ss),
    .tip(tip),
    .receive_data(receive_data)
  );
  
  // Clock generation
  initial begin
    PCLK = 0;
    forever #5 PCLK = ~PCLK;
  end
  
  // Test sequence
  initial begin
    // Initialize
    PRESETn = 0;
    mstr = 0;
    spiswai = 0;
    send_data = 0;
    spi_mode = 2'b00;
    baud_rate_divisor = 12'd100;
    
    // Reset
    #20 PRESETn = 1;
    
    // Test slave select
    #30;
    mstr = 1;
    send_data = 1;
    
    // Test receive timing
    #100;
    send_data = 0;
    
    // Change mode
    #50;
    spi_mode = 2'b10;
    spiswai = 1;
    
    #200 $finish;
  end
  
  // Monitor
  initial begin
    $monitor("T=%0t ss=%b tip=%b recv_data=%b", $time, ss, tip, receive_data);
  end
  
  // Dump waves
  initial begin
    $dumpfile("tb_slave_ctrl.vcd");
    $dumpvars(0, tb_spi_slave_control_select);
  end
endmodule
