module round_robin_arbiter #(
    parameter integer N = 8
) (
    input clk_i,
    input rst_ni,
    input [N-1:0] req_i,
    output logic [N-1:0] gnt_o
);
  logic [N-1:0] grant_masked, grant_unmasked, masked_req, mask, next_grant;

  assign masked_req = req_i & mask;

  fixed_priority_arbiter #(
      .N(N)
  ) masked_arb (
      .req_i(masked_req),
      .gnt_o(grant_masked)
  );

  fixed_priority_arbiter #(
      .N(N)
  ) unmasked_arb (
      .req_i(req_i),
      .gnt_o(grant_unmasked)
  );

  assign next_grant = (masked_req != '0) ? grant_masked : grant_unmasked;

  always_ff @(posedge clk_i or negedge rst_ni) begin : mask_update
    if (!rst_ni) begin
      gnt_o <= '0;
      mask  <= '1;
    end else begin
      gnt_o <= next_grant;

      if (req_i != '0) begin
        // creates a mask of 1s above next_grant
        mask <= ~((next_grant - 1'b1) | next_grant);
      end
    end
  end

endmodule
