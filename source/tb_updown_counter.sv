// $Id: $
// File name:   tb_updown_counter.sv
// Created:     12/2/2017
// Author:      Alejandro Orozco
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: test bench for updown_counter module
`timescale 1ns / 10ps

module tb_updown_counter ();

	// Define parameters
	// basic test bench parameters
	localparam	CLK_PERIOD	= 2.5;
	
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

	
	tb_updown_counter_DUT #(.SIZE(DEFAULT_SIZE)) updown_counter_default(.tb_clk);
	
endmodule // tb_flex_counter

module tb_updown_counter_DUT
	#(parameter SIZE = 4, NAME = "default")
	(input wire tb_clk);

	localparam MAX_BIT = (SIZE - 1);
	
	integer tb_test_num;
	reg tb_n_rst;
	reg tb_clear;
	reg tb_count_up;
	reg tb_count_down;
        reg tb_fifo_full;
	reg tb_fifo_empty;
	reg tb_start;
	reg tb_error;
	reg [MAX_BIT:0] tb_rollover_val;
	reg [MAX_BIT:0] tb_count_out;
        reg tb_expected_fifo_full;
	reg tb_expected_fifo_empty;
	reg [MAX_BIT:0] tb_expected_count_out;

	// DUT portmaps
	generate
		if(NAME == "default")
			updown_counter DUT
			(
				.clk(tb_clk),
				.n_rst(tb_n_rst),
				.clear(tb_clear),
				.count_up(tb_count_up),
				.count_down(tb_count_down),
				.rollover_val(tb_rollover_val),
	                        .fifo_full(tb_fifo_full),
				.fifo_empty(tb_fifo_empty),
				.start(tb_start),
				.error(tb_error),
	                        .count_out(tb_count_out)
		);
	endgenerate
	clocking cb @(posedge tb_clk);
 		// 1step means 1 time precision unit, 10ps for this module. We assume the hold time is less than 200ps.
		default input #1step output #100ps; // Setup time (01CLK -> 10D) is 94 ps
		output #800ps n_rst = tb_n_rst; // FIXME: Removal time (01CLK -> 01R) is 281.25ps, but this needs to be 800 to prevent metastable value warnings
		output clear = tb_clear,
			count_up = tb_count_up,
			count_down = tb_count_down,
			rollover_val = tb_rollover_val,
			error = tb_error,
			start = tb_start;
		input count_out = tb_count_out,
			fifo_full = tb_fifo_full,
			fifo_empty = tb_fifo_empty;
	endclocking
// Default Configuration Test bench main process
	initial
	begin
		// Initialize all of the test inputs
		tb_n_rst		= 1'b1;				// Initialize to be inactive
		tb_clear		= 1'b0;
		tb_start		= 1'b0;
		tb_error		= 1'b0;
		tb_count_up		= 1'b0;				// Initialize to be inactive
		tb_count_down		= 1'b0;		
		tb_expected_fifo_full	= 1'b0;		
		tb_expected_fifo_empty	= 1'b0;		
		tb_expected_count_out   = 0;
		tb_test_num 		= 0;
		
		// Power-on Reset of the DUT
		// Assume we start at positive edge. Immediately assert reset at first negative edge
		// without using clocking block in order to avoid metastable value warnings
		@(negedge tb_clk);
		tb_n_rst	<= 1'b0; 	// Need to actually toggle this in order for it to actually run dependent always blocks
		@cb;
		cb.n_rst	<= 1'b1; 	// Deactivate the chip reset
		
		// Wait for a while to see normal operation
		@cb;
		
		// Test 1: Check for Proper Reset w/ Idle input during reset signal
		tb_test_num = tb_test_num + 1;
		cb.n_rst <= 1'b0;
		cb.count_up <= 1'b0;
		cb.count_down	<= 1'b0;
		cb.clear <= 1'b0;
		cb.rollover_val <= 4'b1000;
		cb.start <= 1'b0;
		cb.error <= 1'b0;
		
		tb_expected_count_out = 0;
		tb_expected_fifo_full = 0;
		tb_expected_fifo_empty = 1;
		@cb; // Measure slightly before the second clock edge
		@cb;
		if (tb_expected_count_out == cb.count_out)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect count", NAME, tb_test_num);
		if (tb_expected_fifo_full == cb.fifo_full)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_full flag", NAME, tb_test_num);
		if (tb_expected_fifo_empty == cb.fifo_empty)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_empty flag", NAME, tb_test_num);
		// De-assert reset for a cycle
		cb.n_rst <= 1'b1;
		@cb;

		// Test 2: Check for Proper Reset w/ count enabled
		tb_test_num = tb_test_num + 1;
		cb.n_rst <= 1'b0;
		cb.count_up <= 1'b1;
		cb.count_down <= 1'b0;
		cb.clear <= 1'b0;
		cb.rollover_val <= 4'b1000;
		cb.start <= 1'b0;
		cb.error <= 1'b0;
		
		tb_expected_count_out = 0;
		tb_expected_fifo_full = 0;
		tb_expected_fifo_empty = 1;
		@cb; // Measure slightly before the second clock edge
		@cb;
		if (tb_expected_count_out == cb.count_out)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect count", NAME, tb_test_num);
		if (tb_expected_fifo_full == cb.fifo_full)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_full flag", NAME, tb_test_num);
		if (tb_expected_fifo_empty == cb.fifo_empty)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_empty flag", NAME, tb_test_num);
		// De-assert reset for a cycle
		cb.n_rst <= 1'b1;
		@cb;
		// Test 3: Check for Proper clear
		cb.n_rst <= 1'b0;		
		tb_test_num = tb_test_num + 1;
		cb.n_rst <= 1'b1;
		cb.count_up <= 1'b1;
		cb.count_down <= 1'b0;
		cb.clear <= 1'b1;
		cb.rollover_val <= 4'b1000;
		cb.start <= 1'b0;
		cb.error <= 1'b0;
		
		tb_expected_count_out = 0;
		tb_expected_fifo_full = 0;
		tb_expected_fifo_empty = 1;
		@cb; // Measure slightly before the second clock edge
		@cb;
		if (tb_expected_count_out == cb.count_out)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect count", NAME, tb_test_num);
		if (tb_expected_fifo_full == cb.fifo_full)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_full flag", NAME, tb_test_num);
		if (tb_expected_fifo_empty == cb.fifo_empty)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_empty flag", NAME, tb_test_num);
		// De-assert reset for a cycle
		cb.n_rst <= 1'b1;
		@cb;
		// Test 4: Check for Proper count without rollover
		cb.n_rst <= 1'b0;
		@cb;
		tb_test_num = tb_test_num + 1;
		cb.n_rst <= 1'b1;
		cb.count_up <= 1'b1;
		cb.count_down <= 1'b0;
		cb.clear <= 1'b0;
		cb.rollover_val <= 4'b1000;
		cb.start <= 1'b1;
		cb.error <= 1'b0;
		
		tb_expected_count_out = 4'b0100;
		tb_expected_fifo_full = 0;
		tb_expected_fifo_empty = 0;
		@cb; // Measure slightly before the second clock edge
		cb.start <= 1'b0;
		@cb;
		@cb;
		@cb;
		@cb;
		if (tb_expected_count_out == cb.count_out)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect count", NAME, tb_test_num);
		if (tb_expected_fifo_full == cb.fifo_full)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_full flag", NAME, tb_test_num);
		if (tb_expected_fifo_empty == cb.fifo_empty)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_empty flag", NAME, tb_test_num);
		// De-assert reset for a cycle
		cb.n_rst <= 1'b1;
		@cb;

		// Test 5: Check for Proper fifo full
		cb.n_rst <= 1'b0;
		@cb;
		tb_test_num = tb_test_num + 1;
		cb.n_rst <= 1'b1;
		cb.count_up <= 1'b1;
		cb.count_down <= 1'b0;
		cb.clear <= 1'b0;
		cb.rollover_val <= 4'b1000;
		cb.start <= 1'b1;
		cb.error <= 1'b0;
		
		tb_expected_count_out = 4'b1000;
		tb_expected_fifo_full = 1;
		tb_expected_fifo_empty = 0;
		@cb; // Measure slightly before the second clock edge
		cb.start <= 1'b0;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		if (tb_expected_count_out == cb.count_out)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect count: %d", NAME, tb_test_num, cb.count_out);
		if (tb_expected_fifo_full == cb.fifo_full)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_full flag", NAME, tb_test_num);
		if (tb_expected_fifo_empty == cb.fifo_empty)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_empty flag", NAME, tb_test_num);
		// De-assert reset for a cycle
		cb.n_rst <= 1'b1;
		@cb;

		// Test 6: Check for Proper count after rollover
		cb.n_rst <= 1'b0;
		@cb;
		tb_test_num = tb_test_num + 1;
		cb.n_rst <= 1'b1;
		cb.count_up <= 1'b1;
		cb.count_down <= 1'b0;
		cb.clear <= 1'b0;
		cb.rollover_val <= 4'b1000;
		cb.start <= 1'b1;
		cb.error <= 1'b0;
		
		tb_expected_count_out = 4'b1000;
		tb_expected_fifo_full = 1;
		tb_expected_fifo_empty = 0;
		@cb; // Measure slightly before the second clock edge
		cb.start <= 1'b0;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		if (tb_expected_count_out == cb.count_out)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect count", NAME, tb_test_num);
		if (tb_expected_fifo_full == cb.fifo_full)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_full flag", NAME, tb_test_num);
		if (tb_expected_fifo_empty == cb.fifo_empty)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_empty flag", NAME, tb_test_num);
		// De-assert reset for a cycle
		cb.n_rst <= 1'b1;
		@cb;
		// Test 7: Check for Proper rollover flag
		cb.n_rst <= 1'b0;
		@cb;
		tb_test_num = tb_test_num + 1;
		cb.n_rst <= 1'b1;
		cb.count_up <= 1'b1;
		cb.count_down <= 1'b0;
		cb.clear <= 1'b0;
		cb.rollover_val <= 4'b1000;
		cb.start <= 1'b1;
		cb.error <= 1'b0;
		
		tb_expected_count_out = 4'b1000;
		tb_expected_fifo_full = 1;
		tb_expected_fifo_empty = 0;
		@cb; // Measure slightly before the second clock edge
		cb.start <= 1'b0;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		if (tb_expected_count_out == cb.count_out)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect count", NAME, tb_test_num);
		if (tb_expected_fifo_full == cb.fifo_full)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_full flag", NAME, tb_test_num);
		if (tb_expected_fifo_empty == cb.fifo_empty)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_empty flag", NAME, tb_test_num);
		// De-assert reset for a cycle
		cb.n_rst <= 1'b1;
		@cb;		
		// Test 8: edge case 1
		cb.n_rst <= 1'b0;
		@cb;
		tb_test_num = tb_test_num + 1;
		cb.n_rst <= 1'b1;
		cb.count_up <= 1'b1;
		cb.count_down <= 1'b0;
		cb.clear <= 1'b0;
		cb.rollover_val <= 4'b1111;
		cb.start <= 1'b1;
		cb.error <= 1'b0;
		
		tb_expected_count_out = 4'b1111;
		tb_expected_fifo_full = 1;
		tb_expected_fifo_empty = 0;
		@cb; // Measure slightly before the second clock edge
		cb.start <= 1'b0;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb; // Measure slightly before the second clock edge
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		if (tb_expected_count_out == cb.count_out)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect count", NAME, tb_test_num);
		if (tb_expected_fifo_full == cb.fifo_full)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_full flag", NAME, tb_test_num);
		if (tb_expected_fifo_empty == cb.fifo_empty)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_empty flag", NAME, tb_test_num);
		// De-assert reset for a cycle
		cb.n_rst <= 1'b1;
		@cb;

		// Test 9: disable count
		cb.n_rst <= 1'b0;
		@cb;
		tb_test_num = tb_test_num + 1;
		cb.n_rst <= 1'b1;
		cb.count_up <= 1'b1;
		cb.count_down <= 1'b0;
		cb.clear <= 1'b0;
		cb.rollover_val <= 4'b0100;
		cb.start <= 1'b1;
		cb.error <= 1'b0;
		
		tb_expected_count_out = 4'b0011;
		tb_expected_fifo_full = 0;
		tb_expected_fifo_empty = 0;
		@cb; // Measure slightly before the second clock edge
		cb.start <= 1'b0;
		@cb;
		@cb;
		cb.count_up <= 1'b0;
		@cb;
		@cb;
		if (tb_expected_count_out == cb.count_out)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect count: %d", NAME, tb_test_num, cb.count_out);
		if (tb_expected_fifo_full == cb.fifo_full)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_full flag", NAME, tb_test_num);
		if (tb_expected_fifo_empty == cb.fifo_empty)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_empty flag", NAME, tb_test_num);
		// De-assert reset for a cycle

		// Test 10: count down
		tb_test_num = tb_test_num + 1;
		cb.n_rst <= 1'b1;
		cb.count_up <= 1'b0;
		cb.count_down <= 1'b1;
		cb.clear <= 1'b0;
		cb.rollover_val <= 4'b0100;
		cb.start <= 1'b0;
		cb.error <= 1'b0;
		
		tb_expected_count_out = 4'b0001;
		tb_expected_fifo_full = 0;
		tb_expected_fifo_empty = 0;
		@cb; // Measure slightly before the second clock edge
		@cb;
		@cb;
		if (tb_expected_count_out == cb.count_out)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect count: %d", NAME, tb_test_num, cb.count_out);
		if (tb_expected_fifo_full == cb.fifo_full)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_full flag", NAME, tb_test_num);
		if (tb_expected_fifo_empty == cb.fifo_empty)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_empty flag", NAME, tb_test_num);
		// De-assert reset for a cycle
		cb.n_rst <= 1'b1;
		@cb;
		// Test 11: correct rollback address after error
		cb.n_rst <= 1'b0;
		@cb;
		tb_test_num = tb_test_num + 1;
		cb.n_rst <= 1'b1;
		cb.count_up <= 1'b1;
		cb.count_down <= 1'b0;
		cb.clear <= 1'b0;
		cb.rollover_val <= 4'b1100;
		cb.start <= 1'b1;
		cb.error <= 1'b0;
		
		tb_expected_count_out = 4'b0011;
		tb_expected_fifo_full = 0;
		tb_expected_fifo_empty = 0;
		@cb; // Measure slightly before the second clock edge
		cb.start <= 1'b0;
		@cb;
		@cb;
		cb.start <= 1'b1;
		@cb;
		cb.start <= 1'b0;
		@cb;
		@cb;
		@cb;
		@cb;
		@cb;
		cb.error <= 1'b1;
		@cb;
		@cb;

		if (tb_expected_count_out == cb.count_out)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect count: %d", NAME, tb_test_num, cb.count_out);
		if (tb_expected_fifo_full == cb.fifo_full)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_full flag", NAME, tb_test_num);
		if (tb_expected_fifo_empty == cb.fifo_empty)
			$info("%s Case %0d:: PASSED", NAME, tb_test_num);
		else // Test case failed
			$error("%s Case %0d:: FAILED incorrect fifo_empty flag", NAME, tb_test_num);
		// De-assert reset for a cycle
		cb.n_rst <= 1'b1;
		@cb;
	end
endmodule
		