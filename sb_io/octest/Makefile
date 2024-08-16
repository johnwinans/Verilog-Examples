TOP=../..

-include  $(TOP)/Make.local
include $(TOP)/Make.rules

.PHONY: all clean burn world timings

FILES= \
	top.v

# FPGA oscillator speed 
OSC_CLK=25

all:: top.bin

top.json: $(FILES)
	$(COMPILE.v) -p "synth_ice40 -top top -json $@" $^

timing: top.asc
	icetime -tmd $(DEVICE) $^

prog: top.bin
	$(FLASH_PROG) $^

# extra dependancies
top.asc: $(PINMAP)
