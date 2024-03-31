This is a summary of some of the synthesizable constructs that are discussed in 
[IEEE Std 1364.1-2002 - IEEE Standard for Verilog Register Transfer Level Synthesis](https://ieeexplore.ieee.org/document/1146718)

# Synthesis of Combinational Circuits

Combinational circuits may be defined with a `continuous assignmnet` or an
`always` statement.

When using an always statement, you can not use `posedge` or `negedge` in its
sensitivity list.  It is a good idea to consider using `@(*)` and only
`blocking` assignments.

This continuous assignment defines a multiplexer.  When `sel` is true,
`a` is assigned `b`.  When `sel` is false, `a` is assigned `c`.
```
wire a;
assign a = sel ? b : c;
```

This is the same circuit defined with an always statement:
```
reg a;
always @(*) begin
    if ( sel )
        a = b;
    else
        a = c;
end
```

# Synthesis of Sequential Circuits

Recall that a sequential circuit is one that has a memory.  Verilog
models these memories as edge-sensitive `flip-flop` or level-sensitive
`latch` circuits.

Generally, you will want to use `non-blocking` assignments in sequential 
circuits.  The exception would be if you need a variable to hold a temporary
value to be assigned to an output using a non-blocking assignment in the 
same always statement.

## Edge-Sensitive

A sequential circuit can be defined with an `always` statement that has
`posedge` and/or `negedge` in its sensitivity list.


### Positive-edge Triggered Flip-Flop
```
always @( posedge clk ) begin
    a <= b;
end
```

### Positive-edge Triggered Flip-Flop With Synchronous Reset
```
always @( posedge clk ) begin
    if ( reset )        // note that reset is *not* in the sentitivity list
        a <= 0;         // the assigned reset value must be a constant
    else
        a <= b;
end
```

### Positive-edge Triggered Flip-Flop With Synchronous Set and Reset
```
always @( posedge clk ) begin
    if ( reset )        // note that reset is *not* in the sentitivity list
        a <= 0;         // the assigned reset value must be a constant
    else if ( set )     // set is *not* in the sentitivity list
        a <= 1;         // the assigned set value must be a constant
    else
        a <= b;
end
```

### Positive-edge Triggered Flip-Flop With Asynchronous Set and Reset

This one is a bit tricky to follow since it has the set and/or reset
signals in the sensitivity list that the synthesis tool *could* confuse
as a clock signal!

All the signals in the sensitivity list must be edge-sensitive.

```
always @( posedge clk, posedge reset, negedge set ) begin
    if ( reset )        // conditions must match the edge direction (pos)
        a <= 0;
    else if ( !set )    // (neg)
        a <= 1;
    else                // the final/naked else is the synchronous operation
        a <= b;
end
```

The above circuit will work *better* as synthesized than in simulation.
Consider simulation of the following signals: 
```
clk=0, reset=0, set=1 
clk=0, reset=1, set=1       // reset
clk=0, reset=1, set=0       // reset!
clk=0, reset=0, set=0       // ???
clk=1, reset=0, set=0       // set!
clk=1, reset=0, set=1
clk=0, reset=0, set=1
```

The same signals in a synthesized circuit might behave differently as the
line marked `???` will likely set the flip-flop (because a real async
circuit does not "wait" for the next edge to arrive before noticing that 
the set signal is active) while synthesis will not change the state 
(because reset changing from 1 to 0 will not cause the always block 
to execute!)



## Level-sensitive

A `level-sensitive latch` is also known as an `inferred latch`.  
Creating these by accident can be annoying bugs to find and fix.
Sometimes, however, they can be useful.

These are created by what looks like an `combinational always statement`
but has an execution path that leaves a value unassigned/unchanged.
For example:

```
always @(*) begin
    if ( enable )
        a <= b;         // a is only assigned a value when enable is 1
end
```

Note that, as long as `enable` is true, this circuit will set `a=b` 
Thus creating what is sometimes called a `transparent latch`.
Such a latch will "capture" and retain the value of `b` by storing
it in `a` at the point in time when `enable` changes from true to 
false.
