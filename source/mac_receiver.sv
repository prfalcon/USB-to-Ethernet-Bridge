module mac_receiver (
  input  logic        clk,
  input  logic        reset,
  
  input  logic [7:0]  rxd,       
  input  logic        rxdv,      
  input  logic        rxer,      
  input  logic        fifo_full,

  output logic [1:0]  mac_rec_state,
  output logic        wr_en,
  output logic        wr_start,
  output logic        wr_error,
  output logic [7:0]  wr_data 
  );
  
  localparam MIN_PAYLOAD = 46;
  localparam MAX_PAYLOAD = 1500;
  localparam MIN_FRAME = MIN_PAYLOAD+6+6+2;
  localparam MAX_FRAME = MAX_PAYLOAD+6+6+2;
  localparam PREAMBLE = 7;
  localparam FCS_LENGTH = 4;
  localparam IFG_LENGTH = 12;
  localparam PREAMBLE_DEFDATA = 8'h55;
  localparam SFD_DEFDATA = 8'hD5;
  localparam IFG_DEFDATA = 8'h00;
  localparam CRC32_RESIDUE = 32'hC704DD7B; 
  localparam RD_COUNT_BITS = $clog2(MAX_FRAME);

  
  typedef enum {
    IDLE, 
    RD_DATA,
    SKIP_FRAME
  } state_type;
  state_type state = IDLE;

  always_comb begin
	mac_rec_state = state;
  end
  
  logic [RD_COUNT_BITS-1:0] rd_count = {RD_COUNT_BITS{1'b0}};
  logic [FCS_LENGTH*8-1:0] crc_val;

  logic old_wr_en = 0;

  always_ff @(posedge clk) begin
    if (reset) begin
      old_wr_en <= 1'b0;
    end else begin
      old_wr_en <= wr_en;
    end
  end
  
  logic [31:0]temp;
  assign temp = crc_val;

  always_comb begin
    wr_start = wr_en & ~old_wr_en;
  end
  
  always_ff @(posedge clk) begin
    if(reset) begin
      wr_error <= 1'b0;
    end else
    if (state == RD_DATA && ~rxdv) begin
      wr_error <= rxer | rd_count >= MAX_FRAME+FCS_LENGTH-1 | crc_val == CRC32_RESIDUE;// | rd_count <= MIN_FRAME+FCS_LENGTH-1;
    end else if(state == SKIP_FRAME) begin
      wr_error <= 1'b1;
    end else begin
      wr_error <= fifo_full;
    end
  end
  
  always_ff @(posedge clk) begin
    if(reset | ~rxdv) begin
      wr_data <= {8{1'b0}};
    end else begin
      wr_data <= rxd;
    end
  end
  
  always_ff @(posedge clk) begin
    if (reset) begin
      wr_en = 1'b0;
      state <= IDLE;
      rd_count <= {RD_COUNT_BITS{1'b0}};
    end else if (1) begin
      case (state)
        IDLE : begin
          wr_en = 0;
          if (rxdv && rxer) begin
            state <= SKIP_FRAME;
          end else if (rxdv && rxd == SFD_DEFDATA) begin
            state <= RD_DATA;
          end else if (rxdv && rxd == PREAMBLE_DEFDATA) begin
            state <= IDLE;
          end else if (rxdv) begin
            state <= SKIP_FRAME;
          end
        end
        RD_DATA : begin
          wr_en = 1;
          if ((rxdv && rd_count >= MAX_FRAME+FCS_LENGTH-1) | rxer) begin
            state <= SKIP_FRAME;
            rd_count <= {RD_COUNT_BITS{1'b0}};
          end else if (rxdv) begin
            rd_count <= rd_count + 1;
          end else begin
	    wr_en = 1'b0;
            state <= IDLE;
            rd_count <= {RD_COUNT_BITS{1'b0}};
          end
        end
        SKIP_FRAME : begin
          wr_en = 0;
          if (~rxdv) begin
            state <= IDLE;
          end
        end
        default : begin
          state <= IDLE;
          rd_count <= {RD_COUNT_BITS{1'b0}};
        end
      endcase
    end
  end
  
  crc32 crc32_inst (
    .clk     (clk),
    .reset   (state == IDLE | reset),
    .crc_en  (state == RD_DATA),
    .data_in (rxd),
    .crc_out (crc_val)
  );
  
endmodule
