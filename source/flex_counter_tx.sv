// $ID: mg 82
// File name: flex_counter.sv 
// Author: Akshay Raj

module flex_counter_tx
	#(
		parameter	NUM_CNT_BITS = 4
	)
	(
		input wire 	clk,
				n_rst,
				clear,
				count_enable,
		input wire 	[NUM_CNT_BITS-1:0]rollover_val,
		output reg	[NUM_CNT_BITS-1:0]count_out,
		output reg	rollover_flag
	);
	
		reg [NUM_CNT_BITS-1:0]intrim_count ;
		reg intrim_flag ;
		
		always_comb
		begin
			intrim_count = count_out ;
			if (clear)
			begin
				intrim_count = '0 ;
			end
			else
			begin
				if (count_enable)
				begin
					if (count_out == rollover_val)
						intrim_count = 1 ;
					else
					begin
						intrim_count = count_out + 1'b1 ;
					end			
				end
			end
		end
							
		always_comb
		begin
			intrim_flag = '0;
			if (clear)
			begin
				intrim_flag = '0 ;
			end
			else
			begin
				if (count_enable)
				begin
					if (count_out == rollover_val - 1'b1)
						intrim_flag = 1'b1;
					else if (count_out == 1 && rollover_val == 1)
						intrim_flag = 1'b1;
					else
						intrim_flag = 1'b0 ;
				end
				else
						intrim_flag = rollover_flag ;
			end
		end
	
		always_ff @ (posedge clk, negedge n_rst) 
		begin
			if (n_rst == 1'b0)
			begin
				count_out <= '0 ;
			end
			else
				count_out <= intrim_count ;
		end 
	
		always_ff @ (posedge clk, negedge n_rst) 
		begin
			if (n_rst == 1'b0)
			begin
				rollover_flag <= '0 ;
			end
			else
				rollover_flag <= intrim_flag ;
		end 
	
	endmodule
