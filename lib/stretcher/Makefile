TOP=../..

-include  $(TOP)/Make.local
include $(TOP)/Make.rules

.PHONY: all clean world

FILES= \
	sync_stretch.v

all:: 

sync_stretch_tb.vvp: sync_stretch_tb.v sync_stretch.v
	iverilog -o $@ $^

plot: sync_stretch_tb.vcd
	gtkwave $^
