# ICE40 VGA color bars example Files for 640x350 @ 70HZ

This directory contains files to generate color bars.

This timing can be useful to render 

By propagating the column and row counter values out of the sync generator
they can be used to generate patterns on the RGB color outputs.

See: http://www.tinyvga.com/vga-timing/640x350@70Hz

640 x 350 @ 70 Hz timing

General timing
Screen refresh rate	70 Hz
Vertical refresh	31.46875 kHz
Pixel freq.	25.175 MHz
Horizontal timing (line)
Polarity of horizontal sync pulse is positive.

Scanline part	Pixels	Time [µs]
Visible area	640	25.422045680238
Front porch	16	0.63555114200596
Sync pulse	96	3.8133068520357
Back porch	48	1.9066534260179
Whole line	800	31.777557100298
Vertical timing (frame)
Polarity of vertical sync pulse is negative.

Frame part	Lines	Time [ms]
Visible area	350	11.122144985104
Front porch	37	1.175769612711
Sync pulse	2	0.063555114200596
Back porch	60	1.9066534260179
Whole frame	449	14.268123138034

Note: We can not get an optimal clock speed of 25.175 from the
PLL when using a 25MHZ oscillator.  So this will run at 25MHZ, which
I hope is close enough to work OK.



31.5MHZ is also viable.

See: http://www.tinyvga.com/vga-timing/640x350@85Hz

640 x 350 @ 85 Hz timing

General timing
Screen refresh rate	85 Hz
Vertical refresh	37.860576923077 kHz
Pixel freq.	31.5 MHz
Horizontal timing (line)
Polarity of horizontal sync pulse is positive.

Scanline part	Pixels	Time [µs]
Visible area	640	20.31746031746
Front porch	32	1.015873015873
Sync pulse	64	2.031746031746
Back porch	96	3.047619047619
Whole line	832	26.412698412698
Vertical timing (frame)
Polarity of vertical sync pulse is negative.

Frame part	Lines	Time [ms]
Visible area	350	9.2444444444444
Front porch	32	0.84520634920635
Sync pulse	3	0.079238095238095
Back porch	60	1.5847619047619
Whole frame	445	11.753650793651
