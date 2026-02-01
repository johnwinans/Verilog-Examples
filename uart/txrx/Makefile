TOP=../..

-include  $(TOP)/Make.local
include $(TOP)/Make.rules

.PHONY: all clean burn world timings

FILES= \
	top.v \
	uart_tx.v

# FPGA oscillator speed 
OSC_CLK=25

all:: top.bin

top.json: $(FILES)
	$(COMPILE.v) $(FLAGS.v) -p "synth_ice40 -top top -json $@" $^

timing: top.asc
	icetime -tmd $(DEVICE) $^

top_tb.vvp: top_tb.v $(FILES)
	iverilog -o $@ $^

top: top_tb.vcd
	gtkwave $^


uart_tx_tb.vvp: uart_tx_tb.v uart_tx.v
	iverilog -o $@ $^

uart_tx: uart_tx_tb.vcd
	gtkwave $^

uart_rx_tb.vvp: uart_rx_tb.v uart_rx.v
	iverilog -o $@ $^
uart_rx: uart_rx_tb.vcd
	gtkwave $^


prog: top.bin
	$(FLASH_PROG) $^

# extra dependancies
top.asc: $(PINMAP)
