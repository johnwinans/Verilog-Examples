`timescale 10ns/1ns

`default_nettype none

module tb();

    reg a;
    reg b;

    wire sum;
    wire cy;

    assign sum = a ^ b;
    assign  cy = a & b;


    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars;
    end


// We can run silently when the assertions are passing
// and then halt the simulation immediately upon a failure.

`define ASSERT(cond) \
        if ( ~(cond) ) begin \
            $display("%s:%0d %m time:%5t ASSERTION FAILED: cond", `__FILE__, `__LINE__, $time ); \
            $finish; \
        end

    initial begin
        // We can add a monitor if we want to watch changes too
        //$monitor("time:%5t ", $time, a, b, sum, cy );   // this will print the values smashed together
        $monitor("time:%5t a=%b b=%b sum=%b cy=%b", $time, a, b, sum, cy );

        a = 0;
        b = 0;

        #1;
        `ASSERT( sum==0 && cy==0 );

        a = 0;
        b = 1;

        #1;
        `ASSERT( sum==1 && cy==0 );

        a = 1;
        b = 0;

        #1;
        `ASSERT( sum==1 && cy==0 );

        a = 1;
        b = 1;

        #1;
        `ASSERT( sum==0 && cy==1 );

        a = 0;
        b = 0;

        #1
        `ASSERT( sum==0 && cy==0 );

        #2;
        $finish;
    end

endmodule
