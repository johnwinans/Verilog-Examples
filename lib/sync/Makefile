TOP=../..

-include  $(TOP)/Make.local
include $(TOP)/Make.rules

.PHONY: all clean world

FILES= \
	sync.v

all:: 

sync_tb.vvp: sync_tb.v sync.v
	iverilog -o $@ $^

plot: sync_tb.vcd
	gtkwave $^
