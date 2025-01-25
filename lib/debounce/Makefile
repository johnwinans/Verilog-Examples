TOP=../..

-include  $(TOP)/Make.local
include $(TOP)/Make.rules

.PHONY: all clean world

FILES= \
	debounce.v \
	../sync/sync.v

all:: 

debounce_tb.vvp: debounce_tb.v $(FILES)
	iverilog -o $@ $^

plot: debounce_tb.vcd
	gtkwave $^
