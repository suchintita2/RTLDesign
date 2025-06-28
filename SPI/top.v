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
  
  Baud_Rate_Generator BAUD_GEN (PCLK, PRESETn, spiswwai, cpol, cpha, ss, spi_mode, sppr, spr, 
                                sclk, flag_low, flags_low, flag_high, flags_high, baud_rate_div);

	APB_Slave_Interface SLAVE_INTERFACE (PCLK, PRESETn, PWRITE, PSEL, PENABLE, ss, receive_data, tip,
					     PADDR, PWDATA, miso_data, mstr, cpol, cpha, lsbfe, spiswai, spi_interrupt_request, 
					     PREADY, PSLVERR, send_data, mosi_data, spi_mode, sppr, spr, PRDATA);
	
  spi_slave_control_select SLAVE_SELECT (PCLK, PRESETn, mstr, spiswai, send_data, spi_mode, , baud_rate_div, ss, tip, receive_data);

  shift_register SHIFT_REG (PCLK, PRESETn, ss, send_data, lsbfe, cpha, cpol, flag_low, flag_high, 
                            flags_low, flags_high, miso, receive_data, data_mosi, data_miso, mosi);

endmodule
