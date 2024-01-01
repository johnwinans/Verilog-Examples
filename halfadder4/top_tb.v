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
        // use monitor to automatically show things when ever they change
        //$monitor("time:%0t {$monitor sum} sum = %0d", $time, sum);   // only one monitor is allowed!
        //$monitor("time:%0t {$monitor cy} cy = %0d", $time, cy);
        // ... so do this:
        $monitor("time:%0t {$monitor sum, cy} sum=%b, cy=%b", $time, sum, cy);   // only one monitor is allowed!
    
        a = 0;
        b = 0;
        #1
        if ( !( sum==0 && cy==0 ) ) begin $display("time:%0t FAILED a=%b, b=%b, sum=%b, cy=%b", $time, a, b, sum, cy); $finish; end
        // not that the above if is scheduled to happen at the same time as the following updates to a and b!!!
        // therefore properly implementing such a check should include a delay before and after!
        // One might consider #0, but that is not always reliable either!

        a = 0;
        b = 1;
        #1
        if ( !( sum==1 && cy==0 ) ) begin $display("time:%0t FAILED a=%b, b=%b, sum=%b, cy=%b", $time, a, b, sum, cy); $finish; end

        a = 1;
        b = 0;
        #1
        if ( !( sum==1 && cy==0 ) ) begin $display("time:%0t FAILED a=%b, b=%b, sum=%b, cy=%b", $time, a, b, sum, cy); $finish; end

        a = 1;
        b = 1;
        #1
        if ( !( sum==0 && cy==1 ) ) begin $display("time:%0t FAILED a=%b, b=%b, sum=%b, cy=%b", $time, a, b, sum, cy); $finish; end

        a = 0;
        b = 0;
        #1
        if ( !( sum==0 && cy==0 ) ) begin $display("time:%0t FAILED a=%b, b=%b, sum=%b, cy=%b", $time, a, b, sum, cy); $finish; end
        
        $finish;
    end

endmodule
