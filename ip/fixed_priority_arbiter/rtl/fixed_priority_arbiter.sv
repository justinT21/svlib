module fixed_priority_arbiter #(
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

  // isolates lowest set bit
  assign gnt_o   = ready_i ? req_i & (-req_i) : '0;
  assign valid_o = |req_i;

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

  generate
    for (genvar i = 0; i < N; i++) begin : gen_priority_checks
      `ASSERT(GrantNeedsReq_A, gnt_o[i] |-> req_i[i])

      if (i > 0) begin : gen_check_priority
        `ASSERT(StrictPriority_A, gnt_o[i] |-> (req_i[i-1:0] == '0))
      end
    end
  endgenerate
endmodule
