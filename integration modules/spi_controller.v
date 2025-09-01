module spi_controller(
    input         PCLK, PRESETn, PWRITE, PSEL, PENABLE, miso,
    input   [2:0] PADDR,
    input   [7:0] PWDATA,
    output  [7:0] PRDATA,
    output        PREADY, sclk, ss, mosi, spi_interrupt_request
);
    wire mstr, cpol, cpha, lsbfe;
    wire [2:0] sppr, spr;
    wire load_tx_reg, transfer_complete, spi_busy;
    wire posedge_sclk_event, negedge_sclk_event;
    wire [7:0] tx_data_out, rx_data_out;
    wire shift_event, sample_event;

    wire spi_enable = spi_busy || (ss==0 && !mstr);
    assign shift_event = cpha ? negedge_sclk_event : posedge_sclk_event;
    assign sample_event = cpha ? posedge_sclk_event : negedge_sclk_event;
    
    APB_Slave_Interface SLAVE_INTERFACE (PCLK, PRESETn, PWRITE, PSEL, PENABLE, PADDR, PWDATA,
        rx_data_out, transfer_complete, spi_busy, mstr, cpol, cpha, lsbfe, sppr, spr,
        spi_interrupt_request, PREADY, load_tx_reg, tx_data_out, PRDATA);
    Baud_Rate_Generator BAUD_GEN (PCLK, PRESETn, spi_enable, cpol, sppr, spr, sclk,
        posedge_sclk_event, negedge_sclk_event);
    shift_register SHIFT_REG (PCLK, PRESETn, load_tx_reg, spi_enable, lsbfe, shift_event,
        sample_event, miso, tx_data_out, rx_data_out, mosi);
    spi_master_ss_control MASTER_SS_CTRL (PCLK, PRESETn, mstr, load_tx_reg, shift_event,
        ss, transfer_complete, spi_busy);
endmodule
