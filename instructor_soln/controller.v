module controller (
  input      rst_n, clk,
  input      size_valid,
  input      data_start,
  input      last_data,
  output reg checksum_valid,
  output reg latch_size,
  output reg upd_data,
  output reg dec_cnt,
  output reg clr_data
);

  localparam WAIT_ON_SIZE       = 0;
  localparam WAIT_ON_DATA_START = 1;
  localparam GET_DATA           = 2;
  localparam DELIVER_CHECKSUM   = 3;

  reg [1:0] cstate, nstate;

  always @( posedge clk )
    if( !rst_n )
      cstate <= WAIT_ON_SIZE;
    else
      cstate <= nstate;

  always @*
  begin
    // defaults
    latch_size     <= 0;
    checksum_valid <= 0;
    upd_data       <= 0;
    dec_cnt        <= 0;
    clr_data       <= 0;

    case( cstate )

      // on reset we start in the state waiting for
      // the size_valid signal to assert indicating
      // that we have a new message coming
      WAIT_ON_SIZE : begin
        clr_data     <= 1;

        // if size_valid asserts then we're getting
        // the size of the next message
        if( size_valid ) begin
          latch_size <= 1;

          // since the data_start could come in this
          // same cycle for the first data to be
          // available in the next cycle we need to
          // check data_start here
          if( data_start )
            nstate   <= GET_DATA;
          else
            nstate   <= WAIT_ON_DATA_START;
        end
        else begin
          nstate     <= WAIT_ON_SIZE;
        end
      
      end // WAIT_ON_SIZE

      // once we have the size of a message then we
      // begin to look for the start of the data
      // associated with it; all the while clearing
      // the contents of our accumulation registers
      WAIT_ON_DATA_START : begin
        clr_data <= 1;

        // once we see the data start signal we know
        // that the first data will appear in the next
        // clock cycle
        if( data_start )
          nstate <= GET_DATA;
        else
          nstate <= WAIT_ON_DATA_START;

      end // WAIT_ON_DATA_START

      // after the data_start signal we begin to see
      // data each clock cycle
      GET_DATA : begin
        upd_data <= 1;
        dec_cnt  <= 1;

        // when last_data asserts the final byte of
        // data will come in and we move to send the
        // final checksum out
        if( last_data )
          nstate <= DELIVER_CHECKSUM;
        else
          nstate <= GET_DATA;

      end // GET_DATA

      // asserting checksum_valid sends the value on
      // to a receiving entity
      DELIVER_CHECKSUM : begin
        checksum_valid <= 1;
        nstate         <= WAIT_ON_SIZE;

      end // DELIVER_CHECKSUM

      default: begin
        nstate <= WAIT_ON_SIZE;
      end

    endcase

  end

endmodule
