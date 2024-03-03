TOP=../..

-include  $(TOP)/Make.local
include $(TOP)/Make.rules

.PHONY: all clean burn world timings

FILES= \
	top.v \
	counter.v

all:: top.bin


#top.blif: $(FILES)
#	$(COMPILE.v) -p "synth_ice40 -top top -blif $@" $^

top.json: $(FILES)
	$(COMPILE.v) -p "synth_ice40 -top top -json $@" $^

timing: top.asc
	icetime -tmd $(DEVICE) $^


counter_tb.vvp: counter_tb.v counter.v
	iverilog -o $@ $^

plot: counter_tb.vcd
	gtkwave $^

prog: top.bin
	$(FLASH_PROG) $^

# extra dependancies
top.asc: $(PINMAP)

