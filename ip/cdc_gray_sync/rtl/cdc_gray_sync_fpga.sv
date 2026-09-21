module cdc_gray_sync #(
    parameter int unsigned STAGES = 2,
    parameter int unsigned WIDTH  = 8
) (
    input src_clk_i,
    input src_rst_ni,
    input dest_clk_i,
    input dest_rst_ni,
    input [WIDTH-1:0] src_counter_i,
    output logic [WIDTH-1:0] dest_counter_o
);
  xpm_cdc_gray #(
      .DEST_SYNC_FF(STAGES),
      .INIT_SYNC_FF(0),
      .REG_OUTPUT(1),
      .SIM_ASSERT_CHK(0),
      .SIM_LOSSLESS_GRAY_CHK(0),
      .WIDTH(WIDTH)
  ) xpm_cdc_gray_inst (
      .src_clk(src_clk_i),
      .src_in_bin(src_counter_i),
      .dest_clk(dest_clk_i),
      .dest_out_bin(dest_counter_o)
  );
endmodule
