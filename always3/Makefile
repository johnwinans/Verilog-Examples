# A Makefile suitable for simulation only

TOP=..

-include  $(TOP)/Make.local
include $(TOP)/Make.rules

.PHONY: all clean world run plot

all:: run

top_tb.vvp : top_tb.v 
	iverilog -o $@ $^

# Run a simulation. But don't plot it.
run: top_tb.vvp
	vvp top_tb.vvp

plot: top_tb.vcd
	gtkwave $^
