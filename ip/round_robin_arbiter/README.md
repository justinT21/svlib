## Steps to run Formal Analysis

The formal analysis uses jaspergold and requires a server with access to such. It may be possible to use symbiyosys but it hasn't been tested.

1. Build the module

```bash
fusesoc run --setup --target=formal justint:arbiter:round_robin:1.0.0
```

2. Run the following tcl script in jaspergold using the command below.

```bash
jg -batch <tcl_filename>.tcl
```

```tcl
elaborate -top round_robin_arbiter
clock clk_i
reset ~rst_ni
prove -all
report -results -summary
```
