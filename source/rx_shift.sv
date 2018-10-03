// $Id: $
// File name:   rx_shift.sv
// Created:     11/24/2017
// Author:      Alexandria Symanski
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Receiver shift register to FIFO

module rx_shift
(
input clk, n_rst, d_unstuffed, final_enable,
output reg [7:0] data_byte
);

flex_stp_sr #(8, 0) DOUT (.clk(clk), .n_rst(n_rst), .shift_enable(final_enable), .serial_in(d_unstuffed), .parallel_out(data_byte));

endmodule
