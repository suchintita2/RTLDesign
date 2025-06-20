module mux(
  input [7:0] a,b, 
  input s, 
  output [7:0] y);

  assign y = s?b:a;
endmodule
