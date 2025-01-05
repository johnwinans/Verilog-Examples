# ICE40 PLL Example Files

This directory contains files to demonstrate the use of the PLL

To generate a PLL module for a PAD input:

```
icepll -i 25 -p -o 50 -m -n pll_25_50
```

To generate a PLL module for a CORE input (leave off the -p):
```
icepll -i 25 -o 50 -m -n pll_25_50
```

Note that this example includes both types of PLL and a commented-out
line in the PCF file to demonstrate what happens when you try to 
instantiate a PAD PLL on an invalid pin.
