module spi_top(
    input PCLK, PRESETn, PWRITE, PSEL, PENABLE, miso, 
    input [2:0] PADDR,
    input [7:0] PWDATA,
    output [7:0] PRDATA,
    output PREADY, PSLVERR, sclk, ss, mosi, spi_interrupt_request
);

    wire tip;
    wire [1:0] spi_mode;
    wire spiswai, cpol, cpha, flag_high, flag_low, flags_high, flags_low;
    wire send_data, lsbfe, receive_data, mstr;
    wire [11:0] baud_rate_div;
    wire [7:0] data_mosi, data_miso;
    wire [2:0] spr, sppr;
    
    Baud_Rate_Generator BAUD_GEN (
        .PCLK(PCLK), .PRESETn(PRESETn), .spiswai(spiswai), 
        .cpol(cpol), .cpha(cpha), .ss(ss), .spi_mode(spi_mode), 
        .sppr(sppr), .spr(spr), .sclk(sclk), .flag_low(flag_low), 
        .flags_low(flags_low), .flag_high(flag_high), 
        .flags_high(flags_high), .baud_rate_divisor(baud_rate_div)
    );

    APB_Slave_Interface SLAVE_INTERFACE (
        .PCLK(PCLK), .PRESETn(PRESETn), .PWRITE(PWRITE), 
        .PSEL(PSEL), .PENABLE(PENABLE), .ss(ss), .receive_data(receive_data), 
        .tip(tip), .PADDR(PADDR), .PWDATA(PWDATA), .miso_data(data_miso), 
        .mstr(mstr), .cpol(cpol), .cpha(cpha), .lsbfe(lsbfe), 
        .spiswai(spiswai), .spi_interrupt_request(spi_interrupt_request), 
        .PREADY(PREADY), .PSLVERR(PSLVERR), .send_data(send_data), 
        .spi_mode(spi_mode), .sppr(sppr), .spr(spr), .PRDATA(PRDATA),
        .mosi_data(data_mosi)
    );
    
    spi_slave_control_select SLAVE_SELECT (
        .PCLK(PCLK), .PRESETn(PRESETn), .mstr(mstr), .spiswai(spiswai), 
        .send_data(send_data), .spi_mode(spi_mode), 
        .baud_rate_divisor(baud_rate_div), .ss(ss), .tip(tip), 
        .receive_data(receive_data)
    );

    shift_register SHIFT_REG (
        .PCLK(PCLK), .PRESETn(PRESETn), .ss(ss), .send_data(send_data), 
        .lsbfe(lsbfe), .cpha(cpha), .cpol(cpol), .flag_high(flag_high), 
        .flags_high(flags_high), .flag_low(flag_low), .flags_low(flags_low), 
        .miso(miso), .receive_data(receive_data), .data_mosi(data_mosi), 
        .data_miso(data_miso), .rx_shift_reg_out(), .mosi(mosi)
    );

endmodule
