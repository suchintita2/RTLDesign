module spi_slave_control_select(
  input PCLK, PRESETn, mstr, spiswai, send_data,
  input [1:0] spi_mode, 
  input [11:0] baud_rate_divisor,
  output ss, tip,
  output reg receive_data);

  reg rcv;
  wire select, enable;
  wire [15:0] count, target;

  assign tip = ~ss;
  
  assign target = {baud_rate_divisor, 4'b0};  // Multiply by 16 (shift left 4)  
  
  assign select = ((!spiswai) && enable && mstr);
  assign enable = (spi_mode == 2'b00) || (spi_mode == 2'b01);
  
  always@(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn)
      receive_data <= 1'b0;
    else
      receive_data <= rcv;
  end

  always@(posedge PCLK or negedge PRESETn) begin
     if(!PRESETn) 
       rcv <= 1'b0;
    else if (select && !send_data && (count <= (target - 1'b1)) && (count == (target - 1'b1)))
       rcv <= 1'b1;
    else if (!select ||  send_data || !(count <= (target - 1'b1)))
       rcv <= 1'b0;
   end
    
  always@(posedge PCLK or negedge PRESETn) begin
     if(!PRESETn) 
       ss <= 1'b1;
    else if (select) begin
      if(!send_data) begin
        if(count <= (target - 1'b1))
          ss <= 1'b0;
        else
          ss <= 1'b1;
      end else
        ss <= 1'b0;
    end else if(!select)
      ss <= 1'b1;
  end
    
  always@(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) 
       count <= 16'hffff;
    else if (select) begin
      if(!send_data) begin
        if(count <= (target - 1'b1))
          count <= (count + 1'b1);
        else
          count <= 16'hffff;
      end else
        count <= 16'b0;
    end else if(!select)
      count <= 16'hffff;
  end

endmodule
