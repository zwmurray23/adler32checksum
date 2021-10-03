module adler32_acc (
  input         rst_n, clk, engine_run,
  input  [ 7:0] data,
  output [31:0] checksum
);

  reg  [15:0] A, B;
  wire [15:0] modulo_add_A, modulo_add_B;

  // checksum output
  assign checksum = { B, A };

  // A register
  always @( posedge clk )
    if( !rst_n )
      A <= 1;
    else
      if( engine_run ) 
      A = modulo_add_A;
      else
      A <= 1;

  // B register
  always @( posedge clk )
    if( !rst_n )
      B <= 0;
    else
      if( engine_run )
      B = modulo_add_B;
      else
      B <= 0;

  modulo_sum sum_A (
    A, {8'h00, data}, modulo_add_A );

  modulo_sum sum_B (
    B, modulo_add_A, modulo_add_B );

endmodule

module modulo_sum(
  input      [15:0] a, b,
  output reg [15:0] sum
);

  always @( a, b ) begin
    if((a + b) == 65521) begin
        sum = 0;
    end //first if statement
    else begin
    if((a + b) > 65521) begin
      sum = (a + b) - 65521;
    end //if statement
    else begin
      sum = a + b;
    end //last else statement

    end //big else statement

  end //end of always

endmodule
