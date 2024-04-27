# A Simple Finite State Machine

This is a serial bit-stream recognizer with synchronous reset.

This Moore FSM is based on a course lecture and handout available on line here:

https://faculty.cs.niu.edu/~winans/CS463/2022-fa/#fsm


This example adds a second test that matches the Mealy glitchy waveform
in the course handout.  It demonstrates that a Moore machine's output
will not glitch like a Mealy one can... even with the same input waveforms!
