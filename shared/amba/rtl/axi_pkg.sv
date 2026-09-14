package axi_pkg;
  `include "axi_pkg.svh"

  localparam int AW = 32;
  localparam int DW = 32;

  typedef struct packed {logic tready;} axis_rsp_t;
  `AXI_REQ_BASIC_T(axis_req_default_t, 32)
endpackage
