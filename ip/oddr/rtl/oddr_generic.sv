module oddr #(
    parameter int unsigned WIDTH = 8
) (
    input clk_i,
    input rst_ni,
    input [WIDTH-1:0] d1_i,
    input [WIDTH-1:0] d2_i,
    output logic [WIDTH-1:0] q_o
);

  logic [WIDTH-1:0] d1, d2, d2_neg;

  always_ff @(posedge clk_i or negedge rst_ni) begin : save_input
    if (!rst_ni) begin
      d1 <= '0;
      d2 <= '0;
    end else begin
      d1 <= d1_i;
      d2 <= d2_i;
    end
  end

  // re-register
  always_ff @(negedge clk_i or negedge rst_ni) begin
    if (!rst_ni) d2_neg <= '0;
    else d2_neg <= d2;
  end

  assign q_o = clk_i ? d1 : d2_neg;
endmodule
