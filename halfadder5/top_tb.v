`timescale 1ns/1ps

module tb();

    reg a;
    reg b;
    wire sum;
    wire cy;

    top uut (
        .a(a),
        .b(b),
        .sum(sum),
        .cy(cy)
        );

    initial begin
        $dumpfile("top_tb.vcd");    // where to write the dump
        $dumpvars;                  // dump EVERYTHING
    end

    initial begin

// This can not be used any 'ol place in verilog. But is good enough for initial and always blocks.
// NOTE: SystemVerilog provides an assert() so we need not provide our own.

`define ASSERT(cond) \
        if (!(cond)) begin \
            $display("time:%0t ASSERTION FAILED in %m: cond", $time); \
            $finish; \
        end

        // use monitor to automatically show things when ever they change
        //$monitor("time:%0t sum = %0d", $time, sum);   // only one monitor is allowed!
        //$monitor("time:%0t cy = %0d", $time, cy);
        // ... so do this:
        $monitor("time:%0t a=%b, b=%b, sum=%b, cy=%b", $time, a, b, sum, cy);   // only one monitor is allowed!
    
        a = 0;
        b = 0;
        #0 `ASSERT( sum==0 && cy==0 );      // #0 will defer the assertion until everything else finishes
                                            // WARNING: "everyting else" could also use #0 causing a race
                                            // This behaviour is more reliable with SystemVerilog
        #1;

        a = 0;
        b = 1;
        #1;

        `ASSERT( sum==1 && cy==0 ); #0;     // this is safer since our assert does not defer anything!
        // without the above #0, the following will overlap with the assert condition evaluation!

        a = 1;                              
        b = 0;
        #1;
        `ASSERT( sum==1 && cy==0 ); #0;

        a = 1;
        b = 1;
        #1;
        `ASSERT( sum==0 && cy==1 ); #0;

        a = 0;
        b = 0;
        #1;
        `ASSERT( sum==0 && cy==0 ); #0;
        
        $finish;
    end

endmodule
