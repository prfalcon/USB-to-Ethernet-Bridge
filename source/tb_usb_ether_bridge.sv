// $Id: $
// File name:   tb_usb_ether_bridge.sv
// Created:     12/6/2017
// Author:      Alexandria Symanski
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: test bench for top level design
`timescale 1ns / 10ps

module tb_usb_ether_bridge ();

	// Define parameters
	// basic test bench parameters
	localparam	CLK_PERIOD	= 5.2;
	
	// Dut portmap 
	reg tb_clk;
	reg tb_n_rst;
	reg tb_d_plus_in;
	reg tb_d_minus_in;
	reg [7:0] tb_rxd;
	reg tb_rxdv;
	reg tb_rxer;
	reg tb_data_ready;
	wire tb_d_plus_out;
	wire tb_d_minus_out;
	wire [7:0] tb_txd;
	wire tb_txen;


	//Test bench signals
	integer tb_test_num;
	string test_phase;
	reg s_bit;

	//Test checking variables
	
	// Clock generation block
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end

	//DUT Portmap
	usb_ether_bridge DUT
	(
		.clk(tb_clk),
		.n_rst(tb_n_rst),
		.d_plus_in(tb_d_plus_in),
		.d_minus_in(tb_d_minus_in),
		.rxd(tb_rxd),
		.rxdv(tb_rxdv),
		.rxer(tb_rxer),
		.data_ready(tb_data_ready),
		.d_plus_out(tb_d_plus_out),
		.d_minus_out(tb_d_minus_out),
		.txd(tb_txd),
		.txen(tb_txen)
	);

	//Tasks
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


	task send_bit(n_bit);
		integer i;
	begin
		tb_d_plus_in = n_bit;
		tb_d_minus_in = !n_bit;
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

	task data_byte([7:0]d_byte);
		tb_rxd = d_byte;
		#(CLK_PERIOD);
	endtask

	//Test Bench Main Process
	initial
	begin
		tb_n_rst = 1;
		tb_d_plus_in = 1;
		tb_d_minus_in = 0;
		tb_rxd = '0;
		tb_rxdv = 0;
		tb_rxer = 0;
		tb_data_ready = 0;
		tb_test_num = 0;

		reset_dut;	

		// Test Case 1: out_token 
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		test_phase = "SYNC";
		//Send Sync
		send_byte(8'b01010100);

		//Send PID	
		test_phase = "out_token PID";
		send_byte(8'b10110000);
		
		//Send Address
		test_phase = "ADDR";
		send_byte(8'b11000110);
		 
		//Send ENDP (is ignored in design, but affects CRC)
		test_phase = "ENDP";
		send_byte(8'b01100011);
		
		//Send CRC
		test_phase = "sending crc";
		send_crc5(5'b01101);	
		//want 11011 in checker 01101
		@(negedge tb_clk);
		
		//EOP
		test_phase = "EOP";
		tb_d_plus_in = 0;
		tb_d_minus_in = 0;
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		
		tb_d_plus_in = 1;
		
		#(CLK_PERIOD)
		#(CLK_PERIOD)
		#(CLK_PERIOD)
		
		// Test Case 2: data packet
		//tb_test_num = tb_test_num + 1;
		//$info("Test %d", tb_test_num);

		test_phase = "SYNC";
		//Send Sync
		send_byte(8'b01010100);
	
		//Send PID	
		test_phase = "data PID";
		send_byte(8'b00101000);
		
		test_phase = "packet data";

		send_byte(8'b11000110);			
		send_byte(8'b01011001);
		send_byte(8'b10101001);
		
		test_phase = "send crc";
		send_crc16(16'b0101001100000111);
		//desired crc: 1111101010000100

		//EOP
		test_phase = "EOP";
		tb_d_plus_in = 0;
		tb_d_minus_in = 0;
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		
		tb_d_plus_in = 1;

		#(CLK_PERIOD)
		#(CLK_PERIOD)
		#(CLK_PERIOD)

		// Test Case 2: success data packet
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		test_phase = "SYNC";
		//Send Sync
		send_byte(8'b01010100);

		//Send PID	
		test_phase = "out_token PID";
		send_byte(8'b10110000);
		
		//Send Address
		test_phase = "ADDR";
		send_byte(8'b11000110);
		 
		//Send ENDP (is ignored in design, but affects CRC)
		test_phase = "ENDP";
		send_byte(8'b01100011);
		
		//Send CRC
		test_phase = "sending crc";
		send_crc5(5'b01101);	
		//want 11011 in checker 01101
		@(negedge tb_clk);
		
		//EOP
		test_phase = "EOP";
		tb_d_plus_in = 0;
		tb_d_minus_in = 0;
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		
		tb_d_plus_in = 1;
		
		#(CLK_PERIOD)
		#(CLK_PERIOD)
		#(CLK_PERIOD)
		//Add bytes
		test_phase = "SYNC";
		//Send Sync
		send_byte(8'b01010100);
	
		//Send PID	
		test_phase = "data PID";
		send_byte(8'b00101000);
		
		test_phase = "packet data";
		
		send_byte(8'b11000110);			
		//NRZI 10100101
		send_byte(8'b01011001);
		//NRZI 01110101
		send_byte(8'b10101001);
		//NRZI 01111101
		
		test_phase = "send crc";
		send_crc16(16'b1101101010001000);
		//desired crc: 0011011111001100

		//EOP
		test_phase = "EOP";
		tb_d_plus_in = 0;
		tb_d_minus_in = 0;
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		
		//tb_d_plus_in = 1;

		//MAC TRANSMIT                 
                tb_data_ready = 1'b1;
		#(CLK_PERIOD);
	        #(CLK_PERIOD);
		tb_data_ready = 1'b0;
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		//END MAC TRANSMIT

		//MAC RECEIVE
		tb_rxdv = 1'b1;
		data_byte(8'h55);
		data_byte(8'h55);
		data_byte(8'h55);
		data_byte(8'hD5);
		data_byte(8'hAB);
		data_byte(8'hCD);
		data_byte(8'hEF); 
		data_byte(8'h00);
		data_byte(8'h00);
		data_byte(8'h00);
		data_byte(8'h00);
		data_byte(8'h00);
		tb_rxdv = 1'b0;
		#(CLK_PERIOD);
		tb_d_plus_in = 1;
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		//END MAC RECEIVE

		test_phase = "SYNC";
		//Send Sync
		send_byte(8'b01010101);
		send_byte(8'b01010100);

		//Send PID	
		test_phase = "out_token PID";
		send_byte(8'b01001110);
		
		//Send Address
		test_phase = "ADDR";
		send_byte(8'b11000110);
		 
		//Send ENDP (is ignored in design, but affects CRC)
		test_phase = "ENDP";
		send_byte(8'b01100011);
		
		//Send CRC
		test_phase = "sending crc";
		send_crc5(5'b01101);	
		//want 11011 in checker 01101
		@(negedge tb_clk);
		
		//EOP
		test_phase = "EOP";
		tb_d_plus_in = 0;
		tb_d_minus_in = 0;
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		
		tb_d_plus_in = 1;
		
		#(CLK_PERIOD)
		#(CLK_PERIOD)
		#(CLK_PERIOD)

		test_phase = "SYNC";
		//Send Sync
		send_byte(8'b01010100);
	
		//Send PID	
		test_phase = "ack PID";
		send_byte(8'b11011000);
		
		#(CLK_PERIOD)
	
		//EOP
		test_phase = "EOP";
		tb_d_plus_in = 0;
		tb_d_minus_in = 0;
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		
		tb_d_plus_in = 1;

		#(CLK_PERIOD)
		#(CLK_PERIOD)
		#(CLK_PERIOD);

	end
endmodule
