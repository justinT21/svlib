module round_robin_arbiter #(
    parameter integer N = 8
) (
    input clk_i,
    input rst_ni,
    input ready_i,
    input [N-1:0] req_i,
    output logic valid_o,
    output logic [N-1:0] gnt_o
);
  `include "formal_macros.svh"
  `ASSERT_INIT(CheckNGreaterZero_A, N > 0)

  logic [N-1:0]
      grant_masked, grant_unmasked, masked_req, mask, raw_grant, locked_grant, final_raw_grant;
  logic is_locked;

  assign masked_req = req_i & mask;

  fixed_priority_arbiter #(
      .N(N)
  ) masked_arb (
      .ready_i(1'b1),
      .req_i  (masked_req),
      .valid_o(),
      .gnt_o  (grant_masked)
  );

  fixed_priority_arbiter #(
      .N(N)
  ) unmasked_arb (
      .ready_i(1'b1),
      .req_i  (req_i),
      .valid_o(),
      .gnt_o  (grant_unmasked)
  );

  assign raw_grant = (masked_req != '0) ? grant_masked : grant_unmasked;
  assign valid_o = |req_i;
  assign gnt_o = ready_i ? final_raw_grant : '0;
  assign final_raw_grant = is_locked ? locked_grant : raw_grant;

  always_ff @(posedge clk_i or negedge rst_ni) begin : mask_update
    if (!rst_ni) begin
      mask <= '1;
    end else begin
      // only update on handshake
      if (valid_o && ready_i) begin
        // creates a mask of 1s above next_grant
        mask <= ~((final_raw_grant - 1'b1) | final_raw_grant);
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin : grant_lock_logic
    if (!rst_ni) begin
      locked_grant <= '0;
      is_locked    <= 1'b0;
    end else if (valid_o && ready_i) begin
      is_locked <= 1'b0;
    end else if (valid_o && !ready_i && !is_locked) begin
      locked_grant <= raw_grant;
      is_locked    <= 1'b1;
    end
  end

  // Assertions
  `ASSERT_KNOWN(GrantKnown_A, gnt_o)
  `ASSERT_KNOWN(ValidKnown_A, valid_o)
  `ASSERT(HotOne_A, $onehot0(gnt_o))

  `ASSERT(GntImpliesReady_A, |gnt_o |-> ready_i)
  `ASSERT(GntImpliesValid_A, |gnt_o |-> valid_o)
  `ASSERT(ReqReadyImplyGrant_A, |req_i && ready_i |-> |gnt_o)
  `ASSERT(ReqImpliesValid_A, |req_i |-> valid_o)
  `ASSERT(ReadyValidImplyGrant_A, ready_i && valid_o |-> |gnt_o)
  `ASSERT(NoReadyValidNoGrant_A, !(ready_i || valid_o) |-> gnt_o == '0)
  // checks that a grant index is higher than previous if one exists
  `ASSERT(RoundRobin_A, ##1 valid_o && ready_i && $past(valid_o) && $past(ready_i)
                        && |(req_i & ~($past(gnt_o) ^ ($past(gnt_o) - 1))) |-> gnt_o > $past(gnt_o))

  `ASSUME(ReqStaysHighUntilGnt_M, |req_i && !ready_i |=> (req_i & $past(req_i)) == $past(req_i))
  `ASSERT(LockGnt_A, |req_i && !ready_i |=> final_raw_grant == $past(final_raw_grant))

`ifdef FORMAL
  // symbolic variables
  int unsigned k;
  bit ReadyStable;
  bit ReqStable;

  `ASSUME(KStable_M, ##1 $stable(k))
  `ASSUME(KInRange_M, k < N)
  // stability assumptions
  `ASSUME(ReadyVarStable_M, ##1 $stable(ReadyStable))
  `ASSUME(ReqVarStable_M, ##1 $stable(ReqStable))
  `ASSUME(ReadyStable_M, ##1 !ReadyStable || $stable(ready_i))
  `ASSUME(ReqStable_M, ##1 !ReqStable || $stable(req_i))

  `ASSUME(ReqStaysHighUntilGntFormal_M, req_i[k] && !gnt_o[k] |=> req_i[k])

  // Formal Assertions
  `ASSERT(GntImpliesRequest_A, gnt_o[k] |-> req_i[k])

  `ASSERT(NoStarvation_A,
          ReadyStable && ReqStable && ready_i && req_i[k] |-> s_eventually (gnt_o[k]))

  for (genvar i = 1; i <= N; i++) begin : gen_fairness
    integer gnt_cnt;
    `ASSERT(Fairness_A,
            ReqStable && ReadyStable && ready_i && req_i[k] && $countones(
                req_i
            ) == i |-> ##i gnt_cnt == $past(
                gnt_cnt, i
            ) + 1)

    always_ff @(posedge clk_i or negedge rst_ni) begin : gnt_cnt_loop
      if (!rst_ni) begin
        gnt_cnt <= 0;
      end else begin
        gnt_cnt <= gnt_cnt + gnt_o[k];
      end
    end
  end
`endif
endmodule
