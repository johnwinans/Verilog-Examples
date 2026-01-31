# Nonblocking Example Synthesized

This example adds a few new concepts:

- Macros defined on the compiler command line (see `FLAGS.v` in `$(TOP)/Make.*.rules`)
- Conditional compilation based on `TB_*` macros
- Initializing reg variables in synthesized code using an `initial` block

In this example, the time base is defined using a board-specific macro named `CLK_HZ`.

The number of bits in the `timer.v` counter is calculated by the compiler based 
on the number of bits required to represent the largest possible binary value that the 
counter is expected to contain using the expression: ``reg [$clog2(`CLK_HZ/2):0] counter;``

*NOTE:* When running this example, I connected a 10-LED bargraph
(Lite-On LTA-1000G, Digikey: 160-1067-ND) to upduino pins 11-20.  The LEDs in this device drop the voltage by 2V.
Each LED is in series with a 330 ohm current-limiting resistor
(Bourns 4611X-101-331LF, Digikey: 4611X-101-331LF-ND) bringing the per-pin max current to 3.3ma.
