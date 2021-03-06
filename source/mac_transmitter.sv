// $Id: $
// File name:   mac_transmitter.sv
// Created:     12/5/2017
// Author:      Vishnu Gopal
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: .

module mac_transmitter (
  input  logic        clk,
  input  logic        reset,
  input  logic [0:7]  rd_data,
  input  logic        data_ready,
  input  logic        fifo_empty,

  output logic [2:0]  mac_tr_state,
  output logic        rd_en,
  output logic        rd_start,
  output logic [7:0]  txd,   
  output logic        txen  
  );
  
  localparam MIN_PAYLOAD = 46;
  localparam MAX_PAYLOAD = 1500;
  localparam MIN_FRAME = MIN_PAYLOAD+6+6+2;
  localparam MAX_FRAME = MAX_PAYLOAD+6+6+2;
  localparam PREAMBLE_LENGTH = 7;
  localparam FCS_LENGTH = 4;
  localparam PAD_LENGTH = 4;
  localparam IFG_LENGTH = 4;
  localparam PREAMBLE_DEFDATA = 8'h55;
  localparam SFD_DEFDATA = 8'hD5;
  localparam IFG_DEFDATA = 8'h00;
  
  typedef enum {
    IDLE,
    PREAMBLE,
    SFD,
    DATA,
    PAD,
    FCS,
    IFG
  } state_type;
  
  state_type state = IDLE;
  
  localparam RD_COUNT_BITS = $clog2(MAX_FRAME);
  logic [RD_COUNT_BITS-1:0] rd_count = {RD_COUNT_BITS{1'b0}};
  logic old_rd_en = 0;
  
  logic [FCS_LENGTH*8-1:0] crc_val;
  logic [7:0] fcs [FCS_LENGTH];
  
  genvar i;
  generate
    for (i=0; i<FCS_LENGTH; i++) begin
      assign fcs[FCS_LENGTH-1-i] = crc_val[8*i+7:8*i];
    end
  endgenerate
  
  logic frame_valid;
  assign frame_valid = state == PREAMBLE 
              | state == SFD 
              | state == DATA
	      | state == PAD 
              | state == FCS; 
  
  always_ff @(posedge clk) begin
    if (reset) begin
        txd <= IFG_DEFDATA;
    end else begin
    case (state)
      IDLE     : txd <= IFG_DEFDATA;
      PREAMBLE : txd <= PREAMBLE_DEFDATA;
      SFD      : txd <= SFD_DEFDATA;
      DATA     : txd <= fifo_empty ? IFG_DEFDATA: rd_data;
      PAD      : txd <= IFG_DEFDATA;
      FCS      : txd <= fcs[rd_count[$clog2(FCS_LENGTH)-1:0]];
      default  : txd <= IFG_DEFDATA;
    endcase
  end
  end
  
  always_ff @(posedge clk) begin
	if (reset) begin
      		txen <= 1'b0;
    	end else begin    
		txen <= frame_valid;
	end
  end

  always_comb begin
	mac_tr_state = state;
 end

  always_ff @(posedge clk) begin
    if (reset) begin
      old_rd_en <= 1'b0;
    end else begin
      old_rd_en <= rd_en;
    end
  end

  always_comb begin
    rd_start = rd_en & ~old_rd_en;
  end
  
  always_ff @(posedge clk) begin
    if (reset) begin
      state <= IDLE;
      rd_count <= {RD_COUNT_BITS{1'b0}};
	rd_en = 0;
    end else begin
      case (state)
        IDLE : begin
          if (data_ready) begin
            state <= PREAMBLE;
          end
        end
        PREAMBLE : begin
          if (rd_count >= PREAMBLE_LENGTH-2) begin
            rd_count <= {RD_COUNT_BITS{1'b0}};
            state <= SFD;
          end else begin
            rd_count <= rd_count + 1;
          end
        end
        SFD : begin
          rd_en = 1'b1;
          state <= DATA;
        end
        DATA : begin
          rd_en = 1'b1;
          if (rd_count >= MAX_FRAME-1) begin
            rd_count <= {RD_COUNT_BITS{1'b0}};
            state <= FCS;
          end else if (fifo_empty) begin
		rd_en = 1'b0;
            rd_count <= {RD_COUNT_BITS{1'b0}};
            state <= PAD;
          end else begin
            rd_count <= rd_count + 1;
          end
        end
        PAD : begin
	  rd_en = 1'b0;
          if (rd_count >= PAD_LENGTH-1) begin
            rd_count <= {RD_COUNT_BITS{1'b0}};
            state <= FCS;
          end else begin
            rd_count <= rd_count + 1;
          end
        end
        FCS : begin
          if (rd_count >= FCS_LENGTH-1) begin
            rd_count <= {RD_COUNT_BITS{1'b0}};
            state <= IFG;
          end else begin
            rd_count <= rd_count + 1;
	    $info("txd: %b", txd);
          end
        end
        IFG : begin
          if (rd_count >= IFG_LENGTH-1) begin
            rd_count <= {RD_COUNT_BITS{1'b0}};
            state <= IDLE;
          end else begin
            rd_count <= rd_count + 1;
          end
        end
        default : begin
          state <= IDLE;
          rd_count <= {RD_COUNT_BITS{1'b0}};
        end
      endcase
    end
  end
  
  crc32 crc32_inst2 (
    .clk     (clk),
    .reset   (state == IDLE | reset),
    .crc_en  (state == DATA),
    .data_in (rd_data),
    .crc_out (crc_val)
  );

endmodule