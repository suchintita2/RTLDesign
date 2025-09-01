// Top-level module for SPI Controller (Corrected)
module top(
    input         PCLK, PRESETn, PWRITE, PSEL, PENABLE, miso,
    input   [2:0] PADDR,
    input   [7:0] PWDATA,
    output  [7:0] PRDATA,
    output        PREADY, PSLVERR, sclk, ss, mosi, spi_interrupt_request
);

    // --- Internal Wires ---
    wire        mstr, cpol, cpha, lsbfe;
    wire  [2:0] sppr, spr;
    wire        load_tx_reg, transfer_complete, spi_busy;
    wire        posedge_sclk_event, negedge_sclk_event;
    wire  [7:0] tx_data_out, rx_data_out;

    // Master mode SS control enable signal
    wire master_ss_enable = mstr & (PSEL & PENABLE & PWRITE & (PADDR == 3'b101));

    // --- Module Instantiations ---

    APB_Slave_Interface SLAVE_INTERFACE (
        .PCLK(PCLK), .PRESETn(PRESETn), .PWRITE(PWRITE), .PSEL(PSEL), .PENABLE(PENABLE),
        .PADDR(PADDR), .PWDATA(PWDATA), .rx_data_in(rx_data_out),
        .transfer_complete(transfer_complete), .spi_busy(spi_busy),
        .mstr(mstr), .cpol(cpol), .cpha(cpha), .lsbfe(lsbfe), .sppr(sppr), .spr(spr),
        .spi_interrupt_request(spi_interrupt_request), .PREADY(PREADY), .PSLVERR(PSLVERR),
        .load_tx_reg(load_tx_reg), .tx_data_out(tx_data_out), .PRDATA(PRDATA)
    );

    Baud_Rate_Generator BAUD_GEN (
        .PCLK(PCLK), .PRESETn(PRESETn), .enable(spi_busy || (ss==0 && !mstr)), .cpol(cpol),
        .sppr(sppr), .spr(spr), .sclk(sclk),
        .posedge_sclk_event(posedge_sclk_event), .negedge_sclk_event(negedge_sclk_event)
    );

    shift_register SHIFT_REG (
        .PCLK(PCLK), .PRESETn(PRESETn), .load_tx_reg(load_tx_reg), .enable(spi_busy || (ss==0 && !mstr)),
        .lsbfe(lsbfe), .cpha(cpha), .cpol(cpol),
        .posedge_sclk_event(posedge_sclk_event), .negedge_sclk_event(negedge_sclk_event),
        .miso(miso), .tx_data_in(tx_data_out), .rx_data_out(rx_data_out), .mosi(mosi)
    );

    // Renamed module for clarity
    spi_master_ss_control MASTER_SS_CTRL (
        .PCLK(PCLK), .PRESETn(PRESETn), .mstr(mstr), .start_transfer(load_tx_reg),
        .posedge_sclk_event(posedge_sclk_event), .negedge_sclk_event(negedge_sclk_event),
        .ss(ss), .transfer_complete(transfer_complete), .spi_busy(spi_busy)
    );

endmodule
