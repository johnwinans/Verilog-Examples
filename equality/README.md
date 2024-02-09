
Recall that:

	0 = false/low/ground
	1 = true/high/positive-voltage
	x = an unknown value. (This can only happen in siumulation.)
	z = floating/high-impedance.  (This is synthesizable as an output value.)


The Verilog spec says:

	a === b   a is equal to b including x and z
	a !== b   a is not equal to b, including x and z
	a == b    a is equal to b, result can be unknown
	a != b    a is not equal to b, result can be unknown


Note that x is always considered false.

if ( 'bx )
	// never gets here
else
	// always gets here
