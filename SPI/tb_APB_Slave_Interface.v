module tb_APB_Slave_Interface();

  // Inputs
  reg PCLK, PRESETn, PWRITE, PSEL, PENABLE, ss, receive_data, tip;
  reg [2:0] PADDR;
  reg [7:0] PWDATA, miso_data;
  
  // Outputs
  wire mstr, cpol, cpha, lsbfe, spiswai, spi_interrupt_request, PREADY, PSLVERR;
  wire send_data, mosi_data;
  wire [1:0] spi_mode;
  wire [2:0] sppr, spr;
  wire [7:0] PRDATA;
  
  // Instantiate module
  APB_Slave_Interface dut (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PWRITE(PWRITE),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .ss(ss),
    .receive_data(receive_data),
    .tip(tip),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .miso_data(miso_data),
    .mstr(mstr),
    .cpol(cpol),
    .cpha(cpha),
    .lsbfe(lsbfe),
    .spiswai(spiswai),
    .spi_interrupt_request(spi_interrupt_request),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR),
    .send_data(send_data),
    .mosi_data(mosi_data),
    .spi_mode(spi_mode),
    .sppr(sppr),
    .spr(spr),
    .PRDATA(PRDATA)
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
    PWRITE = 0;
    PSEL = 0;
    PENABLE = 0;
    ss = 1;
    receive_data = 0;
    tip = 0;
    PADDR = 0;
    PWDATA = 0;
    miso_data = 0;
    
    // Reset
    #20 PRESETn = 1;
    
    // Write to CR1 register
    @(posedge PCLK);
    PSEL = 1;
    PWRITE = 1;
    PADDR = 3'b000;
    PWDATA = 8'hA5;
    @(posedge PCLK);
    PENABLE = 1;
    @(posedge PCLK);
    #1;
    
    // Read from status register
    PENABLE = 0;
    @(posedge PCLK);
    PWRITE = 0;
    PADDR = 3'b011;
    PENABLE = 1;
    
    // Test SPI mode transitions
    #50;
    ss = 0;
    receive_data = 1;
    miso_data = 8'hF0;
    
    #100 $finish;
  end
  
  // Monitor
  initial begin
    $monitor("T=%0t STATE=%b spi_mode=%b PRDATA=%h", $time, dut.STATE, spi_mode, PRDATA);
  end
  
  // Dump waves
  initial begin
    $dumpfile("tb_apb_slave.vcd");
    $dumpvars(0, tb_APB_Slave_Interface);
  end
endmodule
