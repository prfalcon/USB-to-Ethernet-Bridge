// $Id: $
// File name:   tb_usb2ether_fifo.sv
// Created:     12/2/2017
// Author:      Alejandro Orozco
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: test bench for usb2ether module
`timescale 1ns / 10ps
module tb_usb2ether_fifo ();

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
	
	integer tb_test_num;
	integer i;
	reg tb_n_rst;
	reg tb_read_enable;
 	reg tb_write_enable;
	reg tb_clear;
	reg tb_read_error;
	reg tb_read_start;
	reg tb_write_error;
	reg tb_write_start;
    	reg [7:0] tb_write_data;
    	reg [7:0] tb_read_data;
    	reg tb_fifo_empty;
    	reg tb_fifo_full;
	reg tb_expected_fifo_full;
	reg tb_expected_fifo_empty;
    	reg [7:0] tb_expected_read_data;

	// DUT portmaps
	generate
		usb2ether_fifo DUT
			(
        			.clk(tb_clk),
    				.n_rst(tb_n_rst),
				.clear(tb_clear),
        			.read_enable(tb_read_enable),
        			.write_enable(tb_write_enable),
				.read_error(tb_read_error),
				.read_start(tb_read_start),
				.write_error(tb_write_error),
				.write_start(tb_write_start),
        			.write_data(tb_write_data),
        			.read_data(tb_read_data),
        			.fifo_empty(tb_fifo_empty),
				.fifo_full(tb_fifo_full)
		);
	endgenerate
	clocking cb @(posedge tb_clk);
 		// 1step means 1 time precision unit, 10ps for this module. We assume the hold time is less than 200ps.
		default input #1step output #100ps; // Setup time (01CLK -> 10D) is 94 ps
		output #800ps n_rst = tb_n_rst; // FIXME: Removal time (01CLK -> 01R) is 281.25ps, but this needs to be 800 to prevent metastable value warnings
		output read_enable=tb_read_enable;
		output write_enable=tb_write_enable;
		output write_data=tb_write_data;
		output read_error=tb_read_error;
		output read_start=tb_read_start;
		output write_error=tb_write_error;
		output write_start=tb_write_start;
		output clear=tb_clear;
		input read_data=tb_read_data;
		input fifo_empty=tb_fifo_empty;
		input fifo_full=tb_fifo_full;
	endclocking
// Default Configuration Test bench main process
	initial
	begin
		// Initialize all of the test inputs
		tb_n_rst	= 1'b1;				// Initialize to be inactive

		
		// Power-on Reset of the DUT
		// Assume we start at positive edge. Immediately assert reset at first negative edge
		// without using clocking block in order to avoid metastable value warnings
		@(negedge tb_clk);
		tb_n_rst	<= 1'b0; 	// Need to actually toggle this in order for it to actually run dependent always blocks
		@cb;
		cb.n_rst	<= 1'b1; 	// Deactivate the chip reset
		
		// Wait for a while to see normal operation
		@cb;
		
		// Initialize test bench inputs
		tb_test_num = 0;
		i = 0;
		tb_n_rst <= 1'b0;
		tb_clear <= 1'b0;
		tb_read_enable <= 1'b0;
 		tb_write_enable <= 1'b0;
		tb_read_error <= 1'b0;
		tb_read_start <= 1'b0;
		tb_write_error <= 1'b0;
		tb_write_start <= 1'b0;
    		tb_write_data <= 8'b0;
		tb_expected_fifo_full <= 1'b0;
		tb_expected_fifo_empty <= 1'b0;

		// Test 0: Check for Proper Reset w/ Idle input during reset signal and 1 write followed by a read
		@cb;
		@cb;
		//tb_test_num = tb_test_num + 1;
		cb.n_rst <= 1'b1;
		tb_expected_fifo_empty <= 1'b1;
		@cb;
       		tb_write_data <= 8'b11111111;
		tb_expected_read_data <= 8'b11111111;
		@cb;
       		tb_write_enable <= 1'b1;
		tb_write_start <= 1'b1;
		@cb;
		tb_write_enable <= 1'b0;
		tb_write_start <= 1'b0;
		@cb; // Measure slightly before the second clock edge
		cb.read_enable <= 1'b1;
		cb.read_start <= 1'b1;
		@cb;
		cb.read_enable <= 1'b0;
		cb.read_start <= 1'b0;
		@cb;
		@cb;
		if (tb_read_data == tb_expected_read_data)
			$info("Case %0d:: PASSED", tb_test_num);
		else // Test case failed
			$error("Case %0d:: FAILED. Incorrect read_data. Expected: %d but read: %d", tb_test_num, tb_expected_read_data, tb_read_data);
		if (tb_fifo_full == tb_expected_fifo_full)
			$info("Case %0d:: PASSED", tb_test_num);
		else // Test case failed
			$error("Case %0d:: FAILED. Incorrect fifo_full", tb_test_num);
		if (tb_fifo_empty == tb_expected_fifo_empty)
			$info("Case %0d:: PASSED", tb_test_num);
		else // Test case failed
			$error("Case %0d:: FAILED. Incorrect fifo_empty", tb_test_num);
		// De-assert reset for a cycle
		cb.n_rst <= 1'b1;
		@cb;
		// Test Loop: Fill fifo, check fifo full
		cb.n_rst <= 1'b0;
		@cb;
		@cb;
		tb_test_num = tb_test_num + 1;
		cb.n_rst <= 1'b1;
		tb_expected_fifo_empty <= 1'b0;
		tb_expected_fifo_full <= 1'b0;
		@cb;
       		tb_write_data <= 8'b0;
       		tb_write_enable <= 1'b1;
		tb_write_start <= 1'b1;
		@cb;
       		tb_write_enable <= 1'b0;
		tb_write_start <= 1'b0;
		@cb;
		for(i = 1; i < 511; i = i + 1) begin
			tb_test_num = tb_test_num + 1;
			tb_write_data <= tb_write_data + 1;
			tb_write_enable <= 1'b1;
			@cb; // Measure slightly before the second clock edge
			tb_write_enable <= 1'b0;
			@cb;
			if(i == 510) tb_expected_fifo_full <= 1;
			@cb;
			@cb;
			if (tb_fifo_full == tb_expected_fifo_full)
				$info("Case %0d:: PASSED", tb_test_num);
			else // Test case failed
				$error("Case %0d:: FAILED. Incorrect fifo_full", tb_test_num);
			if (tb_fifo_empty == tb_expected_fifo_empty)
				$info("Case %0d:: PASSED", tb_test_num);
			else // Test case failed
				$error("Case %0d:: FAILED. Incorrect fifo_empty", tb_test_num);
			@cb;
		end
		// Test Loop: empty fifo, check fifo empty and read data
		@cb;
		tb_test_num = tb_test_num + 1;
		cb.n_rst <= 1'b1;
		tb_expected_fifo_empty <= 1'b0;
		tb_expected_fifo_full <= 1'b0;
		tb_expected_read_data <= 8'b0;
		@cb;
       		tb_read_enable <= 1'b1;
		tb_read_start <= 1'b1;
		@cb;
       		tb_read_enable <= 1'b0;
		tb_read_start <= 1'b0;
		@cb;
		for(i = 1; i < 511; i = i + 1) begin
			tb_test_num = tb_test_num + 1;
			tb_expected_read_data <= tb_expected_read_data + 1;
			tb_read_enable <= 1'b1;
			@cb; // Measure slightly before the second clock edge
			tb_read_enable <= 1'b0;
			@cb;
			if(i == 510) tb_expected_fifo_empty <= 1;
			@cb;
			if (tb_read_data == tb_expected_read_data)
				$info("Case %0d:: PASSED", tb_test_num);
			else // Test case failed
				$error("Case %0d:: FAILED. Incorrect read_data. Expected: %d but read: %d", tb_test_num, tb_expected_read_data, tb_read_data);
			if (tb_fifo_full == tb_expected_fifo_full)
				$info("Case %0d:: PASSED", tb_test_num);
			else // Test case failed
				$error("Case %0d:: FAILED. Incorrect fifo_full", tb_test_num);
			if (tb_fifo_empty == tb_expected_fifo_empty)
				$info("Case %0d:: PASSED", tb_test_num);
			else // Test case failed
				$error("Case %0d:: FAILED. Incorrect fifo_empty", tb_test_num);
			@cb;
		end


		// De-assert reset for a cycle
		cb.n_rst <= 1'b1;
		@cb;

	// Test Loop: Fill fifo, check if write error resets write pointer
		cb.n_rst <= 1'b0;
		@cb;
		@cb;
		tb_test_num = tb_test_num + 1;
		cb.n_rst <= 1'b1;
		tb_expected_fifo_empty <= 1'b0;
		tb_expected_fifo_full <= 1'b0;
		@cb;
       		tb_write_data <= 8'b0;
       		tb_write_enable <= 1'b1;
		tb_write_start <= 1'b1;
		@cb;
       		tb_write_enable <= 1'b0;
		tb_write_start <= 1'b0;
		@cb;
		for(i = 1; i < 511; i = i + 1) begin
			tb_test_num = tb_test_num + 1;
			tb_write_data <= tb_write_data + 1;
			tb_expected_fifo_empty <= 0;
			tb_write_enable <= 1'b1;
			@cb; // Measure slightly before the second clock edge
			tb_write_enable <= 1'b0;
			if(i == 255) begin
				tb_write_error <= 1;
				@cb;
				tb_write_error <= 0;
				tb_expected_fifo_empty <= 1;
			end
			@cb;
			@cb;
			if (tb_fifo_full == tb_expected_fifo_full)
				$info("Case %0d:: PASSED", tb_test_num);
			else // Test case failed
				$error("Case %0d:: FAILED. Incorrect fifo_full", tb_test_num);
			if (tb_fifo_empty == tb_expected_fifo_empty)
				$info("Case %0d:: PASSED", tb_test_num);
			else // Test case failed
				$error("Case %0d:: FAILED. Incorrect fifo_empty", tb_test_num);
			@cb;
		end
		// Test Loop: read fifo, check read data consistent with write error roll back
		@cb;
		tb_test_num = tb_test_num + 1;
		cb.n_rst <= 1'b1;
		tb_expected_fifo_empty <= 1'b0;
		tb_expected_fifo_full <= 1'b0;
		tb_expected_read_data <= 8'd256;
		@cb;
       		tb_read_enable <= 1'b1;
		tb_read_start <= 1'b1;
		@cb;
       		tb_read_enable <= 1'b0;
		tb_read_start <= 1'b0;
		@cb;
		for(i = 1; i < 255; i = i + 1) begin
			tb_test_num = tb_test_num + 1;
			tb_expected_read_data <= tb_expected_read_data + 1;
			tb_read_enable <= 1'b1;
			@cb; // Measure slightly before the second clock edge
			tb_read_enable <= 1'b0;
			if(i == 254) tb_expected_fifo_empty <= 1;
			@cb;
			@cb;
			if (tb_read_data == tb_expected_read_data)
				$info("Case %0d:: PASSED", tb_test_num);
			else // Test case failed
				$error("Case %0d:: FAILED. Incorrect read_data. Expected: %d but read: %d", tb_test_num, tb_expected_read_data, tb_read_data);
			if (tb_fifo_full == tb_expected_fifo_full)
				$info("Case %0d:: PASSED", tb_test_num);
			else // Test case failed
				$error("Case %0d:: FAILED. Incorrect fifo_full", tb_test_num);
			if (tb_fifo_empty == tb_expected_fifo_empty)
				$info("Case %0d:: PASSED", tb_test_num);
			else // Test case failed
				$error("Case %0d:: FAILED. Incorrect fifo_empty", tb_test_num);
			@cb;
		end
		// Test Loop: send read error, read fifo, check read data consistent with read error roll back
		@cb;
		tb_read_error <= 1;
		@cb;
		tb_read_error <= 0;	
		@cb;
		tb_test_num = tb_test_num + 1;
		cb.n_rst <= 1'b1;
		tb_expected_fifo_empty <= 1'b0;
		tb_expected_fifo_full <= 1'b0;
		tb_expected_read_data <= 8'd256;
		@cb;
       		tb_read_enable <= 1'b1;
		tb_read_start <= 1'b1;
		@cb;
       		tb_read_enable <= 1'b0;
		tb_read_start <= 1'b0;
		@cb;
		for(i = 1; i < 255; i = i + 1) begin
			tb_test_num = tb_test_num + 1;
			tb_expected_read_data <= tb_expected_read_data + 1;
			tb_read_enable <= 1'b1;
			@cb; // Measure slightly before the second clock edge
			tb_read_enable <= 1'b0;
			//@cb;
			if(i == 254) tb_expected_fifo_empty <= 1;
			@cb;
			if (tb_read_data == tb_expected_read_data)
				$info("Case %0d:: PASSED", tb_test_num);
			else // Test case failed
				$error("Case %0d:: FAILED. Incorrect read_data. Expected: %d but read: %d", tb_test_num, tb_expected_read_data, tb_read_data);
			if (tb_fifo_full == tb_expected_fifo_full)
				$info("Case %0d:: PASSED", tb_test_num);
			else // Test case failed
				$error("Case %0d:: FAILED. Incorrect fifo_full", tb_test_num);
			if (tb_fifo_empty == tb_expected_fifo_empty)
				$info("Case %0d:: PASSED", tb_test_num);
			else // Test case failed
				$error("Case %0d:: FAILED. Incorrect fifo_empty", tb_test_num);
			@cb;
			@cb;
		end




	end
endmodule