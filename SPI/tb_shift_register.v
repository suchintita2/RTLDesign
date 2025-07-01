// ====================================================
// Testbench for shift_register module
// Author: 22BEC0413
// ====================================================

module tb_shift_register();

    // Inputs
    reg PCLK, PRESETn, ss, send_data, lsbfe, cpha, cpol;
    reg flag_high, flags_high, miso, receive_data;
    reg [7:0] data_mosi;

    // Outputs
    wire [7:0] data_miso;
    wire mosi;

    // Instantiate DUT
    shift_register dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .ss(ss),
        .send_data(send_data),
        .lsbfe(lsbfe),
        .cpha(cpha),
        .cpol(cpol),
        .flag_high(flag_high),
        .flags_high(flags_high),
        .miso(miso),
        .receive_data(receive_data),
        .data_mosi(data_mosi),
        .data_miso(data_miso),
        .mosi(mosi)
    );

    // Clock generation (100MHz)
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end

    integer i;
    reg [7:0] pattern;

    // Task: Apply synchronous reset
    task apply_reset;
        begin
            PRESETn = 0;
            @(posedge PCLK);
            PRESETn = 1;
            @(posedge PCLK);
        end
    endtask

    // Test sequence
    initial begin
        $display("22BEC0413");
        $display("=============================================");
        $display("SHIFT REGISTER VERIFICATION TESTBENCH");
        $display("=============================================");

        // Initialize all inputs
        PRESETn = 0; ss = 1; send_data = 0; lsbfe = 0;
        cpha = 1; cpol = 0; flag_high = 0; flags_high = 0;
        miso = 0; receive_data = 0; data_mosi = 0;

        // Apply reset
        #20 PRESETn = 1;
        $display("[INIT] Reset released at T=%0t", $time);

        // ==========================
        // TEST 1: TRANSMISSION (MSB FIRST)
        // ==========================
        pattern = 8'b10101010;
        $display("\n=== TEST 1: TRANSMISSION (MSB FIRST) ===");
        ss = 0; lsbfe = 0; send_data = 1; data_mosi = pattern; @(posedge PCLK); send_data = 0;
        for (i=7; i>=0; i=i-1) begin
            @(posedge PCLK); flags_high = 1; @(posedge PCLK); flags_high = 0; #10;
            $display("[TX] Bit %0d: mosi=%b (expected %b)", 7-i, mosi, pattern[i]);
            #40;
        end
        ss = 1; apply_reset();

        // ==========================
        // TEST 2: TRANSMISSION (LSB FIRST)
        // ==========================
        pattern = 8'b10101010;
        $display("\n=== TEST 2: TRANSMISSION (LSB FIRST) ===");
        ss = 0; lsbfe = 1; send_data = 1; data_mosi = pattern; @(posedge PCLK); send_data = 0;
        for (i=0; i<8; i=i+1) begin
            @(posedge PCLK); flags_high = 1; @(posedge PCLK); flags_high = 0; #10;
            $display("[TX] Bit %0d: mosi=%b (expected %b)", i, mosi, pattern[i]);
            #40;
        end
        ss = 1; apply_reset();

        // ==========================
        // TEST 3: RECEPTION (MSB FIRST)
        // ==========================
        pattern = 8'b11111111;
        $display("\n=== TEST 3: RECEPTION (MSB FIRST) ===");
        ss = 0; lsbfe = 0; receive_data = 1;
        for (i=7; i>=0; i=i-1) begin
            miso = pattern[i];
            @(posedge PCLK); flag_high = 1; @(posedge PCLK); flag_high = 0; #10;
            $display("[RX] Bit %0d: temp_reg[%0d]=%b (expected %b)", 7-i, i, dut.rx_shift_reg[i], pattern[i]);
            #40;
        end
        ss = 1; apply_reset();

        // ==========================
        // TEST 4: RECEPTION (LSB FIRST)
        // ==========================
        pattern = 8'b00000000;
        $display("\n=== TEST 4: RECEPTION (LSB FIRST) ===");
        ss = 0; lsbfe = 1; receive_data = 1;
        for (i=0; i<8; i=i+1) begin
            miso = pattern[i];
            @(posedge PCLK); flag_high = 1; @(posedge PCLK); flag_high = 0; #10;
            $display("[RX] Bit %0d: temp_reg[%0d]=%b (expected %b)", i, i, dut.rx_shift_reg[i], pattern[i]);
            #40;
        end
        ss = 1;

        $display("\n=== TEST SUMMARY ===");
        $display("All tests completed at T=%0t", $time);
        $display("=============================================");
        #50 $finish;
    end

    // Monitor internal signals
    initial begin
        $monitor("T=%0t TX_idx=%d RX_idx=%d tx_shift_reg=%b rx_shift_reg=%b",
                 $time, dut.tx_bit_idx, dut.rx_bit_idx, dut.tx_shift_reg, dut.rx_shift_reg);
    end

    // Waveform dump
    initial begin
        $dumpfile("tb_shift_reg.vcd");
        $dumpvars(0, tb_shift_register);
    end
endmodule
