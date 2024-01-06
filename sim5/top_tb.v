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


// Since this test bench is simple and all checks use the same values,
// we can use a macro to print and check everything to reduce visual clutter.
// Note the #0  

`define ASSERT(cond) \
        #0 $display("%s:%0d %m time:%5t a=%b, b=%b, sum=%b, cy=%b   %0s", `__FILE__, `__LINE__, $time, a, b, sum, cy, (cond) ? "passed" : "ASSERTION (cond) FAILED!" );


    initial begin
        a = 0;
        b = 0;

        `ASSERT( sum==0 && cy==0 );
        #1;

        a = 0;
        b = 1;

        `ASSERT( sum==1 && cy==0 );
        #1;

        a = 1;
        b = 0;

        `ASSERT( sum==1 && cy==0 );
        #1;

        a = 1;
        b = 1;

        `ASSERT( sum==0 && cy==1 );
        #1;

        a = 0;
        b = 0;
        `ASSERT( sum==0 && cy==0 );
        #2;
        
        $finish;    // The $finish 'system task' halts the simulation
    end

endmodule
