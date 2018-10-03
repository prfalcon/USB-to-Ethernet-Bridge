// $ID: mg 82
// File name: nrzi_encode.sv 
// Author: Akshay Raj
// Lab Section: Wednesday
module nrzi_encode (
		input wire	clk,
				n_rst,
				pause,
				d_orig,
				flag_8,
				eop,
		output reg	d_plus,
				d_minus
	) ;
	
		reg prev_d;
	
		always_ff @ (posedge clk, negedge n_rst) begin
			if (n_rst == 1'b0) begin
				d_plus <= 1;
				d_minus <= 1;
				prev_d <= 1;
			end else if (eop & flag_8) begin
				d_plus <= 0;
				d_minus <= 0;
			end else if (!pause & !eop) begin
				if (flag_8) begin
					if (d_orig == prev_d) begin
						d_plus <= 1;
						d_minus <= 0;
						prev_d <= d_orig;
					end else begin
						d_plus <= 0;
						d_minus <= 1;
						prev_d <= d_orig;
					end
				end else begin
					d_plus <= d_plus;
					d_minus <= d_minus;
				end
			end else if (pause & !eop) begin
				if (flag_8) begin
					d_plus <= 0;
					d_minus <= 1;
				end else begin
					d_plus <= d_plus;
					d_minus <= d_minus;
				end
			end else begin
				d_plus <= d_plus;
				d_minus <= d_minus;
			end	
		end
	endmodule