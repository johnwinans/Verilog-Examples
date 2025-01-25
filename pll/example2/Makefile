TOP=../..

-include  $(TOP)/Make.local
include $(TOP)/Make.rules

.PHONY: all clean burn world timings

FILES= \
	top.v \
	counter.v\
	pll_25_65.v \
	pll_25_18432.v

# FPGA oscillator speed 
OSC_CLK=25

all:: top.bin

top.json: $(FILES)
	$(COMPILE.v) -p "synth_ice40 -top top -json $@" $^

prog: top.bin
	$(FLASH_PROG) $^

pll_25_65.v:
	icepll -i $(OSC_CLK) -o 65 -m -n pll_25_65 -f $@

pll_25_18432.v:
	icepll -i $(OSC_CLK) -o 18.432 -m -n pll_25_18432 -f $@

# extra dependancies
top.asc: $(PINMAP)

clean::
	rm -f pll_25_65.v pll_25_18432.v
