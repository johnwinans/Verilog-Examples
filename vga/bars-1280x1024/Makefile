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
OSC_TARGET=108

# Override the default nextpnr rule in the Make.rules file to test using the
# --freq option (that I should migrate into the default rules file... I know.)
%.asc : %.json
	$(NEXTPNR) --freq $(OSC_TARGET) --$(DEVICE) --package $(PACKAGE) --pcf $(PINMAP) --asc $@ --json $<



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
	icepll -i $(OSC_CLK) -o $(OSC_TARGET) -m -f $@

# extra dependancies
top.asc: $(PINMAP)

clean::
	rm -f pll.v
