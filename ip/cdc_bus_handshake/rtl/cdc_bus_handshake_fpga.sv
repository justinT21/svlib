module cdc_bus_handshake #(
    parameter int unsigned STAGES = 2,
    parameter int unsigned WIDTH = 8,
    parameter int unsigned DEST_EXT_HSK = 1
) (
    input src_clk_i,
    input src_rst_ni,
    input src_send_i,
    input [WIDTH-1:0] src_data_i,
    input dest_clk_i,
    input dest_rst_ni,
    input dest_ack_i,
    output logic src_rcv_o,
    output logic dest_ready_o,
    output logic [WIDTH-1:0] dest_data_o
);
  xpm_cdc_handshake #(
      .DEST_EXT_HSK(DEST_EXT_HSK),
      .DEST_SYNC_FF(STAGES),
      .INIT_SYNC_FF(0),
      .SIM_ASSERT_CHK(0),
      .SRC_SYNC_FF(STAGES),
      .WIDTH(WIDTH)
  ) xpm_cdc_handshake_inst (
      .src_clk (src_clk_i),
      .src_in  (src_data_i),
      .src_send(src_send_i),
      .src_rcv (src_rcv_o),
      .dest_clk(dest_clk_i),
      .dest_out(dest_data_o),
      .dest_req(dest_ready_o),
      .dest_ack(dest_ack_i)
  );
endmodule
