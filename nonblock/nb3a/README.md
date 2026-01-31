# Nonblocking Example Synthesized

This example adds a few new concepts:

- Macros defined on the compiler command line (see `FLAGS.v` in `$(TOP)/Make.*.rules`)
- Conditional compilation based on `TB_*` macros
- Initializing reg variables in synthesized code using an `initial` block

In this example, the time base is defined using a board-specific macro named `CLK_HZ`.

Note that the number of bits in the `timer.v` counter is calculated by the compiler based 
on the number of bits required to represent the largest possible binary value that the 
counter is expected to contain using the expression: ``reg [$clog2(`CLK_HZ/2):0] counter;``
