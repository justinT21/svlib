module oddr #(
    parameter int WIDTH = 8
) (
    input clk_i,
    input rst_ni,
    input [WIDTH-1:0] d1_i,
    input [WIDTH-1:0] d2_i,
    output logic [WIDTH-1:0] q_o
);
  for (genvar i = 0; i < WIDTH; i++) begin : g_oddr
    ODDR #(
        .DDR_CLK_EDGE("SAME_EDGE"),
        .INIT(1'b0),
        .SRTYPE("ASYNC")
    ) ODDR_inst (
        .Q (q_o[i]),
        .C (clk_i),
        .CE(1'b1),
        .D1(d1_i[i]),
        .D2(d2_i[i]),
        .R (!rst_ni),
        .S (1'b0)
    );
  end
endmodule
