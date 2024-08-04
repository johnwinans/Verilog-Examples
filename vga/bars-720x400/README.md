# ICE40 VGA 720x400 color bars example Files

This resolution was designed for using 9x16 tiles for text characters. 

Note that the vertical sync pulse polarity for this mode is positive.

This example uses a PLL to generate the 35.5MHZ clock required for
VESA Signal 720 x 400 @ 85 Hz timing
using the parameters found
at [tinyvga.com](http://tinyvga.com/vga-timing/720x400@85Hz)

The Makefile includes a recipie to generate a module with the 
settings we need by using the `icepll` command.

Note: When using the 25MHZ reference clock found on
the [2057-ICE40HX4K-TQ144-breakout](https://github.com/johnwinans/2057-ICE40HX4K-TQ144-breakout)
project board, the PLL can not generate the exact frequency we want.
But it can generate one close enough to work on modern video monitors.

My Samsung SyncMaster 910v video monitor does not like this mode.
It flashes a box on the screen suggesting the use of 1280x1024 @60Hz
for optimal clarity.
