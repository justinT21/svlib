module ss_iddr #(
    parameter int unsigned WIDTH = 8
) (
    input ext_clk_i,
    input rst_ni,
    input [WIDTH-1:0] d_i,
    output logic clk_o,
    output logic [WIDTH-1:0] q1_o,
    output logic [WIDTH-1:0] q2_o
);
  logic ibuf_clk, bufio_clk;

  IBUF #(
      .IBUF_LOW_PWR("FALSE"),
      .IOSTANDARD  ("DEFAULT")
  ) IBUF_inst (
      .O(ibuf_clk),
      .I(ext_clk_i)
  );

  BUFIO BUFIO_inst (
      .O(bufio_clk),
      .I(ibuf_clk)
  );
  BUFR #(
      .BUFR_DIVIDE("BYPASS"),
      .SIM_DEVICE ("7SERIES")
  ) BUFR_inst (
      .O  (clk_o),
      .CE (1'b1),
      .CLR(1'b0),
      .I  (ibuf_clk)
  );

  iddr #(
      .WIDTH(WIDTH)
  ) iddr_inst (
      .clk_i(bufio_clk),
      .rst_ni(rst_ni),
      .d_i(d_i),
      .q1_o(q1_o),
      .q2_o(q2_o)
  );
endmodule
