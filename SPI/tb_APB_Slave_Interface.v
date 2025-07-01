// APB Slave Interface Verification Testbench
// Author: 22BEC0413
// Verified and Fixed Version

module tb_APB_Slave_Interface();

  // Inputs
  reg PCLK, PRESETn, PWRITE, PSEL, PENABLE, ss, receive_data, tip;
  reg [2:0] PADDR;
  reg [7:0] PWDATA, miso_data;
  
  // Outputs
  wire mstr, cpol, cpha, lsbfe, spiswai, spi_interrupt_request, PREADY, PSLVERR;
  wire send_data;
  wire [1:0] spi_mode;
  wire [2:0] sppr, spr;
  wire [7:0] PRDATA;
  wire [7:0] mosi_data;
  
  // Instantiate the DUT
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
    .spi_mode(spi_mode),
    .sppr(sppr),
    .spr(spr),
    .PRDATA(PRDATA),
    .mosi_data(mosi_data)
  );
  
  // Clock generation
  initial begin
    PCLK = 0;
    forever #5 PCLK = ~PCLK;
  end

  // APB Write Task
  task apb_write(input [2:0] addr, input [7:0] data);
    begin
      $display("[APB-WRITE] Addr:%h Data:%h", addr, data);
      @(posedge PCLK);
      PSEL = 1; PWRITE = 1; PADDR = addr; PWDATA = data; PENABLE = 0;
      @(posedge PCLK);
      PENABLE = 1;
      @(posedge PCLK);
      while (!PREADY) @(posedge PCLK); // Wait for PREADY
      PSEL = 0; PENABLE = 0; PWRITE = 0;
      @(posedge PCLK);
    end
  endtask

  // APB Read Task
  task apb_read(input [2:0] addr);
    begin
      $display("[APB-READ] Addr:%h", addr);
      @(posedge PCLK);
      PSEL = 1; PWRITE = 0; PADDR = addr; PENABLE = 0;
      @(posedge PCLK);
      PENABLE = 1;
      @(posedge PCLK);
      while (!PREADY) @(posedge PCLK);
      PSEL = 0; PENABLE = 0;
      @(posedge PCLK);
    end
  endtask

  // Main test sequence
  initial begin
    $display("22BEC0413");
    $display("=============================================");
    $display("APB SLAVE INTERFACE VERIFICATION TESTBENCH");
    $display("=============================================");
    
    // Initialize
    PRESETn = 0; 
    PWRITE = 0; PSEL = 0; PENABLE = 0;
    ss = 1; receive_data = 0; tip = 0;
    PADDR = 0; PWDATA = 0; 
    miso_data = 8'h55;  // Set to known value
    
    // Apply reset
    #15 PRESETn = 1;
    #10;
    
    // 1. Write configuration registers
    apb_write(3'b000, 8'hB5);  // CR1
    apb_write(3'b001, 8'h1B);  // CR2
    apb_write(3'b010, 8'h77);  // BR
    
    // 2. Verify mosi_data updates on write
    apb_write(3'b101, 8'hA9);
    #10;
    if (mosi_data === 8'hA9)
      $display("[SUCCESS] mosi_data = %h (expected A9)", mosi_data);
    else
      $display("[ERROR] mosi_data = %h (expected A9)", mosi_data);
    
    // 3. Verify mosi_data doesn't change on read
    apb_read(3'b101);
    #10;
    if (mosi_data === 8'hA9)
      $display("[SUCCESS] mosi_data unchanged after read");
    else
      $display("[ERROR] mosi_data changed unexpectedly");
    
    // 4. Verify new write updates mosi_data
    apb_write(3'b101, 8'h5A);
    #10;
    if (mosi_data === 8'h5A)
      $display("[SUCCESS] mosi_data = %h (expected 5A)", mosi_data);
    else
      $display("[ERROR] mosi_data = %h (expected 5A)", mosi_data);
    
    // 5. Verify reset behavior
    PRESETn = 0;
    #10;
    if (mosi_data === 8'h00)
      $display("[SUCCESS] mosi_data reset to 00");
    else
      $display("[ERROR] mosi_data not reset");
    
    $display("\n=== TEST SUMMARY ===");
    $display("All test sequences completed");
    $display("=============================================");
    #20 $finish;
  end

  // Monitor critical signals
  initial begin
    $monitor("T=%0t STATE=%b MODE=%b PRDATA=%h MOSI=%h DR=%h PREADY=%b",
             $time, dut.STATE, spi_mode, PRDATA, mosi_data, dut.SPI_DR, PREADY);
  end

  // Waveform dump
  initial begin
    $dumpfile("apb_slave_verified.vcd");
    $dumpvars(0, tb_APB_Slave_Interface);
  end

endmodule
