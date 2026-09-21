module cdc_bit_sync #(
    parameter int unsigned STAGES = 2,
    parameter logic INIT   = 1'b0
) (
    input clk_i,
    input rst_ni,
    input d_i,
    output logic q_o
);
  `include "formal_macros.svh"
  `ASSERT_INIT(CheckStagesGreaterTwo_A, STAGES >= 2)

  logic [STAGES-1:0] sync_pipe;

  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin

      sync_pipe <= {STAGES{INIT}};
    end else begin

      sync_pipe <= {sync_pipe[STAGES-2:0], d_i};
    end
  end

  assign q_o = sync_pipe[STAGES-1];
endmodule
