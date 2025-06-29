module tb_Baud_Rate_Generator();

  // Inputs
  reg PCLK, PRESETn, spiswai, cpol, cpha, ss;
  reg [1:0] spi_mode;
  reg [2:0] sppr, spr;
  
  // Outputs
  wire sclk, flag_low, flags_low, flag_high, flags_high;
  wire [11:0] baud_rate_divisor;
  
  // Instantiate module
  Baud_Rate_Generator dut (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .spiswai(spiswai),
    .cpol(cpol),
    .cpha(cpha),
    .ss(ss),
    .spi_mode(spi_mode),
    .sppr(sppr),
    .spr(spr),
    .sclk(sclk),
    .flag_low(flag_low),
    .flags_low(flags_low),
    .flag_high(flag_high),
    .flags_high(flags_high),
    .baud_rate_divisor(baud_rate_divisor)
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
    spiswai = 0;
    cpol = 0;
    cpha = 0;
    ss = 1;
    spi_mode = 2'b00;
    sppr = 0;
    spr = 0;
    
    // Reset
    #20 PRESETn = 1;
    
    // Test different configurations
    #100;
    sppr = 3'b001;
    spr = 3'b010;
    ss = 0;
    
    // Change mode
    #200;
    cpol = 1;
    cpha = 1;
    
    #200 $finish;
  end
  
  // Monitor
  initial begin
    $monitor("T=%0t sclk=%b divisor=%0d", $time, sclk, baud_rate_divisor);
  end
  
  // Dump waves
  initial begin
    $dumpfile("tb_baud_gen.vcd");
    $dumpvars(0, tb_Baud_Rate_Generator);
  end
endmodule
