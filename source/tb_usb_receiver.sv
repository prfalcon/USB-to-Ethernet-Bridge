// $Id: $
// File name:   tb_usb_receiver.sv
// Created:     11/28/2017
// Author:      Alexandria Symanski
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Test Bench for USB Receiver
`timescale 1ns / 10ps

module tb_usb_receiver();

	// Define local parameters used by the test bench
	localparam	CLK_PERIOD		= 5.2;

	reg s_bit;	
	string test_phase;

	// Declare DUT portmap signals
	reg tb_clk;
	reg tb_n_rst;
	reg tb_d_plus;
	reg tb_d_minus;
	wire tb_crc_err;
	wire tb_in_token;
	wire tb_out_token;
	wire tb_byte_ready;
	wire tb_host_ack;
	wire tb_host_nack;	
	wire tb_eop_found;
	wire [7:0] tb_data_byte;
	
	// Declare test bench signals
	integer tb_test_num;
	string tb_test_case;
	
	reg ex_crc_err;
	reg ex_in_token;
	reg ex_out_token;
	reg ex_byte_ready;
	reg ex_host_ack;
	reg ex_host_nack;
	reg ex_eop_found;
	reg [7:0] ex_data_byte;
			
	
	// Clock generation block
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end
	
	// DUT Port map
	usb_receiver DUT
	(
		.clk(tb_clk), 
		.n_rst(tb_n_rst), 
		.d_plus(tb_d_plus), 
		.d_minus(tb_d_minus), 
		.crc_err(tb_crc_err), 
		.in_token(tb_in_token),
		.out_token(tb_out_token),
		.byte_ready(tb_byte_ready),
		.host_ack(tb_host_ack),
		.host_nack(tb_host_nack),
		.eop_found(tb_eop_found),
		.data_byte(tb_data_byte)
	);

	// Tasks
	task reset_dut;
	begin
		//Activate design's reset
		tb_n_rst = 0;
		
		//wait for a couple clock clycles
		@(posedge tb_clk);
		@(posedge tb_clk);

		//Release the reset
		@(negedge tb_clk);
		tb_n_rst = 1;

		//wait for a while before activating the design
		@(posedge tb_clk);
		@(posedge tb_clk);
	end
	endtask

	task check_output;
		input ex_crc_err;
		input ex_in_token;
		input ex_out_token;
		input ex_byte_ready;
		input ex_host_ack;
		input ex_host_nack;
		input ex_eop_found;
		input [7:0] ex_data_byte; 
	begin
		if( ex_crc_err == tb_crc_err)
			$info("correct crc_err output");
		else
			$error("WRONG crc_err output");
		if( ex_in_token == tb_in_token)
			$info("correct in_token output");
		else
			$error("WRONG in_token output");
		if( ex_out_token == tb_out_token)
			$info("correct out_token output");
		else
			$error("WRONG out_token output");
		if( ex_byte_ready == tb_byte_ready)
			$info("correct byte_ready output");
		else
			$error("WRONG byte_ready output");
		if( ex_host_ack == tb_host_ack)
			$info("correct host_ack output");
		else
			$error("WRONG host_ack output");
		if( ex_host_nack == tb_host_nack)
			$info("correct host_nack output");
		else
			$error("WRONG host_nack output");
		if( ex_eop_found == tb_eop_found)
			$info("correct eop_found output");
		else
			$error("WRONG eop_found output");
		if( ex_data_byte == tb_data_byte) 
			$info("correct data_byte output");
		else 
			$error("WRONG data_byte output");
	end
	endtask
	
	task send_bit(n_bit);
		integer i;
	begin
		tb_d_plus = n_bit;
		tb_d_minus = !n_bit;
		for(i=15; i >= 0; i = i -1)
		begin
			@(negedge tb_clk);
		end
	end
	endtask

	task send_byte([7:0]n_byte);
		integer i;
	begin
		for(i=7; i >= 0; i = i - 1) 
		begin
			s_bit = n_byte[i];
			send_bit(s_bit);
		end
	end
	endtask

	task send_crc16([15:0]n_byte);
		integer i;
	begin
		for(i=15; i >= 0; i = i - 1) 
		begin
			s_bit = n_byte[i];
			send_bit(s_bit);
		end
	end
	endtask

	task send_crc5([4:0]n_byte);
		integer i;
	begin
		for(i=4; i >= 0; i = i - 1) 
		begin
			s_bit = n_byte[i];
			send_bit(s_bit);
		end
	end
	endtask


	// Test bench main process
	initial
	begin
		// Initialize all of the test inputs
		tb_n_rst	= 1'b1;		// Initialize to be inactive
		tb_d_plus 	= 1'b1;
		tb_d_minus 	= 1'b0;
		tb_test_num = 0;
		tb_test_case = "Test bench initializaton";
		#(0.1);

		// Test Case 1: Reset 
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "Reset";
		test_phase = "reset";

		reset_dut;
		
		#(CLK_PERIOD)
		
		ex_crc_err = 1'b0;
		ex_in_token = 1'b0;
		ex_out_token = 1'b0;
		ex_byte_ready = 1'b0;
		ex_host_ack = 1'b0;
		ex_host_nack = 1'b0;
		ex_eop_found = 1'b0;
		ex_data_byte = 8'b11111111;
			
		check_output(ex_crc_err, ex_in_token, ex_out_token, ex_byte_ready, ex_host_ack, ex_host_nack, ex_eop_found, ex_data_byte);
		
		// Test Case 2: in_token 
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "in_token";
		test_phase = "reset";
		reset_dut;	
		test_phase = "SYNC";
		//Send Sync
		send_byte(8'b01010100);
	
		ex_crc_err = 1'b0;
		ex_in_token = 1'b0;
		ex_out_token = 1'b0;
		ex_byte_ready = 1'b0;
		ex_host_ack = 1'b0;
		ex_host_nack = 1'b0;
		ex_data_byte = 8'b01111111;
		//Send PID	
		test_phase = "in_token PID";
		send_byte(8'b01001110);
		ex_data_byte = 8'b10010110;
		
		//Send Address
		test_phase = "ADDR";
		send_byte(8'b11000110);
		ex_data_byte = 8'b10100101;
		 
		//Send ENDP (is ignored in design, but affects CRC)
		test_phase = "ENDP";
		send_byte(8'b01100011);
		ex_data_byte = 8'b01010010;
		
		//Send CRC
		test_phase = "sending crc";
		send_crc5(5'b01101);	
		//want 11011 in checker 01101

		#(CLK_PERIOD)
		
		//EOP
		test_phase = "EOP";
		tb_d_plus = 0;
		tb_d_minus = 0;
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		
		//CRC5 check
		test_phase = "check crc5";
		ex_crc_err = 0;	
		
		#(CLK_PERIOD)
		#(CLK_PERIOD)

		check_output(ex_crc_err, ex_in_token, ex_out_token, ex_byte_ready, ex_host_ack, ex_host_nack, ex_eop_found, ex_data_byte);

		// Test Case 2: out_token 
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "out_token";
		test_phase = "reset";
		reset_dut;	
		test_phase = "SYNC";
		//Send Sync
		send_byte(8'b01010100);
	
		ex_crc_err = 1'b0;
		ex_in_token = 1'b0;
		ex_out_token = 1'b0;
		ex_byte_ready = 1'b0;
		ex_host_ack = 1'b0;
		ex_host_nack = 1'b0;
		ex_data_byte = 8'b01111111;
		//Send PID	
		test_phase = "out_token PID";
		send_byte(8'b10110000);
		ex_data_byte = 8'b00010111;
		
		//Send Address
		test_phase = "ADDR";
		send_byte(8'b11000110);
		ex_data_byte = 8'b10100101;
		 
		//Send ENDP (is ignored in design, but affects CRC)
		test_phase = "ENDP";
		send_byte(8'b01100011);
		ex_data_byte = 8'b01010010;
		
		//Send CRC
		test_phase = "sending crc";
		send_crc5(5'b01101);	
		//want 11011 in checker 01101
		@(negedge tb_clk);
		
		//EOP
		test_phase = "EOP";
		tb_d_plus = 0;
		tb_d_minus = 0;
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		
		//CRC5 check
		test_phase = "check crc5";
		ex_crc_err = 0;	

		#(CLK_PERIOD)
		#(CLK_PERIOD)
		check_output(ex_crc_err, ex_in_token, ex_out_token, ex_byte_ready, ex_host_ack, ex_host_nack, ex_eop_found, ex_data_byte);
		
		// Test Case 3: ack from host
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "host ack";
		test_phase = "reset";

		reset_dut;	
		test_phase = "SYNC";
		//Send Sync
		send_byte(8'b01010100);
	
		ex_crc_err = 1'b0;
		ex_in_token = 1'b0;
		ex_out_token = 1'b0;
		ex_byte_ready = 1'b0;
		ex_host_ack = 1'b0;
		ex_host_nack = 1'b0;
		ex_data_byte = 8'b01111111;
		//Send PID	
		test_phase = "ack PID";
		send_byte(8'b11011000);
		ex_data_byte = 8'b00101101;
		
		#(CLK_PERIOD)
	
		//EOP
		test_phase = "EOP";
		tb_d_plus = 0;
		tb_d_minus = 0;
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);

		check_output(ex_crc_err, ex_in_token, ex_out_token, ex_byte_ready, ex_host_ack, ex_host_nack, ex_eop_found, ex_data_byte);
		
		// Test Case 4: nack from host
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "host nack";
		test_phase = "reset";
		reset_dut;	
		test_phase = "SYNC";
		//Send Sync
		send_byte(8'b01010100);
	
		ex_crc_err = 1'b0;
		ex_in_token = 1'b0;
		ex_out_token = 1'b0;
		ex_byte_ready = 1'b0;
		ex_host_ack = 1'b0;
		ex_host_nack = 1'b0;
		ex_data_byte = 8'b01111111;
		//Send PID	
		test_phase = "nack PID";
		send_byte(8'b11000110);
		ex_data_byte = 8'b10100101;
		
		#(CLK_PERIOD)
	
		//EOP
		test_phase = "EOP";
		tb_d_plus = 0;
		tb_d_minus = 0;
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);

		check_output(ex_crc_err, ex_in_token, ex_out_token, ex_byte_ready, ex_host_ack, ex_host_nack, ex_eop_found, ex_data_byte);
		
		// Test Case 5: data packet
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "host nack";
		test_phase = "reset";

		reset_dut;	
		test_phase = "SYNC";
		//Send Sync
		send_byte(8'b01010100);
	
		ex_crc_err = 1'b0;
		ex_in_token = 1'b0;
		ex_out_token = 1'b0;
		ex_byte_ready = 1'b0;
		ex_host_ack = 1'b0;
		ex_host_nack = 1'b0;
		ex_data_byte = 8'b01111111;
		//Send PID	
		test_phase = "data PID";
		send_byte(8'b00101000);
		ex_data_byte = 8'b00111100;
		
		test_phase = "packet data";

		send_byte(8'b11000110);			
		send_byte(8'b01011001);
		send_byte(8'b10101001);
		
		//test_phase = "send crc"
		//send_crc16(16'b0101001100000111);
		//desired crc: 1111101010000100

		//EOP
		test_phase = "EOP";
		tb_d_plus = 0;
		tb_d_minus = 0;
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);

		check_output(ex_crc_err, ex_in_token, ex_out_token, ex_byte_ready, ex_host_ack, ex_host_nack, ex_eop_found, ex_data_byte);


	end
endmodule

