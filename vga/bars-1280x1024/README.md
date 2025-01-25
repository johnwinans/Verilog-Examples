# ICE40 VGA 1280x1024 color bars example Files

WARNING: This fails to compile into a design that can operate at
the required 108MHZ due to the propagation delay in the carry chains
of the row and column counters!

Note that the horizontal and vertical sync pulse polarities for this mode are positive.

This example uses a PLL to generate the 108MHZ clock required for
VESA Signal 1280 x 1024 @ 60 Hz timing
using the parameters found
at [tinyvga.com](http://tinyvga.com/vga-timing/1280x1024@60Hz)

The Makefile includes a recipie to generate a module with the 
settings we need by using the `icepll` command.

Note: When using the 25MHZ reference clock found on
the [2057-ICE40HX4K-TQ144-breakout](https://github.com/johnwinans/2057-ICE40HX4K-TQ144-breakout)
project board, the PLL can not generate the exact frequency we want.
But it can generate one close enough to work on modern video monitors.

Note: This example includes an overriden recipie when running `nextpnr`
in order to insert `--freq 108` for the timing assessment calculation.
