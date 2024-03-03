Another way to get a $display to run at the end of the current time period.
Add a `#0` delay before the $display system tasks.

The `#0` statement will wait for all operations already started in the 
same time period to complete before simulation will continue.  Taken 
literally, this means that *other operations* might also have initiated 
a `#0` delay in the same time period!  Therefore this does not always
mean that *everything* will finish before the $display() is performed.

However, it will work for our purposes because we have not scheduled anything
else (other that our simple test bench operations) to run.
