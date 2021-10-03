module adler32 (
  input         rst_n, clk,
  input         size_valid,
  input  [31:0] size,
  input         data_start,
  input  [ 7:0] data,
  output        checksum_valid,
  output [31:0] checksum
);

  wire latch_size, upd_data, dec_cnt, clr_data;

  controller ctl( rst_n, clk, size_valid, data_start,
    last_data, checksum_valid, latch_size, upd_data,
    dec_cnt, clr_data );

  datapath datap( rst_n, clk, size, latch_size, data,
    upd_data, clr_data, dec_cnt, last_data, checksum );

endmodule
