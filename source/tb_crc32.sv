// $Id: $
// File name:   tb_crc32.sv
// Created:     11/28/2017
// Author:      Vishnu Gopal
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Test Bench for 32-bit CRC Checker
`timescale 1ns / 10ps

module tb_crc32();

	// Define local parameters used by the test bench
	localparam	CLK_PERIOD		= 5.3;
	
	// Declare DUT portmap signals
	logic tb_clk;
	logic tb_reset;
	logic tb_crc_en;
	logic [7:0] tb_data_in;
	logic [31:0] tb_crc_out;
	
	// Declare test bench signals
	integer tb_test_num;
	
	// Clock generation block
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end
	
	// DUT Port map
	crc32 DUT
	(
		.clk(tb_clk), 
		.reset(tb_reset), 
		.crc_en(tb_crc_en), 
		.data_in(tb_data_in), 
		.crc_out(tb_crc_out) 
	);

	// Tasks
	task data_byte([7:0]d_byte);
		tb_data_in = d_byte;
		#(CLK_PERIOD);
	endtask


	// Test bench main process
	initial
	begin
	// Initialize all of the test inputs
	tb_reset = 1'b0;
	tb_crc_en = 1'b0;
	tb_data_in = {8{1'b0}};
	tb_test_num = 0;
	#(0.1);

        // Test Case 1: Reset 
	tb_test_num = tb_test_num + 1;
	$info("Test %d", tb_test_num);
	tb_reset = 1'b1;
	#(CLK_PERIOD);
	tb_reset = 1'b0;
	#(CLK_PERIOD);
	data_byte(8'h55);
        data_byte(8'h55);
        data_byte(8'hD5);
        tb_crc_en = 1'b1;
        data_byte(8'hAB);
        data_byte(8'hCD);
        data_byte(8'hEF);
	data_byte(8'h7c);
        data_byte(8'hDF);
        data_byte(8'hAF);
        data_byte(8'h2C);

 	tb_crc_en = 1'b0;

	data_byte(8'h00);
        data_byte(8'h00);
        data_byte(8'h00);
        data_byte(8'h00);
        data_byte(8'h00);
	tb_reset = 1'b1;
	#(CLK_PERIOD);
	// Check that internal state was correctly reset
	if( {32{1'b1}} == tb_crc_out)
		$info("Correct test case 1");
	else
		$error("Incorrect test case 1");
	end
endmodule
