TOP=../..

-include  $(TOP)/Make.local
include $(TOP)/Make.rules

.PHONY: all clean burn world timings

FILES= \
	top.v

all:: top.bin


#top.blif: $(FILES)
#	$(COMPILE.v) -p "synth_ice40 -top top -blif $@" $^

top.json: $(FILES)
	$(COMPILE.v) -p "synth_ice40 -top top -json $@" $^


timing: top.asc
	icetime -tmd $(DEVICE) $^


top_tb.vvp: top_tb.v top.v
	iverilog -o $@ $^

plot: top_tb.vcd
	gtkwave $^

prog: top.bin
	$(FLASH_PROG) $^


# extra dependancies
top.asc: $(PINMAP)

