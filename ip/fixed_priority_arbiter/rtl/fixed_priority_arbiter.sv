module fixed_priority_arbiter #(
    parameter integer N = 8
) (
    input  logic [N-1:0] req_i,
    output logic [N-1:0] gnt_o
);
  // isolates lowest set bit
  assign gnt_o = req_i & (-req_i);

endmodule
