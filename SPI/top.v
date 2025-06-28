module top(
  input PCLK, PRESETn, PWRITE, PSEL, PENABLE, miso, 
  input [2:0] PADDR,
  input[7:0] PWDATA,
  output [7:0] PRDATA,
  output ss, sclk, spi_interrupt_request, mosi, PREADY, PSLVERR
);

  wire tip;
  wire [1:0] spi_mode;
  wire spiswai,cpol,cpha,flag_high,flag_low,flags_high,flags_low,send_data,lsbfe,receive_data,mstr;
  wire [11:0] baud_rate_div;
  wire [7:0] data_mosi,data_miso;
  wire [2:0] spr,sppr;

  Baud_Rate_Generator BAUD_GEN (PCLK, PRESETn, spi_mode, spiswai, sppr, spr, cpol, cpha, 
                                ss, sclk, flag_high, flag_low, flags_high, flags_low, baud_rate_div);

  APB_Slave_Interface SLAVE_INTERFACE (PCLK, PRESET, PADDR, PWRITE, PSEL, PENABLE, PWDATA,
                                       ss, data_miso, receive_data, tip, PRDATA, mstr, cpol, cpha, lsbfe, 
                                       spiswai, spi_interrupt_request, PREADY, PSLVERR, send_data, data_mosi, spi_mode, sppr, spr);

  spi_slave_control_select SLAVE_SELECT (PCLK, PRESETn, mstr, spiswai, spi_mode, send_data, baud_rate_div, receive_data, ss, tip);

  shift_register SHIFT_REG (PCLK, PRESETn, ss, send_data, lsbfe, cpha, cpol, flag_low, flag_high, 
                            flags_low, flags_high, miso, receive_data, data_mosi, mosi, data_miso);

endmodule
