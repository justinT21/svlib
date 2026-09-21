module cdc_async_rst #(
    parameter int unsigned STAGES = 2
) (
    input clk_i,
    input rst_ni,
    output logic rst_no
);
  xpm_cdc_async_rst #(
      .DEST_SYNC_FF(STAGES),
      .INIT_SYNC_FF(1),
      .RST_ACTIVE_HIGH(0)
  ) xpm_cdc_async_rst_inst (
      .src_arst (rst_ni),
      .dest_clk (clk_i),
      .dest_arst(rst_no)
  );
endmodule
