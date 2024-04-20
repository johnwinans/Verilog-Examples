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

- Since simulation will propagate b'x values through circuits when one
appears in its input(s), it can be useful to match them precisely in a
test bench.  Avoiding the use of `casex` can make this easier.
