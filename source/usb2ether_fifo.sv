// $Id: $
// File name:   usb2ether_fifo.sv
// Created:     12/2/2017
// Author:      Alejandro Orozco
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: USB to Ethernet FIFO module
module usb2ether_fifo
#(
	parameter NUM_ADDR_BITS = 9,
	parameter MAX_ADDR_VALUE = 9'd511
)
(
	input  wire clk,
	input  wire n_rst,
	input  wire clear,
	input  wire read_enable,
	input  wire write_enable,
	input  wire read_error,
	input  wire read_start,
	input  wire write_error,
	input  wire write_start,
	input  wire [7:0] write_data,
	output wire [7:0] read_data,
	output wire fifo_empty,
	output wire fifo_full
);

	reg [NUM_ADDR_BITS - 1:0] read_pointer;
	reg [NUM_ADDR_BITS - 1:0] write_pointer;
	reg [NUM_ADDR_BITS - 1:0] byte_count;
	reg rf_read, rf_write;
	

	addr_counter #(NUM_ADDR_BITS) READ
	(
		.clk(clk),
		.n_rst(n_rst),
		.clear(1'b0),
		.count_enable(read_enable),
		.start(read_start),
		.error(read_error),
		.count_out(read_pointer),
		.rollover_val(MAX_ADDR_VALUE),
		.rollover_flag(rf_read)
	);

	addr_counter #(NUM_ADDR_BITS) WRITE
	(
		.clk(clk),
		.n_rst(n_rst),
		.clear(clear),
		.count_enable(write_enable),
		.start(write_start),
		.error(write_error),
		.count_out(write_pointer),
		.rollover_val(MAX_ADDR_VALUE),
		.rollover_flag(rf_write)
	);

	updown_counter #(NUM_ADDR_BITS) CTRL
	(
		.clk(clk),
		.n_rst(n_rst),
		.clear(clear),
		.count_up(write_enable),
		.count_down(read_enable),
		.start(write_start | read_start),
		.error(write_error | read_error),
		.count_out(byte_count),
		.rollover_val(MAX_ADDR_VALUE),
		.fifo_full(fifo_full),
		.fifo_empty(fifo_empty)
	);
	
	on_chip_sram_wrapper_u2e #(.W_ADDR_SIZE_BITS(NUM_ADDR_BITS)) RAM 
	(
		.read_enable(read_enable),
		.write_enable(write_enable),
		.address(read_enable ? read_pointer : write_pointer),
		.read_data(read_data),
		.write_data(write_data)
	);

endmodule
