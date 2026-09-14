`ifndef FORMAL_MACROS_SVH
`define FORMAL_MACROS_SVH

`define ASSERT_DEFAULT_CLK clk_i
`define ASSERT_DEFAULT_RST !rst_ni

`ifdef SYNTHESIS
// Dummy Definitions

`define ASSERT(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST)
`define ASSUME(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST)
`define COVER(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST)
`define ASSERT_KNOWN(__name, __sig, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST)
`define ASSERT_KNOWN_IF(__name, __sig, __cond, __clk = `ASSERT_DEFAULT_CLK,
                        __rst = `ASSERT_DEFAULT_RST)
`define ASSERT_NEVER(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST)
`define ASSERT_STABLE_IF(__name, __sig, __cond, __clk = `ASSERT_DEFAULT_CLK,
                         __rst = `ASSERT_DEFAULT_RST)
`define ASSERT_INIT(__name, __prop)
`define ASSERT_COMB(__name, __prop)
`else
// Standard Definitions

`define ASSERT(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
  __name: assert property (@(posedge __clk) disable iff (__rst !== '0) (__prop))

`define ASSUME(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
  __name: assume property (@(posedge __clk) disable iff (__rst !== '0) (__prop))

`define COVER(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
  __name: cover property (@(posedge __clk) disable iff (__rst !== '0) (__prop))

`define ASSERT_KNOWN(__name, __sig, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
  `ASSERT(__name, !$isunknown(__sig), __clk, __rst)

`define ASSERT_KNOWN_IF(__name, __sig, __cond, __clk = `ASSERT_DEFAULT_CLK,
                        __rst = `ASSERT_DEFAULT_RST) \
  `ASSERT(__name, (__cond) |-> !$isunknown(__sig), __clk, __rst)

`define ASSERT_NEVER(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
  `ASSERT(__name, not (__prop), __clk, __rst)

`define ASSERT_STABLE_IF(__name, __sig, __cond, __clk = `ASSERT_DEFAULT_CLK,
                         __rst = `ASSERT_DEFAULT_RST) \
  `ASSERT(__name, (__cond) |=> $stable(__sig), __clk, __rst)

`define ASSERT_INIT(__name, __prop) \
  initial begin \
    __name: assert (__prop) else $fatal(1, "Assertion failed: %m"); \
  end

`define ASSERT_COMB(__name, __prop) \
  always_comb begin \
    __name: assert final (__prop) else $error("Assertion failed: %m"); \
  end

`endif
`endif  //FORMAL_MACROS_SVH
