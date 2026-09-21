module cdc_bit_sync #(
    parameter int unsigned STAGES = 2,
    parameter logic INIT   = 1'b0
) (
    input clk_i,
    input rst_ni,
    input d_i,
    output logic q_o
);
  xpm_cdc_single #(
      .DEST_SYNC_FF  (STAGES),
      .INIT_SYNC_FF  (INIT),
      .SIM_ASSERT_CHK(0),
      .SRC_INPUT_REG (0)
  ) xpm_cdc_single_inst (
      .src_clk (),
      .src_in  (d_i),
      .dest_clk(clk_i),
      .dest_out(q_o)
  );
endmodule
