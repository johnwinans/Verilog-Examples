An always block implementing a decoder with unknown input values.

In simulation, == is a literal comparison.

Recall that Verilog was designed for sim and later adapted to FPGAs!
Take care of x and z sim situations by propagating an appropriate value.

Since z/x can never happen in an actual circuit, the code that handles it
will be optimized away.  But in sim, propagating a useful (unknown) value
can help catch design flaws!
