module cdc_gray_sync #(
    parameter int STAGES = 2,
    parameter int WIDTH  = 8
) (
    input src_clk_i,
    input src_rst_ni,
    input dest_clk_i,
    input dest_rst_ni,
    input [WIDTH-1:0] src_counter_i,
    output logic [WIDTH-1:0] dest_counter_o
);
  `include "formal_macros.svh"
  `ASSERT_INIT(CheckStagesGreaterTwo_A, STAGES >= 2)
  `ASSERT_INIT(CheckWidthGreaterTwo_A, WIDTH >= 2)

  logic [STAGES-1:0][WIDTH-1:0] sync_pipe;
  logic [WIDTH-1:0] gray_src, gray_dest, bin_dest;

  always_ff @(posedge src_clk_i or negedge src_rst_ni) begin
    if (!src_rst_ni) begin
      gray_src <= {'0};
    end else begin
      gray_src <= src_counter_i ^ (src_counter_i >> 1);
    end
  end

  always_ff @(posedge dest_clk_i or negedge dest_rst_ni) begin
    if (!dest_rst_ni) begin
      sync_pipe <= {'0};
    end else begin
      sync_pipe <= {sync_pipe[STAGES-2:0], gray_src};
    end
  end

  assign gray_dest = sync_pipe[STAGES-1];

  always_comb begin
    for (int i = 0; i < WIDTH; i++) begin
      bin_dest[i] = ^(gray_dest >> i);
    end
  end

  always_ff @(posedge dest_clk_i or negedge dest_rst_ni) begin
    if (!dest_rst_ni) begin
      dest_counter_o <= '0;
    end else begin
      dest_counter_o <= bin_dest;
    end
  end
endmodule
