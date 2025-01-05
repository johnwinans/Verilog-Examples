
2025-01-05 jrw

Note: if you use the software from Lattice, constraints related to 
things like which pins can be used to directly-drive a PLL or that 
become reserved as a result of choices like what PLL modes have been
selected are more obvious as selections in various config menus 
become enabled/disabled as clues for guidance.

The pin numbers mentioned here are in reference to the TQFP package.


The following copied from: https://github.com/YosysHQ/icestorm/issues/273

If you want to use `ice40_PLL_PAD`, `ice40_PLL_2F_PAD` or `ice40_PLL_2_PAD` you 
have to route external clock only to:

* `IOB_81_GBIN5` - pin 49
* `IOT_198_GBIN0` - pin 129

I didn't find that information in any vendor PDF's or pinout files, just 
figured out it experimentally.

If you want to use `ice40_PLL_CORE` or `ice40_PLL_2F_CORE` you won't be able to 
use PLL dedicated pins as inputs.

Some additional information from iCE40 sysCLOCK PLL Design and Usage Guide 
(FPGA-TN-02052-1.2):

5.1.2. iCEcube2 Software

* If any instance of PLL is placed in the location of the I/O cell, 
		then, an instance of `SB_GB_IO` cannot be placed in that particular 
		I/O cell.

* If an instance of `ice40_PLL_CORE` or `ice40_PLL_2F_CORE` is placed, an 
		instance of `SB_IO` in output-only mode can be placed in the 
		associated I/O cell location.

* If an instance of `ice40_PLL_PAD`, `ice40_PLL_2F_PAD`, `ice40_PLL_2_PAD` 
		is placed, the associated I/O cell cannot be used by any `SB_IO` 
		or `SB_GB_IO`.

* If an instance of `ice40_PLL_2F_CORE`, `ice40_PLL_2F_PAD`, `ice40_PLL_2_PAD` 
		is placed, an instance of `SB_IO` in output-only mode can be placed 
		in the right neighboring I/O cell.


