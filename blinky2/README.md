When using the SB_IO, you can create a different module (counter) with the application 
logic in it so that a test-bench can be used while a device-specific SB_IO module 
(that can not be simulated) can be present in a top module.

This will be necessary when using the SB_IO for features that can not be specified in a .pcf file.
