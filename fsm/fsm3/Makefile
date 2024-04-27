# A Makefile suitable for simulation only

TOP=../..

-include  $(TOP)/Make.local
include $(TOP)/Make.rules

.PHONY: all clean world run plot

all:: run

top_tb.vvp : top_tb.v fsm.v
	iverilog -o $@ $^

# Run a simulation. But don't plot it.
run: top_tb.vvp
	vvp top_tb.vvp

plot: top_tb.vcd
	gtkwave $^


# add a second test bench
top2_tb.vvp : top2_tb.v fsm.v
	iverilog -o $@ $^
run2: top2_tb.vvp
	vvp top2_tb.vvp
plot2: top2_tb.vcd
	gtkwave $^

