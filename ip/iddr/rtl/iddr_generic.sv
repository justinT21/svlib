module iddr #(
    parameter int WIDTH = 8
) (
    input clk_i,
    input rst_ni,
    input [WIDTH-1:0] d_i,
    output logic [WIDTH-1:0] q1_o,
    output logic [WIDTH-1:0] q2_o
);

  logic [WIDTH-1:0] q1, q2;

  always_ff @(posedge clk_i or negedge rst_ni) begin : d_output
    if (!rst_ni) begin
      q1_o <= '0;
      q2_o <= '0;
    end else begin
      q1_o <= q1;
      q2_o <= q2;
    end
  end

  always_ff @(posedge clk_i) begin : pos_edge_block
    if (!rst_ni) q1 <= '0;
    else q1 <= d_i;
  end

  always_ff @(negedge clk_i) begin : neg_edge_block
    if (!rst_ni) q2 <= '0;
    else q2 <= d_i;
  end
endmodule
