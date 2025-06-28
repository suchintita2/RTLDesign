module spi_slave_control_select(
  input PCLK, PRESETn, mstr, spiswai, send_data,
  input [1:0] spi_mode, 
  input [11:0] baud_rate_divisor,
  output ss, tip,
  output reg receive_data);

  reg rcv;
  wire select, enable, target;

  assign tip = ~ss;
  assign target = baud_rate_divisor << 4;
  
  assign select = ((!spiswai) && enable && mstr);
  assign enable = (spi_mode == 2'b00) || (spi_mode == 2'b01);
  
  always@(posedge clk or negedge PRESETn) begin
    if(!PRESETn)
      receive_data <= 1'b0;
    else
      receive_data <= rcv;
  end

   always@(posedge clk or negedge PRESETn) begin
     if(!PRESETn) 
       rcv <= 1'b0;
     else if (enable && !send_data && (count <= (target - 1'b1)) && (count == (target - 1'b1)))
       rcv <= 1'b1;
     else if (!enable ||  send_data || !(count <= (target - 1'b1)))
       rcv <= 1'b0;
   end

  always@(posedge clk or negedge PRESETn) begin
     if(!PRESETn) 
       ss <= 1'b1;
    else if (enable) begin
      if(!send_data) begin
        if(count <= (target - 1'b1))
          ss <= 1'b0;
        else
          ss <= 1'b1;
      end else
        ss <= 1'b0;
    end else if(!enable)
      ss <= 1'b1;
  end
