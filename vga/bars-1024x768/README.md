# ICE40 VGA 1024x768 color bars example Files

This example uses a PLL to generate the 65MHZ clock required for
XGA Signal 1024 x 768 @ 60 Hz timing using the parameters found
at [tinyvga.com](http://tinyvga.com/vga-timing/1024x768@60Hz)

The Makefile includes a recipie to generate a module with the 
settings we need by using the `icepll` command.

Note: When using the 25MHZ reference clock found on
the [2057-ICE40HX4K-TQ144-breakout](https://github.com/johnwinans/2057-ICE40HX4K-TQ144-breakout)
project board, the PLL can not generate the exact frequency we want.
But it can generate one close enough to work on modern video monitors.

Note: Because the logic in `top.v` that determines the color bits is 
combinational, the way that the Verilog choses to implement it can 
result glitches and/or hesitations when the colors transition.
(I can see a narrow vertical glitch on the left edge of my screen.)
