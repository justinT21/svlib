import axi_pkg::*;

module axis_protocol_checker #(
    parameter type req_t = axis_req_default_t,
    parameter type rsp_t = axis_rsp_t
) (
    input logic clk_i,
    input logic rst_ni,
    input req_t req,
    input rsp_t rsp
);
  `include "formal_macros.svh"
  // Check valid handshake
  `ASSERT(ValidStable_A, (req.tvalid && !rsp.tready) |=> req.tvalid, clk_i, !rst_ni)

  // Check payload stability
  `ASSERT_STABLE_IF(DataStable_A, req.tdata, (req.tvalid && !rsp.tready), clk_i, !rst_ni)
  `ASSERT_STABLE_IF(KeepStable_A, req.tkeep, (req.tvalid && !rsp.tready), clk_i, !rst_ni)
  `ASSERT_STABLE_IF(LastStable_A, req.tlast, (req.tvalid && !rsp.tready), clk_i, !rst_ni)

  // Ensure values are all known
  `ASSERT_KNOWN_IF(ValidKnown_A, req.tvalid, 1'b1, clk_i, !rst_ni)
  `ASSERT_KNOWN_IF(ReadyKnown_A, rsp.tready, 1'b1, clk_i, !rst_ni)
  `ASSERT_KNOWN_IF(DataKnown_A, req.tdata, req.tvalid, clk_i, !rst_ni)

  // Assume data never stalls infinitely
  `ASSUME(SlaveEventuallyReady_M, req.tvalid |-> s_eventually (rsp.tready), clk_i, !rst_ni)
endmodule
