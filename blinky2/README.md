When using the SB_IO, you can create a different module with the main 
logic in it so that the test-bench can still work.

This becomes necessary when using the SB_IO for things beyond what can be
specified in the .pcf file.
