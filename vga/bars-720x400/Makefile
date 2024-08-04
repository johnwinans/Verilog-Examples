TOP=../..

-include  $(TOP)/Make.local
include $(TOP)/Make.rules

.PHONY: all clean burn world timings

FILES= \
	top.v \
	pll.v \
	vgasync.v

# FPGA oscillator speed 
OSC_CLK=25

all:: top.bin

top.json: $(FILES)
	$(COMPILE.v) -p "synth_ice40 -top top -json $@" $^

timing: top.asc
	icetime -tmd $(DEVICE) $^

vgasync_tb.vvp: vgasync_tb.v vgasync.v
	iverilog -o $@ $^

plot: vgasync_tb.vcd
	gtkwave $^

prog: top.bin
	$(FLASH_PROG) $^

pll.v:
	icepll -i 25 -o 35.5 -m -f $@

# extra dependancies
top.asc: $(PINMAP)

clean::
	rm -f pll.v
