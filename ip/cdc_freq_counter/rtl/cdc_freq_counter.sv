module cdc_freq_counter #(
    parameter int unsigned WINDOW_CYCLES = 8,
    parameter int unsigned COUNTER_WIDTH = 12,
    parameter int unsigned STAGES = 2
) (
    input ref_clk_i,
    input ref_rst_ni,
    input target_clk_i,
    output logic [COUNTER_WIDTH-1:0] slowness_factor
);
  `include "formal_macros.svh"
  `ASSERT_INIT(CheckWindowCyclesPower2_A, $onehot(WINDOW_CYCLES))
  `ASSERT_INIT(CheckCounterWidthFits_A, COUNTER_WIDTH >= $clog2(WINDOW_CYCLES + STAGES + 1))
  localparam int unsigned WindowBits = $clog2(WINDOW_CYCLES);

  logic target_rst_n;
  logic [COUNTER_WIDTH-1:0]
      ref_counter,
      target_counter,
      target_ref_counter,
      target_ref_last_counter,
      target_slowness_factor;

  always_ff @(posedge ref_clk_i or negedge ref_rst_ni) begin : ref_counter_blk
    if (!ref_rst_ni) begin
      ref_counter <= '0;
    end else begin
      ref_counter <= ref_counter + 1'b1;
    end
  end

  logic slowness_update_req;

  always_ff @(posedge target_clk_i or negedge target_rst_n) begin : target_counter_blk
    if (!target_rst_n) begin
      target_counter <= '0;
      target_ref_last_counter <= '0;
      target_slowness_factor <= '0;
      slowness_update_req <= 1'b0;
    end else begin
      target_counter <= target_counter + 1'b1;
      slowness_update_req <= 1'b0;
      if (target_counter == (WINDOW_CYCLES + STAGES)) begin
        target_slowness_factor <= (target_ref_counter - target_ref_last_counter) >> WindowBits;
        target_ref_last_counter <= target_ref_counter;
        target_counter <= STAGES + 1'b1;
        slowness_update_req <= 1'b1;
      end
    end
  end

  cdc_bus_handshake #(
      .STAGES(STAGES),
      .WIDTH(COUNTER_WIDTH),
      .DEST_EXT_HSK(0)
  ) target_ref_slowness_factor (
      .src_clk_i(target_clk_i),
      .src_rst_ni(target_rst_n),
      .src_send_i(slowness_update_req),
      .src_data_i(target_slowness_factor),
      .dest_clk_i(ref_clk_i),
      .dest_rst_ni(ref_rst_ni),
      .dest_ack_i(1'b0),
      .src_rcv_o(),
      .dest_ready_o(),
      .dest_data_o(slowness_factor)
  );

  cdc_gray_sync #(
      .STAGES(STAGES),
      .WIDTH (COUNTER_WIDTH)
  ) target_to_ref_counter (
      .src_clk_i(ref_clk_i),
      .src_rst_ni(ref_rst_ni),
      .dest_clk_i(target_clk_i),
      .dest_rst_ni(target_rst_n),
      .src_counter_i(ref_counter),
      .dest_counter_o(target_ref_counter)
  );

  cdc_async_rst #(
      .STAGES(STAGES)
  ) rst_synchronizer (
      .clk_i (target_clk_i),
      .rst_ni(ref_rst_ni),
      .rst_no(target_rst_n)
  );
endmodule
