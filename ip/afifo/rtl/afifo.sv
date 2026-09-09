`timescale 1ns/1ps

module afifo #(
    parameter int DATA_WIDTH   = 32,
    parameter int BUFFER_WIDTH = 10
) (
    input wclk_i,
    input wrst_ni,
    input wr_i,
    input [DATA_WIDTH-1:0] wdata_i,
    output logic wfull_o,
    input rclk_i,
    input rrst_ni,
    input rd_i,
    output logic [DATA_WIDTH-1:0] rdata_o,
    output logic rempty_o
);
  (* ASYNC_REG = "TRUE" *) logic [BUFFER_WIDTH:0] rgray_q1, rgray_q2;
  (* ASYNC_REG = "TRUE" *) logic [BUFFER_WIDTH:0] wgray_q1, wgray_q2;
  logic [BUFFER_WIDTH:0] rgray, rbin;
  logic [BUFFER_WIDTH:0] wgray, wbin;

  wire [BUFFER_WIDTH-1:0] waddr, raddr;

  logic [DATA_WIDTH-1:0] mem[1<<BUFFER_WIDTH];

  wire [BUFFER_WIDTH:0] wbin_next, wgray_next;
  wire [BUFFER_WIDTH:0] rbin_next, rgray_next;

  logic wfull_next, rempty_next;

  // write domain
  always_ff @(posedge wclk_i or negedge wrst_ni) begin : read_gray_to_write
    if (!wrst_ni) {rgray_q2, rgray_q1} <= 0;
    else {rgray_q2, rgray_q1} <= {rgray_q1, rgray};
  end

  assign wbin_next = wbin + {{BUFFER_WIDTH{1'b0}}, wr_i && !wfull_o};
  // gray code scheme https://en.wikipedia.org/wiki/Gray_code
  assign wgray_next = (wbin_next >> 1) ^ wbin_next;

  assign waddr = wbin[BUFFER_WIDTH-1:0];

  always_ff @(posedge wclk_i or negedge wrst_ni) begin : write_clk_update
    if (!wrst_ni) {wbin, wgray} <= 0;
    else {wbin, wgray} <= {wbin_next, wgray_next};
  end

  // gray code is full when top two bits are inverted and the rest identical
  // first bit must be opposite due to being full, then gray coding that
  // makes only the top two bits inverted and the rest equal
  assign wfull_next = wgray_next ==
      {~rgray_q2[BUFFER_WIDTH:BUFFER_WIDTH-1], rgray_q2[BUFFER_WIDTH-2:0]};

  always_ff @(posedge wclk_i or negedge wrst_ni) begin : write_full_update
    if (!wrst_ni) wfull_o <= 0;
    else wfull_o <= wfull_next;
  end

  // write to memory
  always_ff @(posedge wclk_i) begin : write_mem
    if (wr_i && !wfull_o) mem[waddr] <= wdata_i;
  end

  // read domain
  always_ff @(posedge rclk_i or negedge rrst_ni) begin : write_gray_to_read
    if (!rrst_ni) {wgray_q2, wgray_q1} <= 0;
    else {wgray_q2, wgray_q1} <= {wgray_q1, wgray};
  end

  assign rbin_next  = rbin + {{BUFFER_WIDTH{1'b0}}, rd_i && !rempty_o};
  assign rgray_next = (rbin_next >> 1) ^ rbin_next;

  always_ff @(posedge rclk_i or negedge rrst_ni) begin : read_clk_update
    if (!rrst_ni) {rbin, rgray} <= 0;
    else {rbin, rgray} <= {rbin_next, rgray_next};
  end

  // empty if the gray codes and hence pointers are equivalent
  assign rempty_next = (rgray_next == wgray_q2);

  always_ff @(posedge rclk_i or negedge rrst_ni) begin : read_full_update
    if (!rrst_ni) rempty_o <= 1;
    else rempty_o <= rempty_next;
  end

  assign raddr = rbin_next[BUFFER_WIDTH-1:0];

  // read one ahead to remove bram one cycle latency
  always_ff @(posedge rclk_i) begin : read_mem
    rdata_o <= mem[raddr];
  end
endmodule
