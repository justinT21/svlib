clear -all

analyze -sv afifo.sv
elaborate -top afifo -parameter DATA_WIDTH 32 -parameter BUFFER_WIDTH 10

clock wclk_i
clock rclk_i

config_rtlds -clock -group -async {{wclk_i} {rclk_i}}

config_rtlds -reset -async wrst_ni -polarity low
config_rtlds -reset -async rrst_ni -polarity low

# resets are synchronized at top level
config_rtlds -port wrst_ni -external_sync -destination_clock wclk_i
config_rtlds -port rrst_ni -external_sync -destination_clock rclk_i

config_rtlds -port {wr_i wdata_i wfull_o} -clock wclk_i
config_rtlds -port {rd_i rdata_o rempty_o} -clock rclk_i

config_rtlds -rule -parameter {fifo_detection = true}

check_cdc -extract

# dump reports
check_cdc -list pairs -file pairs.csv -force
check_cdc -list violations -file violations.csv -force
check_cdc -list domains -file domains.csv -force
