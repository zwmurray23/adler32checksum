module datapath (
  input         rst_n, clk,
  input  [31:0] size,
  input         latch_size,
  input  [ 7:0] data,
  input         upd_data,
  input         clr_data,
  input         dec_cnt,
  output        last_data,
  output [31:0] checksum
);

  reg  [15:0] A, B;
  reg  [31:0] size_cnt;
  wire [15:0] modulo_add_A, modulo_add_B;

  // checksum output
  assign checksum = { B, A };

  // A register
  always @( posedge clk )
    if( !rst_n )
      A <= 1;
    else
      if( clr_data )
        A <= 1;
      else
        if( upd_data )
          A <= modulo_add_A;
        else
          A <= A;

  // B register
  always @( posedge clk )
    if( !rst_n )
      B <= 0;
    else
      if( clr_data )
        B <= 0;
      else
        if( upd_data )
          B <= modulo_add_B;
        else
          B <= B;

  // size counter
  always @( posedge clk )
    if( !rst_n )
      size_cnt <= 32'hffffffff;
    else
      if( latch_size )
        size_cnt <= size;
      else
        if( dec_cnt )
          size_cnt <= size_cnt - 1;
        else
          size_cnt <= size_cnt;

  assign last_data = ( size_cnt == 32'h00000001 );

  modulo_sum sum_A (
    A, {8'h00, data}, modulo_add_A );

  modulo_sum sum_B (
    B, modulo_add_A, modulo_add_B );

endmodule

module modulo_sum(
  input      [15:0] a, b,
  output reg [15:0] sum
);

  reg [16:0] tmp_sum;

  always @( a, b ) begin
    tmp_sum = a + b;
    if( tmp_sum >= 65521 )
      sum = tmp_sum - 65521;
    else
      sum = tmp_sum;
  end

endmodule
