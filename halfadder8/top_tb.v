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


// This can not be used any 'ol place in verilog. But is good enough for initial and always blocks.
// NOTE: SystemVerilog provides an assert() so we need not provide our own.
//
// The \ at the end of a line means continuation, just like C/C++  Therefore this macro turns into
// four lines of text that is then compiled.

`define ASSERT(cond) \
        if (!(cond)) begin \
            $display("%s:%0d time:%0t ASSERTION FAILED in %m: cond", `__FILE__, `__LINE__, $time); \
            $finish; \
        end


    initial begin
        $monitor("time:%0t a=%b, b=%b, sum=%b, cy=%b", $time, a, b, sum, cy);

        a = 0;
        b = 0;
        #0.5 `ASSERT( sum==0 && cy==0 );
        #0.5;

        a = 0;
        b = 1;
        #0.5 `ASSERT( sum==1 && cy==0 ); #0;
        #0.5;

        a = 1;                              
        b = 0;
        #0.5 `ASSERT( sum==1 && cy==0 ); #0;
        #0.5;

        a = 1;
        b = 1;
        #0.5`ASSERT( sum==0 && cy==1 ); #0;
        #0.5;

        a = 0;
        b = 0;
        #0.5 `ASSERT( sum==0 && cy==0 ); #0;
        #0.5;
        
        $finish;
    end

endmodule
