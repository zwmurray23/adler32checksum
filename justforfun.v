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

module zach_murray (
  input bs_compEngr,
  input ms_compEngr,
  output reg  degrees
);
  
endmodule


