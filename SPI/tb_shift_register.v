module tb_shift_register();

  // Inputs
  reg PCLK, PRESETn, ss, send_data, lsbfe, cpha, cpol;
  reg flag_low, flag_high, flags_low, flags_high, miso, receive_data;
  reg [7:0] data_mosi;
  
  // Outputs
  wire [7:0] data_miso;
  wire mosi;
  
  // Instantiate module
  shift_register dut (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .ss(ss),
    .send_data(send_data),
    .lsbfe(lsbfe),
    .cpha(cpha),
    .cpol(cpol),
    .flag_low(flag_low),
    .flag_high(flag_high),
    .flags_low(flags_low),
    .flags_high(flags_high),
    .miso(miso),
    .receive_data(receive_data),
    .data_mosi(data_mosi),
    .data_miso(data_miso),
    .mosi(mosi)
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
    ss = 1;
    send_data = 0;
    lsbfe = 0;
    cpha = 0;
    cpol = 0;
    flag_low = 0;
    flag_high = 0;
    flags_low = 0;
    flags_high = 0;
    miso = 0;
    receive_data = 0;
    data_mosi = 0;
    
    // Reset
    #20 PRESETn = 1;
    
    // Test transmission
    #30;
    ss = 0;
    send_data = 1;
    data_mosi = 8'hAA;
    
    // Generate clock flags
    #50;
    flags_high = 1;
    #10 flags_high = 0;
    
    // Test reception
    #50;
    receive_data = 1;
    miso = 1;
    flag_high = 1;
    
    #200 $finish;
  end
  
  // Monitor
  initial begin
    $monitor("T=%0t mosi=%b data_miso=%h", $time, mosi, data_miso);
  end
  
  // Dump waves
  initial begin
    $dumpfile("tb_shift_reg.vcd");
    $dumpvars(0, tb_shift_register);
  end
endmodule
