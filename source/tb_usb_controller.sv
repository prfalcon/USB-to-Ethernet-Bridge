// $Id: $
// File name:   tb_usb_controller.sv
// Created:     12/5/2017
// Author:      Alejandro Orozco
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: test bench for USB Controller
`timescale 1ns / 10ps

module tb_usb_controller ();

	// Define parameters
	// basic test bench parameters
	localparam	CLK_PERIOD	= 5.2;
	
	// Shared Test Variables
	reg tb_clk;
	
	// Clock generation block
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end
	
	// Default Config Test Variables & constants
	localparam DEFAULT_SIZE = 4;

	
	tb_usb_controller_DUT  usb_controller_default(.tb_clk);
	
endmodule // tb_flex_counter

module tb_usb_controller_DUT
	#(parameter SIZE = 4, NAME = "default")
	(input wire tb_clk);

	localparam MAX_BIT = (SIZE - 1);
	
	integer tb_test_num;
	reg tb_n_rst;
	reg tb_ack_done;
	reg tb_crc_error;
	reg tb_ack_rcvd;
	reg tb_nak_rcvd;
	reg tb_byte_ready;
	reg tb_eop_found;
	reg tb_fifo_empty;
	reg tb_fifo_full;
	reg tb_in_token;
	reg tb_out_token;
	reg tb_read_enable;
	reg tb_read_start;
	reg tb_read_error;
	reg tb_write_enable;
	reg tb_write_start;
	reg tb_write_error;
	reg tb_tx_enable;
	reg tb_handshake_prep;
	reg [1:0] tb_handshake;
	reg tb_expected_read_enable;
	reg tb_expected_read_start;
	reg tb_expected_read_error;
	reg tb_expected_write_enable;
	reg tb_expected_write_start;
	reg tb_expected_write_error;
	reg tb_expected_tx_enable;
	reg tb_expected_handshake_prep;
	reg [1:0] tb_expected_handshake; 

	// DUT portmaps
	generate
		if(NAME == "default")
			usb_controller DUT
			(
			.clk(tb_clk),
			.n_rst(tb_n_rst),
			.ack_done(tb_ack_done),
			.crc_error(tb_crc_error),
			.ack_rcvd(tb_ack_rcvd),
			.nak_rcvd(tb_nak_rcvd),
			.byte_ready(tb_byte_ready),
			.eop_found(tb_eop_found),
			.fifo_empty(tb_fifo_empty),
			.fifo_full(tb_fifo_full),
			.in_token(tb_in_token),
			.out_token(tb_out_token),
			.read_enable(tb_read_enable),
			.read_start(tb_read_start),
			.read_error(tb_read_error),
			.write_enable(tb_write_enable),
			.write_start(tb_write_start),
			.write_error(tb_write_error),
			.tx_enable(tb_tx_enable),
			.handshake_prep(tb_handshake_prep),
			.handshake(tb_handshake) 
		);
	endgenerate
	clocking cb @(posedge tb_clk);
 		// 1step means 1 time precision unit, 10ps for this module. We assume the hold time is less than 200ps.
		default input #1step output #100ps; // Setup time (01CLK -> 10D) is 94 ps
		output #800ps n_rst = tb_n_rst; // FIXME: Removal time (01CLK -> 01R) is 281.25ps, but this needs to be 800 to prevent metastable value warnings
		output 	ack_done=tb_ack_done,
			crc_error=tb_crc_error,
			ack_rcvd=tb_ack_rcvd,
			nak_rcvd=tb_nak_rcvd,
			byte_ready=tb_byte_ready,
			eop_found=tb_eop_found,
			fifo_empty=tb_fifo_empty,
			fifo_full=tb_fifo_full,
			in_token=tb_in_token,
			out_token=tb_out_token;
		input	read_enable=tb_read_enable,
			read_start=tb_read_start,
			read_error=tb_read_error,
			write_enable=tb_write_enable,
			write_start=tb_write_start,
			write_error=tb_write_error,
			tx_enable=tb_tx_enable,
			handshake_prep=tb_handshake_prep,
			handshake=tb_handshake; 
	endclocking
// Default Configuration Test bench main process
	initial
	begin
		// Initialize all of the test inputs
		tb_test_num = 0;	
		tb_n_rst = 0;
		tb_ack_done = 0;
		tb_crc_error = 0;
		tb_ack_rcvd = 0;
		tb_nak_rcvd = 0;
		tb_byte_ready = 0;
		tb_eop_found = 0;
		tb_fifo_empty = 0;
		tb_fifo_full = 0;
		tb_in_token = 0;
		tb_out_token = 0;
		tb_expected_read_enable = 0;
		tb_expected_read_start = 0;
		tb_expected_read_error = 0;
		tb_expected_write_enable = 0;
		tb_expected_write_start = 0;
		tb_expected_write_error = 0;
		tb_expected_tx_enable = 0;
		tb_expected_handshake_prep = 0;
		tb_expected_handshake = 0; 
		
		// Power-on Reset of the DUT
		// Assume we start at positive edge. Immediately assert reset at first negative edge
		// without using clocking block in order to avoid metastable value warnings
		@(negedge tb_clk);
		tb_n_rst	<= 1'b0; 	// Need to actually toggle this in order for it to actually run dependent always blocks
		@cb;
		cb.n_rst	<= 1'b1; 	// Deactivate the chip reset
		
		// Wait for a while to see normal operation
		@cb;
		
		// Test 0: Check for Proper Reset w/ Idle input during reset signal
		
		if (tb_expected_read_enable == tb_read_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_enable", NAME, tb_test_num);
		if (tb_expected_read_start == tb_read_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_start", NAME, tb_test_num);
		if (tb_expected_read_error == tb_read_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_error", NAME, tb_test_num);
		if (tb_expected_write_enable == tb_write_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_enable", NAME, tb_test_num);
		if (tb_expected_write_start == tb_write_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_start", NAME, tb_test_num);
		if (tb_expected_write_error == tb_write_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_error", NAME, tb_test_num);
		if (tb_expected_tx_enable == tb_tx_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect tx_enable", NAME, tb_test_num);
		if (tb_expected_handshake_prep == tb_handshake_prep)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED handshake_prep", NAME, tb_test_num);
		if (tb_expected_handshake == tb_handshake)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect handshake", NAME, tb_test_num);

		// De-assert reset for a cycle
		cb.n_rst <= 1'b1;
		@cb;

		// Test 1: Out token and run through successfull write
		// Initialize all of the test inputs
		tb_test_num = tb_test_num + 1;	
		tb_n_rst <= 0;
		@cb;
		cb.n_rst <= 1'b1;
		@cb;
		tb_ack_done <= 0;
		tb_crc_error <= 0;
		tb_ack_rcvd <= 0;
		tb_nak_rcvd <= 0;
		tb_byte_ready <= 0;
		tb_eop_found <= 0;
		tb_fifo_empty <= 0;
		tb_fifo_full <= 0;
		tb_in_token <= 0;
		tb_out_token <= 0;
		tb_expected_read_enable <= 0;
		tb_expected_read_start <= 0;
		tb_expected_read_error <= 0;
		tb_expected_write_enable <= 1;
		tb_expected_write_start <= 1;
		tb_expected_write_error <= 0;
		tb_expected_tx_enable <= 0;
		tb_expected_handshake_prep <= 0;
		tb_expected_handshake <= 0; 
		@cb;
		tb_out_token <= 1;
		@cb;
		tb_out_token <= 0;
		tb_byte_ready <= 1;
		@cb;
		@cb;
		// Check for correct asserted write enable and write start 
		if (tb_expected_read_enable == tb_read_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_enable", NAME, tb_test_num);
		if (tb_expected_read_start == tb_read_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_start", NAME, tb_test_num);
		if (tb_expected_read_error == tb_read_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_error", NAME, tb_test_num);
		if (tb_expected_write_enable == tb_write_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_enable", NAME, tb_test_num);
		if (tb_expected_write_start == tb_write_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_start", NAME, tb_test_num);
		if (tb_expected_write_error == tb_write_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_error", NAME, tb_test_num);
		if (tb_expected_tx_enable == tb_tx_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect tx_enable", NAME, tb_test_num);
		if (tb_expected_handshake_prep == tb_handshake_prep)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED handshake_prep", NAME, tb_test_num);
		if (tb_expected_handshake == tb_handshake)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect handshake", NAME, tb_test_num);
		// Correct write enable 
		tb_test_num = tb_test_num + 1;	
		tb_expected_write_start <= 0;
		@cb;
		@cb;
		if (tb_expected_read_enable == tb_read_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_enable", NAME, tb_test_num);
		if (tb_expected_read_start == tb_read_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_start", NAME, tb_test_num);
		if (tb_expected_read_error == tb_read_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_error", NAME, tb_test_num);
		if (tb_expected_write_enable == tb_write_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_enable", NAME, tb_test_num);
		if (tb_expected_write_start == tb_write_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_start", NAME, tb_test_num);
		if (tb_expected_write_error == tb_write_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_error", NAME, tb_test_num);
		if (tb_expected_tx_enable == tb_tx_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect tx_enable", NAME, tb_test_num);
		if (tb_expected_handshake_prep == tb_handshake_prep)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED handshake_prep", NAME, tb_test_num);
		if (tb_expected_handshake == tb_handshake)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect handshake", NAME, tb_test_num);
		// Correct ack after successfull write
		tb_test_num = tb_test_num + 1;	
		tb_byte_ready <= 0;
		tb_eop_found <= 1;
		tb_expected_write_enable <= 0;
		tb_expected_handshake_prep <= 1;
		tb_expected_handshake <= 0;
		@cb;
		@cb;
		if (tb_expected_read_enable == tb_read_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_enable", NAME, tb_test_num);
		if (tb_expected_read_start == tb_read_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_start", NAME, tb_test_num);
		if (tb_expected_read_error == tb_read_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_error", NAME, tb_test_num);
		if (tb_expected_write_enable == tb_write_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_enable", NAME, tb_test_num);
		if (tb_expected_write_start == tb_write_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_start", NAME, tb_test_num);
		if (tb_expected_write_error == tb_write_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_error", NAME, tb_test_num);
		if (tb_expected_tx_enable == tb_tx_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect tx_enable", NAME, tb_test_num);
		if (tb_expected_handshake_prep == tb_handshake_prep)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED handshake_prep", NAME, tb_test_num);
		if (tb_expected_handshake == tb_handshake)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect handshake", NAME, tb_test_num);
		
		
		// Out token with nak due to crc error on packet
		tb_test_num = tb_test_num + 1;	
		tb_ack_done <= 0;
		tb_crc_error <= 0;
		tb_ack_rcvd <= 0;
		tb_nak_rcvd <= 0;
		tb_byte_ready <= 0;
		tb_eop_found <= 0;
		tb_fifo_empty <= 0;
		tb_fifo_full <= 0;
		tb_in_token <= 0;
		tb_out_token <= 0;
		tb_expected_read_enable <= 0;
		tb_expected_read_start <= 0;
		tb_expected_read_error <= 0;
		tb_expected_write_enable <= 1;
		tb_expected_write_start <= 1;
		tb_expected_write_error <= 0;
		tb_expected_tx_enable <= 0;
		tb_expected_handshake_prep <= 0;
		tb_expected_handshake <= 0; 
		@cb;
		tb_out_token <= 1;
		@cb;
		tb_out_token <= 0;
		tb_byte_ready <= 1;
		@cb;
		@cb;
		// Check for correct asserted write enable and write start 
		if (tb_expected_read_enable == tb_read_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_enable", NAME, tb_test_num);
		if (tb_expected_read_start == tb_read_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_start", NAME, tb_test_num);
		if (tb_expected_read_error == tb_read_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_error", NAME, tb_test_num);
		if (tb_expected_write_enable == tb_write_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_enable", NAME, tb_test_num);
		if (tb_expected_write_start == tb_write_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_start", NAME, tb_test_num);
		if (tb_expected_write_error == tb_write_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_error", NAME, tb_test_num);
		if (tb_expected_tx_enable == tb_tx_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect tx_enable", NAME, tb_test_num);
		if (tb_expected_handshake_prep == tb_handshake_prep)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED handshake_prep", NAME, tb_test_num);
		if (tb_expected_handshake == tb_handshake)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect handshake", NAME, tb_test_num);

		tb_test_num = tb_test_num + 1;	
		tb_crc_error <= 1;
		tb_expected_read_enable <= 0;
		tb_expected_read_start <= 0;
		tb_expected_read_error <= 0;
		tb_expected_write_enable <= 0;
		tb_expected_write_start <= 0;
		tb_expected_write_error <= 1;
		tb_expected_tx_enable <= 0;
		tb_expected_handshake_prep <= 0;
		tb_expected_handshake <= 0;
		@cb;
		@cb;
		// Correct asserted write error
		if (tb_expected_read_enable == tb_read_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_enable", NAME, tb_test_num);
		if (tb_expected_read_start == tb_read_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_start", NAME, tb_test_num);
		if (tb_expected_read_error == tb_read_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_error", NAME, tb_test_num);
		if (tb_expected_write_enable == tb_write_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_enable", NAME, tb_test_num);
		if (tb_expected_write_start == tb_write_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_start", NAME, tb_test_num);
		if (tb_expected_write_error == tb_write_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_error", NAME, tb_test_num);
		if (tb_expected_tx_enable == tb_tx_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect tx_enable", NAME, tb_test_num);
		if (tb_expected_handshake_prep == tb_handshake_prep)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED handshake_prep", NAME, tb_test_num);
		if (tb_expected_handshake == tb_handshake)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect handshake", NAME, tb_test_num);

		tb_test_num = tb_test_num + 1;	
		tb_expected_write_error <= 0;
		tb_expected_tx_enable <= 0;
		tb_expected_handshake_prep <= 1;
		tb_expected_handshake <= 1;
		@cb;
		// Correct asserted handshake prep with nak handshake (handshake == 1)
		if (tb_expected_read_enable == tb_read_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_enable", NAME, tb_test_num);
		if (tb_expected_read_start == tb_read_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_start", NAME, tb_test_num);
		if (tb_expected_read_error == tb_read_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_error", NAME, tb_test_num);
		if (tb_expected_write_enable == tb_write_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_enable", NAME, tb_test_num);
		if (tb_expected_write_start == tb_write_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_start", NAME, tb_test_num);
		if (tb_expected_write_error == tb_write_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_error", NAME, tb_test_num);
		if (tb_expected_tx_enable == tb_tx_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect tx_enable", NAME, tb_test_num);
		if (tb_expected_handshake_prep == tb_handshake_prep)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED handshake_prep", NAME, tb_test_num);
		if (tb_expected_handshake == tb_handshake)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect handshake", NAME, tb_test_num);

		// Check for nak on crc error on out token
		tb_test_num = tb_test_num + 1;	
		tb_ack_done <= 0;
		tb_crc_error <= 0;
		tb_ack_rcvd <= 0;
		tb_nak_rcvd <= 0;
		tb_byte_ready <= 0;
		tb_eop_found <= 0;
		tb_fifo_empty <= 0;
		tb_fifo_full <= 0;
		tb_in_token <= 0;
		tb_out_token <= 1;
		tb_expected_read_enable <= 0;
		tb_expected_read_start <= 0;
		tb_expected_read_error <= 0;
		tb_expected_write_enable <= 0;
		tb_expected_write_start <= 0;
		tb_expected_write_error <= 0;
		tb_expected_tx_enable <= 0;
		tb_expected_handshake_prep <= 0;
		tb_expected_handshake <= 0; 
		@cb;
		tb_crc_error <= 1;
		tb_expected_handshake_prep <= 1;
		tb_expected_handshake <= 1; 
		@cb;
		@cb;
		// Correct asserted handshake prep with nak handshake (handshake == 1)
		if (tb_expected_read_enable == tb_read_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_enable", NAME, tb_test_num);
		if (tb_expected_read_start == tb_read_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_start", NAME, tb_test_num);
		if (tb_expected_read_error == tb_read_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_error", NAME, tb_test_num);
		if (tb_expected_write_enable == tb_write_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_enable", NAME, tb_test_num);
		if (tb_expected_write_start == tb_write_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_start", NAME, tb_test_num);
		if (tb_expected_write_error == tb_write_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_error", NAME, tb_test_num);
		if (tb_expected_tx_enable == tb_tx_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect tx_enable", NAME, tb_test_num);
		if (tb_expected_handshake_prep == tb_handshake_prep)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED handshake_prep", NAME, tb_test_num);
		if (tb_expected_handshake == tb_handshake)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect handshake", NAME, tb_test_num);

		// Nak after fifo full on in token
		tb_test_num = tb_test_num + 1;	
		tb_ack_done <= 0;
		tb_crc_error <= 0;
		tb_ack_rcvd <= 0;
		tb_nak_rcvd <= 0;
		tb_byte_ready <= 0;
		tb_eop_found <= 0;
		tb_fifo_empty <= 1;
		tb_fifo_full <= 0;
		tb_in_token <= 1;
		tb_out_token <= 0;
		tb_expected_read_enable <= 0;
		tb_expected_read_start <= 0;
		tb_expected_read_error <= 0;
		tb_expected_write_enable <= 0;
		tb_expected_write_start <= 0;
		tb_expected_write_error <= 0;
		tb_expected_tx_enable <= 0;
		tb_expected_handshake_prep <= 0;
		tb_expected_handshake <= 0; 
		@cb;
 		tb_expected_handshake_prep <= 1;
		tb_expected_handshake <= 1;
		@cb;
		@cb;
		// Correct asserted handshake prep with nak handshake (handshake == 1)
		if (tb_expected_read_enable == tb_read_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_enable", NAME, tb_test_num);
		if (tb_expected_read_start == tb_read_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_start", NAME, tb_test_num);
		if (tb_expected_read_error == tb_read_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_error", NAME, tb_test_num);
		if (tb_expected_write_enable == tb_write_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_enable", NAME, tb_test_num);
		if (tb_expected_write_start == tb_write_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_start", NAME, tb_test_num);
		if (tb_expected_write_error == tb_write_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_error", NAME, tb_test_num);
		if (tb_expected_tx_enable == tb_tx_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect tx_enable", NAME, tb_test_num);
		if (tb_expected_handshake_prep == tb_handshake_prep)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED handshake_prep", NAME, tb_test_num);
		if (tb_expected_handshake == tb_handshake)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect handshake", NAME, tb_test_num);
		// Send bytes after in token
		tb_test_num = tb_test_num + 1;	
		tb_ack_done <= 0;
		tb_crc_error <= 0;
		tb_ack_rcvd <= 0;
		tb_nak_rcvd <= 0;
		tb_byte_ready <= 0;
		tb_eop_found <= 0;
		tb_fifo_empty <= 0;
		tb_fifo_full <= 0;
		tb_in_token <= 1;
		tb_out_token <= 0;
		tb_expected_read_enable <= 0;
		tb_expected_read_start <= 0;
		tb_expected_read_error <= 0;
		tb_expected_write_enable <= 0;
		tb_expected_write_start <= 0;
		tb_expected_write_error <= 0;
		tb_expected_tx_enable <= 0;
		tb_expected_handshake_prep <= 0;
		tb_expected_handshake <= 0; 

		@cb;
		tb_expected_read_enable <= 1;
		tb_expected_read_start <= 1;
		tb_expected_tx_enable <= 1;
		@cb;
		@cb;
		// Correct asserted read start, read enable and tx enable
		if (tb_expected_read_enable == tb_read_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_enable", NAME, tb_test_num);
		if (tb_expected_read_start == tb_read_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_start", NAME, tb_test_num);
		if (tb_expected_read_error == tb_read_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_error", NAME, tb_test_num);
		if (tb_expected_write_enable == tb_write_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_enable", NAME, tb_test_num);
		if (tb_expected_write_start == tb_write_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_start", NAME, tb_test_num);
		if (tb_expected_write_error == tb_write_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_error", NAME, tb_test_num);
		if (tb_expected_tx_enable == tb_tx_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect tx_enable", NAME, tb_test_num);
		if (tb_expected_handshake_prep == tb_handshake_prep)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED handshake_prep", NAME, tb_test_num);
		if (tb_expected_handshake == tb_handshake)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect handshake", NAME, tb_test_num);

		tb_test_num = tb_test_num + 1;	
		tb_expected_read_enable <= 1;
		tb_expected_read_start <= 0;
		tb_expected_tx_enable <= 1;
		@cb;
		@cb;
		// asserted read enable and tx enable
		if (tb_expected_read_enable == tb_read_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_enable", NAME, tb_test_num);
		if (tb_expected_read_start == tb_read_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_start", NAME, tb_test_num);
		if (tb_expected_read_error == tb_read_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_error", NAME, tb_test_num);
		if (tb_expected_write_enable == tb_write_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_enable", NAME, tb_test_num);
		if (tb_expected_write_start == tb_write_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_start", NAME, tb_test_num);
		if (tb_expected_write_error == tb_write_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_error", NAME, tb_test_num);
		if (tb_expected_tx_enable == tb_tx_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect tx_enable", NAME, tb_test_num);
		if (tb_expected_handshake_prep == tb_handshake_prep)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED handshake_prep", NAME, tb_test_num);
		if (tb_expected_handshake == tb_handshake)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect handshake", NAME, tb_test_num);

		tb_test_num = tb_test_num + 1;	
		tb_fifo_empty <= 1;
		tb_expected_read_enable <= 0;
		tb_expected_read_start <= 0;
		tb_expected_read_error <= 0;
		tb_expected_write_enable <= 0;
		tb_expected_write_start <= 0;
		tb_expected_write_error <= 0;
		tb_expected_tx_enable <= 0;
		tb_expected_handshake_prep <= 0;
		tb_expected_handshake <= 0; 
		@cb;
		@cb;
		if (tb_expected_read_enable == tb_read_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_enable", NAME, tb_test_num);
		if (tb_expected_read_start == tb_read_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_start", NAME, tb_test_num);
		if (tb_expected_read_error == tb_read_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_error", NAME, tb_test_num);
		if (tb_expected_write_enable == tb_write_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_enable", NAME, tb_test_num);
		if (tb_expected_write_start == tb_write_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_start", NAME, tb_test_num);
		if (tb_expected_write_error == tb_write_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_error", NAME, tb_test_num);
		if (tb_expected_tx_enable == tb_tx_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect tx_enable", NAME, tb_test_num);
		if (tb_expected_handshake_prep == tb_handshake_prep)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED handshake_prep", NAME, tb_test_num);
		if (tb_expected_handshake == tb_handshake)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect handshake", NAME, tb_test_num);

		tb_test_num = tb_test_num + 1;			
		tb_ack_rcvd <= 1;
		@cb;
		@cb;
		if (tb_expected_read_enable == tb_read_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_enable", NAME, tb_test_num);
		if (tb_expected_read_start == tb_read_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_start", NAME, tb_test_num);
		if (tb_expected_read_error == tb_read_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_error", NAME, tb_test_num);
		if (tb_expected_write_enable == tb_write_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_enable", NAME, tb_test_num);
		if (tb_expected_write_start == tb_write_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_start", NAME, tb_test_num);
		if (tb_expected_write_error == tb_write_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_error", NAME, tb_test_num);
		if (tb_expected_tx_enable == tb_tx_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect tx_enable", NAME, tb_test_num);
		if (tb_expected_handshake_prep == tb_handshake_prep)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED handshake_prep", NAME, tb_test_num);
		if (tb_expected_handshake == tb_handshake)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect handshake", NAME, tb_test_num);

		// Send bytes after in token with nak received
		tb_test_num = tb_test_num + 1;	
		tb_ack_done <= 0;
		tb_crc_error <= 0;
		tb_ack_rcvd <= 0;
		tb_nak_rcvd <= 0;
		tb_byte_ready <= 0;
		tb_eop_found <= 0;
		tb_fifo_empty <= 0;
		tb_fifo_full <= 0;
		tb_in_token <= 1;
		tb_out_token <= 0;
		tb_expected_read_enable <= 0;
		tb_expected_read_start <= 0;
		tb_expected_read_error <= 0;
		tb_expected_write_enable <= 0;
		tb_expected_write_start <= 0;
		tb_expected_write_error <= 0;
		tb_expected_tx_enable <= 0;
		tb_expected_handshake_prep <= 0;
		tb_expected_handshake <= 0; 

		@cb;
		tb_expected_read_enable <= 1;
		tb_expected_read_start <= 1;
		tb_expected_tx_enable <= 1;
		@cb;
		@cb;
		// Correct asserted read start, read enable and tx enable
		if (tb_expected_read_enable == tb_read_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_enable", NAME, tb_test_num);
		if (tb_expected_read_start == tb_read_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_start", NAME, tb_test_num);
		if (tb_expected_read_error == tb_read_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_error", NAME, tb_test_num);
		if (tb_expected_write_enable == tb_write_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_enable", NAME, tb_test_num);
		if (tb_expected_write_start == tb_write_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_start", NAME, tb_test_num);
		if (tb_expected_write_error == tb_write_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_error", NAME, tb_test_num);
		if (tb_expected_tx_enable == tb_tx_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect tx_enable", NAME, tb_test_num);
		if (tb_expected_handshake_prep == tb_handshake_prep)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED handshake_prep", NAME, tb_test_num);
		if (tb_expected_handshake == tb_handshake)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect handshake", NAME, tb_test_num);

		tb_test_num = tb_test_num + 1;	
		tb_expected_read_enable <= 1;
		tb_expected_read_start <= 0;
		tb_expected_tx_enable <= 1;
		@cb;
		@cb;
		// asserted read enable and tx enable
		if (tb_expected_read_enable == tb_read_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_enable", NAME, tb_test_num);
		if (tb_expected_read_start == tb_read_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_start", NAME, tb_test_num);
		if (tb_expected_read_error == tb_read_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_error", NAME, tb_test_num);
		if (tb_expected_write_enable == tb_write_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_enable", NAME, tb_test_num);
		if (tb_expected_write_start == tb_write_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_start", NAME, tb_test_num);
		if (tb_expected_write_error == tb_write_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_error", NAME, tb_test_num);
		if (tb_expected_tx_enable == tb_tx_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect tx_enable", NAME, tb_test_num);
		if (tb_expected_handshake_prep == tb_handshake_prep)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED handshake_prep", NAME, tb_test_num);
		if (tb_expected_handshake == tb_handshake)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect handshake", NAME, tb_test_num);

		tb_test_num = tb_test_num + 1;	
		tb_fifo_empty <= 1;
		tb_expected_read_enable <= 0;
		tb_expected_read_start <= 0;
		tb_expected_read_error <= 0;
		tb_expected_write_enable <= 0;
		tb_expected_write_start <= 0;
		tb_expected_write_error <= 0;
		tb_expected_tx_enable <= 0;
		tb_expected_handshake_prep <= 0;
		tb_expected_handshake <= 0; 
		@cb;
		@cb;
		if (tb_expected_read_enable == tb_read_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_enable", NAME, tb_test_num);
		if (tb_expected_read_start == tb_read_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_start", NAME, tb_test_num);
		if (tb_expected_read_error == tb_read_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_error", NAME, tb_test_num);
		if (tb_expected_write_enable == tb_write_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_enable", NAME, tb_test_num);
		if (tb_expected_write_start == tb_write_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_start", NAME, tb_test_num);
		if (tb_expected_write_error == tb_write_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_error", NAME, tb_test_num);
		if (tb_expected_tx_enable == tb_tx_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect tx_enable", NAME, tb_test_num);
		if (tb_expected_handshake_prep == tb_handshake_prep)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED handshake_prep", NAME, tb_test_num);
		if (tb_expected_handshake == tb_handshake)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect handshake", NAME, tb_test_num);

		tb_test_num = tb_test_num + 1;			
		tb_nak_rcvd <= 1;
		tb_expected_read_error <= 1;
		@cb;
		@cb;
		if (tb_expected_read_enable == tb_read_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_enable", NAME, tb_test_num);
		if (tb_expected_read_start == tb_read_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_start", NAME, tb_test_num);
		if (tb_expected_read_error == tb_read_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect read_error", NAME, tb_test_num);
		if (tb_expected_write_enable == tb_write_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_enable", NAME, tb_test_num);
		if (tb_expected_write_start == tb_write_start)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_start", NAME, tb_test_num);
		if (tb_expected_write_error == tb_write_error)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect write_error", NAME, tb_test_num);
		if (tb_expected_tx_enable == tb_tx_enable)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect tx_enable", NAME, tb_test_num);
		if (tb_expected_handshake_prep == tb_handshake_prep)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED handshake_prep", NAME, tb_test_num);
		if (tb_expected_handshake == tb_handshake)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect handshake", NAME, tb_test_num);



	end
endmodule
