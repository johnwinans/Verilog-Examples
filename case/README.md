# case, casez, and casex


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
