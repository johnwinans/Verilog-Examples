TOP=../..

-include  $(TOP)/Make.local
include $(TOP)/Make.rules

.PHONY: all clean burn world timings

FILES= \
	top.v \
	timer.v \
	toggler.v

all:: top.bin

top.json: $(FILES)
	$(COMPILE.v) $(FLAGS.v) -p "synth_ice40 -top top -json $@" $^

timing: top.asc
	icetime -tmd $(DEVICE) $^

timer_tb.vvp: timer_tb.v timer.v
	iverilog $(FLAGS.v) -o $@ $^

timer: timer_tb.vcd
	gtkwave $^

toggler_tb.vvp: toggler_tb.v toggler.v
	iverilog $(FLAGS.v) -o $@ $^

toggler: toggler_tb.vcd
	gtkwave $^

top_tb.vvp: top_tb.v timer.v toggler.v top.v
	iverilog $(FLAGS.v) -o $@ $^

plot: top_tb.vcd
	gtkwave $^

prog: top.bin
	$(FLASH_PROG) $^

# extra dependancies
top.asc: $(PINMAP)

