# ICE40 VGA 1024x768 color bars example Files

This example uses a PLL to generate the 65MHZ clock required for
XGA Signal 1024 x 768 @ 60 Hz timing using the parameters found
at [tinyvga.com](http://tinyvga.com/vga-timing/1024x768@60Hz)

1024 x 768 @ 60 Hz timing

General timing
Screen refresh rate	60 Hz
Vertical refresh	48.363095238095 kHz
Pixel freq.			65.0 MHz

Horizontal timing (line)
Polarity of horizontal sync pulse is negative.

Scanline part	Pixels	Time [µs]
Visible area	1024	15.753846153846
Front porch		24		0.36923076923077
Sync pulse		136		2.0923076923077
Back porch		160		2.4615384615385
Whole line		1344	20.676923076923

Vertical timing (frame)
Polarity of vertical sync pulse is negative.

Frame part		Lines	Time [ms]
Visible area	768		15.879876923077
Front porch		3		0.062030769230769
Sync pulse		6		0.12406153846154
Back porch		29		0.59963076923077
Whole frame		806		16.6656



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
