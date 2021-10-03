// ECE310 Project 2 
// Zachary Murray
//
// Adler-32 Checksum Generator -- A size input is given constantly, and is
// meant to be captured when the size_valid signal is asserted. Once
// data_start is asserted, the system must begin counting down from the
// original size and adding each number to create the correct Adler-32
// Checksum. After the data is fully received (designated by the size parameter),
// the system must assert a "valid" signal coincident with the correct
// checksum within 10 clock cycles. This design completes the checksum and
// asserts "valid" within 2 clock cycles.
//
// Submitted on 04/27/2021.
//
// Main design work was completed before this date.

module adler32 (
  input clk, rst_n,
  input size_valid,
  input [31:0] size,
  input data_start,
  input [7:0] data,
  output checksum_valid,
  output [31:0] checksum
);

  wire lw_last;

  size_count mySize(
    .clock( clk ),
    .rst_n( rst_n ),
    .size( size ),
    .size_valid( size_valid ),
    .data_start( data_start ),
    .last( lw_last )
);

  reg lr_engine_run;
  wire [31:0] lw_checksum;

  adler32_acc myAcc(
    .clk( clk ),
    .rst_n( rst_n ),
    .engine_run( lr_engine_run ),
    .data( data ),
    .checksum( lw_checksum )
);


  assign checksum = lw_checksum;

  always @( posedge clk ) begin
      
    if( !rst_n ) begin
      lr_engine_run <= 0;
    end
    else begin 

    if( data_start )
      lr_engine_run = 1;
    else
      if( lw_last )
      lr_engine_run = 0;

    end // end of rst_n else
  end

  wire lw_checksum_valid;
  wire lw_garbage;

  dff valid_comp(
    .rst_n( rst_n ),
    .clock( clk ),
    .q( lw_checksum_valid ),
    .q_n( lw_garbage ),
    .d( lw_last )
);

//  reg

//  dff reset_dff(
//    .rst_n( rst_n ),
//    .clock( clk ),
//    .q( lr_clear ),
//    .q_n( lw_garbage ),
//    .d( lw_checksum_valid )
//);

  assign checksum_valid = lw_checksum_valid;



endmodule


