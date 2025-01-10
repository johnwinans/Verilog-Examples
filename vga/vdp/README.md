# ICE40 VGA 1280x1024 with scaled 320x192px

Parameters can be found at [tinyvga.com](http://tinyvga.com/vga-timing/1024x768@60Hz)

```
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
```

The Makefile includes a recipie to generate a module with the 
settings we need by using the `icepll` command.

Note: When using the 25MHZ reference clock found on
the [2057-ICE40HX4K-TQ144-breakout](https://github.com/johnwinans/2057-ICE40HX4K-TQ144-breakout)
project board, the PLL can not generate the exact frequency we want.
But it can generate one close enough to work on modern video monitors.


# Timing for mapping a TI 9118 VDP onto 1024x768 VGA:

* VDP pixel counts:

- Horizontal:

- 32 tiles @ 8px each = 256px * 4 = 1024
- clog2(1024) = 10

- Vertical:
- 24 tiles @ 8px each = 192px * 4 = 768
- clog2(768) = 10


* Plan:

- 11 bit horizontal counter:

- V CCCCC ccc mm

- V       = 1-bit visible when zero
- CCCCC	= 5-bit tile/pattern position column number
- ccc     = 3-bit tile/pattern pixel column counter
- mm      = 2-bit magnifier (to make each VDP px into 4 VGA px)

- front porch VCCCCCcccmm >= 1024 & VCCCCCcccmm < 1024+24
- sync        VCCCCCcccmm >= 1024+24 & VCCCCCcccmm < 1024+24+136
- back porch  VCCCCCcccmm >= 1024+24+136 & VCCCCCcccmm < 1024+24+136+160


- 10 bit vertical counter:

- RRRRR rrr mm

- RRRRR   = 5-bit tile/pattern position row number
- rrr     = 3-bit tile/pattern pixel row counter
- nn      = 2-bit magnifier (to make each VDP px into 4 VGA px)

- front porch CCCCCcccmm >= 768 & CCCCCcccmm < 768+3
- sync        CCCCCcccmm >= 768+3 & CCCCCcccmm < 768+3+6
- back porch  CCCCCcccmm >= 768+3+6 & CCCCCcccmm < 768+3+6+29

- visible when RRRRR < 24 && V == 0

