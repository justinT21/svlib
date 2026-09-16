module iddr #(
    parameter int WIDTH = 8
) (
    input clk_i,
    input rst_ni,
    input [WIDTH-1:0] d_i,
    output logic [WIDTH-1:0] q1_o,
    output logic [WIDTH-1:0] q2_o
);
  for (genvar i = 0; i < WIDTH; i++) begin : g_iddr
    IDDR #(
        .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
        .INIT_Q1(1'b0),
        .INIT_Q2(1'b0),
        .SRTYPE("ASYNC")
    ) IDDR_inst (
        .Q1(q1_o[i]),
        .Q2(q2_o[i]),
        .C (clk_i),
        .CE(1'b1),
        .D (d_i[i]),
        .R (!rst_ni),
        .S (1'b0)
    );
  end
endmodule
