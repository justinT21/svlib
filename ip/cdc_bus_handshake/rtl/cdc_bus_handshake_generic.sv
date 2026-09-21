module cdc_bus_handshake #(
    parameter int STAGES = 2,
    parameter int WIDTH = 8,
    parameter int DEST_EXT_HSK = 1
) (
    input src_clk_i,
    input src_rst_ni,
    input src_send_i,
    input [WIDTH-1:0] src_data_i,
    input dest_clk_i,
    input dest_rst_ni,
    input dest_ack_i,
    output logic src_rcv_o,
    output logic dest_ready_o,
    output logic [WIDTH-1:0] dest_data_o
);
  logic req_out, sync_req;
  logic ack_out, sync_ack;
  logic [WIDTH-1:0] src_data_reg;

  cdc_bit_sync #(
      .STAGES(STAGES)
  ) sync_req_inst (
      .clk_i(dest_clk_i),
      .rst_ni(dest_rst_ni),
      .d_i(req_out),
      .q_o(sync_req)
  );

  cdc_bit_sync #(
      .STAGES(STAGES)
  ) sync_ack_inst (
      .clk_i(src_clk_i),
      .rst_ni(src_rst_ni),
      .d_i(ack_out),
      .q_o(sync_ack)
  );

  typedef enum logic [1:0] {
    SRC_IDLE,
    SRC_WAIT_ACK,
    SRC_WAIT_ACK_DROP
  } src_state_t;
  src_state_t src_state;

  always_ff @(posedge src_clk_i or negedge src_rst_ni) begin
    if (!src_rst_ni) begin
      src_state <= SRC_IDLE;
      req_out <= 1'b0;
      src_rcv_o <= 1'b0;
      src_data_reg <= '0;
    end else begin
      src_rcv_o <= 1'b0;
      unique case (src_state)
        SRC_IDLE: begin
          if (src_send_i) begin
            src_data_reg <= src_data_i;
            req_out <= 1'b1;
            src_state <= SRC_WAIT_ACK;
          end
        end
        SRC_WAIT_ACK: begin
          if (sync_ack) begin
            req_out   <= 1'b0;
            src_rcv_o <= 1'b1;
            src_state <= SRC_WAIT_ACK_DROP;
          end
        end
        SRC_WAIT_ACK_DROP: begin
          if (!sync_ack) begin
            src_state <= SRC_IDLE;
          end
        end
      endcase
    end
  end

  typedef enum logic [1:0] {
    DEST_IDLE,
    DEST_WAIT_ACK,
    DEST_WAIT_REQ_DROP
  } dest_state_t;
  dest_state_t dest_state;

  always_ff @(posedge dest_clk_i or negedge dest_rst_ni) begin
    if (!dest_rst_ni) begin
      dest_state <= DEST_IDLE;
      dest_ready_o <= 1'b0;
      ack_out <= 1'b0;
      dest_data_o <= '0;
    end else begin
      unique case (dest_state)
        DEST_IDLE: begin
          if (sync_req) begin
            dest_data_o  <= src_data_reg;
            dest_ready_o <= 1'b1;
            if (DEST_EXT_HSK) begin
              dest_state <= DEST_WAIT_ACK;
            end else begin
              ack_out <= 1'b1;
              dest_state <= DEST_WAIT_REQ_DROP;
            end
          end
        end
        DEST_WAIT_ACK: begin
          if (dest_ack_i) begin
            dest_ready_o <= 1'b0;
            ack_out <= 1'b1;
            dest_state <= DEST_WAIT_REQ_DROP;
          end
        end
        DEST_WAIT_REQ_DROP: begin
          dest_ready_o <= 1'b0;
          if (!sync_req) begin
            ack_out <= 1'b0;
            dest_state <= DEST_IDLE;
          end
        end
      endcase
    end
  end
endmodule
