module iddr #(
    parameter int WIDTH = 8
) (
    input clk_i,
    input rst_ni,
    input [WIDTH-1:0] q_i,
    output logic [WIDTH-1:0] d1_o,
    output logic [WIDTH-1:0] d2_o
);

  logic [WIDTH-1:0] d1, d2;

  always_ff @(posedge clk_i or negedge rst_ni) begin : d_output
    if (!rst_ni) begin
      d1_o <= '0;
      d2_o <= '0;
    end else begin
      d1_o <= d1;
      d2_o <= d2;
    end
  end

  always_ff @(posedge clk_i) begin : pos_edge_block
    if (!rst_ni) d1 <= '0;
    else d1 <= q_i;
  end

  always_ff @(negedge clk_i) begin : neg_edge_block
    if (!rst_ni) d2 <= '0;
    else d2 <= q_i;
  end
endmodule
