module ss_iddr #(
    parameter int WIDTH = 8
) (
    input ext_clk_i,
    input rst_ni,
    input [WIDTH-1:0] d_i,
    output logic clk_o,
    output logic [WIDTH-1:0] q1_o,
    output logic [WIDTH-1:0] q2_o
);
  assign clk_o = ext_clk_i;

  iddr #(
      .WIDTH(WIDTH)
  ) iddr_inst (
      .clk_i(ext_clk_i),
      .rst_ni(rst_ni),
      .d_i(d_i),
      .q1_o(q1_o),
      .q2_o(q2_o)
  );
endmodule
