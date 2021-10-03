module size_count (
  input clock, rst_n,
  input [31:0] size,
  input size_valid, data_start,
  output reg last
);

  localparam WAIT_ON_SIZE = 2'b00;
  localparam WAIT_ON_START = 2'b01;
  localparam MACHINE_DECREMENT  = 2'b11;

  reg [1:0] cstate, nstate;

  // state vector
  always @( posedge clock )
    if( !rst_n )
      cstate <= WAIT_ON_SIZE;
    else
      cstate <= nstate;

  // Controller Implementation

  reg load,dec;
  wire tc;

  always @*
    case( cstate )
      WAIT_ON_SIZE : begin  // Waiting for size_valid to assert
        last   <= 0;
        dec    <= 0;
        if( size_valid ) begin
          load   <= 1;
          nstate <= WAIT_ON_START;
        end
        else begin
          load   <= 0;
          nstate <= WAIT_ON_SIZE;
        end
      end

      WAIT_ON_START : begin
        last   <= 0;
        dec    <= 0;
        load   <= 0;
        nstate <= data_start ? MACHINE_DECREMENT : WAIT_ON_START;
      end

      MACHINE_DECREMENT : begin
        load   <= 0;
        if( tc ) begin
          nstate <= WAIT_ON_SIZE;
          dec    <= 0;
          last   <= 1;
        end
        else begin
          nstate <= MACHINE_DECREMENT;
          dec    <= 1;
          last   <= 0;
        end
      end

      default : begin
        last   <= 0;
        nstate <= WAIT_ON_SIZE;
      end
    endcase  // end of controller implementation

  // Instatiation of datapath within size_count

  datapath dp (
    .clock( clock ),
    .rst_n( rst_n ),
    .size( size ),
    .dec( dec ),
    .load( load ),
    .tc( tc )
);

endmodule

module datapath (
  input clock, rst_n,
  input [31:0] size,
  input reg dec, load,
  output reg tc
);

  reg [31:0] local_size;

  always @( posedge clock ) begin
     if( !rst_n ) begin
       tc         <= 0;
       local_size <= 0;
     end
     else begin
       if( load )
       local_size <= size;
       else begin
         if( dec )
           local_size = local_size - 1;
         else
           local_size <= local_size;

       end // end of load else statement
           
       if( local_size == 1 )
         tc <= 1;
       else 
         tc <= 0;
 
     end // end of rst_n else

  end //end of procedural block


endmodule

