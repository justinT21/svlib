`ifndef AXI_MACROS_SVH
`define AXI_MACROS_SVH

`define AXIS_REQ_BASIC_T(__name, __data_width) \
  typedef struct packed { \
    logic [__data_width-1:0]     tdata; \
    logic [(__data_width/8)-1:0] tkeep; \
    logic                        tlast; \
    logic                        tvalid; \
  } __name;
`endif
