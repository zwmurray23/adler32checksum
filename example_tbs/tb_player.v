`define NEWLINE 10
`define CARRIAGE_RETURN 13
`define MAX_LINE_LENGTH 80
`define NULL 0

module tb_player #(
  parameter WIDTH      = 4,
  parameter PFILE      = "tb_player.dat",
  parameter RAND_DELAY = 1,
  parameter RAND_MIN   = 0,
  parameter RAND_MAX   = 10
) (
  input rst_n, clock,
  output reg done,
  output reg [WIDTH-1:0] play
);

  reg [WIDTH-1:0] play_str;
  reg enable;
  integer play_fileno, play_c, play_r, play_rnd;
  reg [8*`MAX_LINE_LENGTH-1:0] play_line;

  initial begin : tb_player_block
    done = 0;
    enable = 0;
    $display( "[%t TB PLAYER] Opening [%s] for read", $time, PFILE );
    play_fileno = $fopen( PFILE, "r" );

    // check that the file was opened
    if( play_fileno == `NULL ) begin
      $display( "[%t TB PLAYER] Unable to open [%s] for reading ... exiting", $time, PFILE );
      disable tb_player_block;
    end

    else begin
      // get the first character of the first line
      play_c = $fgetc( play_fileno );

      // repeat for every line in the file
      while( !$feof( play_fileno ) ) begin

        // check the first character for a comment
        if( play_c == "#" ) begin
          play_r = $fgets( play_line, play_fileno );
          play_line[7:0] = 8'h00;
          $display( "[%t TB PLAYER] [COMMENT] %s", $time, play_line );
        end

        else begin
          // push the char back to the file and grab the binary string
          play_r = $ungetc( play_c, play_fileno );
          play_r = $fscanf( play_fileno, "%b\n", play_str );

          // wait until out of reset
          wait( rst_n == 1 );

          // check to see if we wait a random number of cycles and,
          // if so, the range
          if( RAND_DELAY ) begin
            play_rnd = {$random} % RAND_MAX + RAND_MIN;
            repeat( play_rnd ) @( posedge clock );
          end

          // pulse the enable for the output flop capture
          enable = 1;
          @( posedge clock )
          enable = 0;
        end

        // get the first character of the next line
        play_c = $fgetc( play_fileno );
      end
    end

    $display( "[%t TB PLAYER] Finished processing input lines from [%s]", $time, PFILE );
    $fclose( play_fileno );
    $display( "[%t TB PLAYER] Closed [%s]", $time, PFILE );
    done = 1;
  end

  // clocked device to get the timing right
  always @( negedge clock )
    if( !rst_n )
      play <= 0;
    else
      play <= play_str;

endmodule
