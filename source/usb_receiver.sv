// $Id: $
// File name:   usb_receiver.sv
// Created:     11/20/2017
// Author:      Alexandria Symanski
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: USB Receiver wrapper file

module usb_receiver
(
input clk, n_rst, d_plus, d_minus, 
output reg crc_err, in_token, out_token, byte_ready, host_ack, host_nack, eop_found,
output reg [7:0] data_byte
);

reg d_decoded, d_unstuffed, eop, receiving, init, data_enable, crc_16_enable, crc_5_enable;
reg crc_16_check, crc_5_check, crc_16_passed, crc_5_passed, final_enable, d_edge, n_enable;

sync_high SDP (.clk(clk), .n_rst(n_rst), .async_in(d_plus), .sync_out(sync_d_plus));
sync_high SDM (.clk(clk), .n_rst(n_rst), .async_in(d_minus), .sync_out(sync_d_minus));

re_decoder DCD (.clk(clk), .n_rst(n_rst), .d_plus(sync_d_plus), .d_minus(sync_d_minus), .data_enable(data_enable), .d_edge(d_edge), .d_decoded(d_decoded), .eop(eop), .n_enable(n_enable));

re_timer TMR (.clk(clk), .n_rst(n_rst), .d_edge(d_edge), .receiving(receiving), .data_enable(data_enable), .unstuff_hold(unstuff_hold), .byte_processed(byte_processed), .final_enable(final_enable), .n_enable(n_enable));

bit_unstuff BUSF (.clk(clk), .n_rst(n_rst), .d_decoded(d_decoded), .data_enable(n_enable), .unstuff_hold(unstuff_hold), .d_unstuffed(d_unstuffed));

rx_shift RXSR (.clk(clk), .n_rst(n_rst), .d_unstuffed(d_unstuffed), .final_enable(final_enable), .data_byte(data_byte));

re_controller RCNTRL (.clk(clk), .n_rst(n_rst), .byte_processed(byte_processed), .data_byte(data_byte), .eop(eop), .d_edge(d_edge), .crc_16_passed(crc_16_passed), .crc_5_passed(crc_5_passed), .crc_16_enable(crc_16_enable), .crc_5_enable(crc_5_enable), .crc_16_check(crc_16_check), .crc_5_check(crc_5_check), .receiving(receiving), .data_enable(data_enable), .crc_err(crc_err), .in_token(in_token), .out_token(out_token), .host_ack(host_ack), .host_nack(host_nack), .byte_ready(byte_ready), .eop_found(eop_found), .crc_init(init));

crc_16 CRC16 (.clk(clk), .n_rst(n_rst), .d_unstuffed(d_unstuffed), .final_enable(final_enable), .crc_16_enable(crc_16_enable), .crc_16_check(crc_16_check), .crc_16_passed(crc_16_passed), .init(init));

crc_5 CRC5 (.clk(clk), .n_rst(n_rst), .d_unstuffed(d_unstuffed), .final_enable(final_enable), .crc_5_enable(crc_5_enable), .crc_5_check(crc_5_check), .crc_5_passed(crc_5_passed), .init(init));

endmodule
