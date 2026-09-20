module cdc_async_rst #(
    parameter int STAGES = 2
) (
    input clk_i,
    input rst_ni,
    output logic rst_no
);
  `include "formal_macros.svh"
  `ASSERT_INIT(CheckStagesGreaterTwo_A, STAGES >= 2)

  logic [STAGES-1:0] rst_pipe;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rst_pipe <= '0;
    end else begin
      rst_pipe <= {rst_pipe[STAGES-2:0], 1'b1};
    end
  end

  assign rst_no = rst_pipe[STAGES-1];
endmodule
