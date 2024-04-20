# A 7-segment LED HEX decoder.


## case (exact match)
```
time:17 en=1 D=1x11 segs=xxxxxxx		// no match. (default)
time:18 en=0 D=1x11 segs=zzzzzzz		// disabled
time:19 en=0 D=1011 segs=zzzzzzz		// disabled
time:20 en=1 D=zzzz segs=z0z0z0z		// exact match
time:21 en=0 D=zzzz segs=zzzzzzz		// disabled
time:22 en=1 D=xxxx segs=x0x0x0x		// exact match
time:23 en=0 D=xxxx segs=zzzzzzz		// disabled
time:24 en=1 D=10z0 segs=xxxxxxx		// no match (default)
time:25 en=1 D=10x0 segs=xxxxxxx		// no match (default)
time:26 en=1 D=1zx1 segs=xxxxxxx		// no match (default)
```

## casez (where 'z is a wildcard)
```
time:17 en=1 D=1x11 segs=z0z0z0z		// matches with 4'bzzzz
time:18 en=0 D=1x11 segs=zzzzzzz		// disabled
time:19 en=0 D=1011 segs=zzzzzzz		// disabled
time:20 en=1 D=zzzz segs=1111110		// matches with 4'b0000 (the first wildcard match)
time:21 en=0 D=zzzz segs=zzzzzzz		// disabled
time:22 en=1 D=xxxx segs=x0x0x0x		// exact match
time:23 en=0 D=xxxx segs=zzzzzzz		// disabled
time:24 en=1 D=10z0 segs=1111111		// matches with 4'b1000 (the first wildcard match)
time:25 en=1 D=10x0 segs=z0z0z0z		// matched with 4'bzzzz
time:26 en=1 D=1zx1 segs=z0z0z0z		// matches with 4'bzzzz
```

## casex (where 'z and 'x are wildcards)
```
time:17 en=1 D=1x11 segs=0011111		// matches with 4'b1011 (the first wildcard match)
time:18 en=0 D=1x11 segs=zzzzzzz		// disabled
time:19 en=0 D=1011 segs=zzzzzzz		// disabled
time:20 en=1 D=zzzz segs=1111110		// matches with 4'b0000 (the first wildcard match)
time:21 en=0 D=zzzz segs=zzzzzzz		// disabled
time:22 en=1 D=xxxx segs=1111110		// matches with 4'b0000 (the first wildcard match)
time:23 en=0 D=xxxx segs=zzzzzzz		// disabled
time:24 en=1 D=10z0 segs=1111111		// matches with 4'b1000 (the first wildcard match)
time:25 en=1 D=10x0 segs=1111111		// matches with 4'b1000 (the first wildcard match)
time:26 en=1 D=1zx1 segs=1111011		// matches with 4'b1001 (the first wildcard match)
```

# Observations:

- The wildcard matches in these examples just happen to match against 
0 values in the case items.  This is only because the order of the items
in the source code are in ascending order.  If we rearrange the order of
the items, we can get different results from `casex` and `casez`!

- Because a synthesized circuit can never have a signal with an unknown
value, the `casex` is avoided for such designs... because it offers no 
more than can be gained by `casez`.

- Since simulation *can* propagate b'x values through circuits when one
appears in its input(s), it can be useful to match them precisely in a
test bench.  Avoiding the use of `casex` can make this easier.


# A summary of the differences can be found on stackoverflow:

https://stackoverflow.com/questions/34370901/casex-vs-casez-in-verilog

The key difference is when the case expression instr contains `x` or `z` values. 
Remember that both casex and casez look at both the case item and the case 
expression for `x` and `z` values. We call this a symmetric comparison as don't 
care values can show up in either place.

So if instr was all x's, none of the items in the casez would match, but ALL 
of the items in the casex would match, and a simulator would pick the first item. 
Similarly, if instr were all z's, then ALL items would match. I consider 
`casex` a useless construct.

SystemVerilog replaces both statements with a `case() inside` statement. 
It uses an asymmetric comparison operator `==?` that only treats an `x` or 
`z` in the case item as a don't care.

