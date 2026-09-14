module fixed_priority_arbiter #(
    parameter integer N = 8
) (
    input  logic [N-1:0] req_i,
    output logic [N-1:0] gnt_o
);
  `include "formal_macros.svh"
  `ASSERT_INIT(CheckNGreaterZero_A, N > 0)

  // isolates lowest set bit
  assign gnt_o = req_i & (-req_i);

  // Assertions
  `ASSERT_KNOWN(GrantKnown_A, gnt_o)
  `ASSERT(HotOne_A, $onehot0(gnt_o))

  generate
    for (genvar i = 0; i < N; i++) begin : gen_priority_checks
      `ASSERT(GrantNeedsReq_A, gnt_o[i] |-> req_i[i])

      if (i > 0) begin : gen_check_priority
        `ASSERT(StrictPriority_A, gnt_o[i] |-> (req_i[i-1:0] == '0))
      end

    end
  endgenerate
endmodule
