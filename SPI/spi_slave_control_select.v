module spi_slave_control_select(
  input PCLK, PRESETn, mstr, spiswai, send_data,
  input [1:0] spi_mode, 
  input [11:0] BaudRateDivisor,
  output receive_data, ss, tip);
