module cdc_freq_counter #(
    parameter int WINDOW_CYCLES = 8,
    parameter int COUNTER_WIDTH = 8
) (
    input ref_clk_i,
    input ref_rst_ni,
    input target_clk_i,
    output logic [COUNTER_WIDTH-1:0] slowness_factor
);
  // Ref Counter
  //
  // Ref to Target CDC
  //
  // Target Counter
  //
  // Target to Ref CDC

  // Reset Synchronizer

endmodule
