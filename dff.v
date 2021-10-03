module dff (
  input rst_n, clock,
  input d,
  output reg q,
  output q_n
);

  always @(posedge clock )
    if( !rst_n )
      q <= 0;
    else
      q <= d;

  assign q_n = ~q;

endmodule
