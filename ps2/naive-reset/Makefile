TOP=../..

-include  $(TOP)/Make.local
include $(TOP)/Make.rules

.PHONY: all clean burn world timings

FILES= \
	$(LIB_DIR)/sync/sync.v \
	$(LIB_DIR)/debounce/debounce.v \
	ps2.v

# FPGA oscillator speed 
OSC_CLK=25

all:: top.bin

# special case for top.v only used here
top.json: $(FILES) top.v
	$(COMPILE.v) -p "synth_ice40 -top top -json $@" $^

timing: top.asc
	icetime -tmd $(DEVICE) $^

# special case for ps2_tb.v only used here
ps2_tb.vvp: $(FILES) ps2_tb.v
	iverilog -o $@ $^

plot: ps2_tb.vcd
	gtkwave $^

prog: top.bin
	$(FLASH_PROG) $^

# extra dependancies
top.asc: $(PINMAP)
