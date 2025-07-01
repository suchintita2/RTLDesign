// Testbench for Baud_Rate_Generator
// Author: 22BEC0413

module tb_Baud_Rate_Generator();

  // Inputs
  reg PCLK, PRESETn, spiswai, cpol, cpha, ss;
  reg [1:0] spi_mode;
  reg [2:0] sppr, spr;

  // Outputs
  wire sclk, flag_low, flags_low, flag_high, flags_high;
  wire [11:0] baud_rate_divisor;

  // Instantiate the DUT
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

  // Clock generation (100MHz)
  initial begin
    PCLK = 0;
    forever #5 PCLK = ~PCLK;
  end

  // Test sequence
  initial begin
    $display("22BEC0413");
    $display("=============================================");
    $display("BAUD RATE GENERATOR VERIFICATION TESTBENCH");
    $display("=============================================");

    // Initial values and reset
    PRESETn = 0; spiswai = 0; cpol = 0; cpha = 0; ss = 1;
    spi_mode = 2'b00; sppr = 0; spr = 0;
    $display("[INIT] Applying reset and initializing inputs");
    #20 PRESETn = 1;
    $display("[INIT] Reset released at T=%0t", $time);

    // PHASE 1: Default configuration (sel=0, cpol=0, cpha=0)
    $display("\n=== PHASE 1: DEFAULT CONFIGURATION (sel=0, cpol=0, cpha=0) ===");
    ss = 0; // Activate SPI
    #100;
    $display("[CHECK] At T=%0t: sclk=%b, divisor=%0d, sel=%b", $time, sclk, baud_rate_divisor, cpha^cpol);

    // PHASE 2: Change baud rate (sppr=1, spr=2)
    $display("\n=== PHASE 2: CHANGE BAUD RATE (sppr=1, spr=2) ===");
    sppr = 3'b001;
    spr = 3'b010;
    #400;
    $display("[CHECK] At T=%0t: sclk=%b, divisor=%0d, sel=%b", $time, sclk, baud_rate_divisor, cpha^cpol);

    // PHASE 3: Change SPI mode to sel=0 (cpol=1, cpha=1)
    $display("\n=== PHASE 3: CHANGE SPI MODE TO sel=0 (cpol=1, cpha=1) ===");
    cpol = 1;
    cpha = 1;
    #400;
    $display("[CHECK] At T=%0t: sclk=%b, divisor=%0d, sel=%b", $time, sclk, baud_rate_divisor, cpha^cpol);

    // PHASE 4: Change SPI mode to sel=1 (cpol=1, cpha=0)
    $display("\n=== PHASE 4: CHANGE SPI MODE TO sel=1 (cpol=1, cpha=0) ===");
    cpol = 1;
    cpha = 0;
    #400;
    $display("[CHECK] At T=%0t: sclk=%b, divisor=%0d, sel=%b", $time, sclk, baud_rate_divisor, cpha^cpol);

    // PHASE 5: Change SPI mode to sel=1 (cpol=0, cpha=1)
    $display("\n=== PHASE 5: CHANGE SPI MODE TO sel=1 (cpol=0, cpha=1) ===");
    cpol = 0;
    cpha = 1;
    #400;
    $display("[CHECK] At T=%0t: sclk=%b, divisor=%0d, sel=%b", $time, sclk, baud_rate_divisor, cpha^cpol);

    // PHASE 6: Enter wait mode (spiswai=1)
    $display("\n=== PHASE 6: ENTER WAIT MODE (spiswai=1) ===");
    spiswai = 1;
    #100;
    $display("[CHECK] At T=%0t: sclk=%b, divisor=%0d", $time, sclk, baud_rate_divisor);

    // PHASE 7: Reset behavior
    $display("\n=== PHASE 7: RESET BEHAVIOR ===");
    PRESETn = 0;
    #20;
    $display("[CHECK] After reset at T=%0t: sclk=%b, flag_low=%b, flag_high=%b", $time, sclk, flag_low, flag_high);

    $display("\n=== TEST SUMMARY ===");
    $display("All test sequences completed at T=%0t", $time);
    $display("=============================================");
    #20 $finish;
  end

  // Real-time monitoring of key outputs
  always @(posedge PCLK) begin
    if (flag_low)
      $display("[MONITOR] flag_low HIGH at T=%0t", $time);
    if (flag_high)
      $display("[MONITOR] flag_high HIGH at T=%0t", $time);
    if (flags_low)
      $display("[MONITOR] flags_low HIGH at T=%0t", $time);
    if (flags_high)
      $display("[MONITOR] flags_high HIGH at T=%0t", $time);
  end

  // Continuous signal monitoring
  initial begin
    $monitor("T=%0t sclk=%b divisor=%0d sppr=%b spr=%b cpol=%b cpha=%b ss=%b spi_mode=%b sel=%b flags[L:%b H:%b] [LS:%b HS:%b]",
      $time, sclk, baud_rate_divisor, sppr, spr, cpol, cpha, ss, spi_mode, cpha^cpol,
      flag_low, flag_high, flags_low, flags_high);
  end

  // Waveform dump for ModelSim/GTKWave
  initial begin
    $dumpfile("tb_baud_gen_verified.vcd");
    $dumpvars(0, tb_Baud_Rate_Generator);
  end

endmodule
