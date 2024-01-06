`timescale 10ns/1ns

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

    initial begin
        a = 0;
        b = 0;

        // #0 will cause all the assignments in THIS process block to finish 
        // before proceeding. This does NOT mean that things OUTSIDE of this 
        // process block and that SHOULD be finished 'now' as well will have
        // completed!  Using #0 may not be as reliable as it is here!
        #0 $display("%5t: a=%b, b=%b, sum=%b, cy=%b %s", $time, a, b, sum, cy, (sum==0 && cy==0)? "pass" : "fail" );
        #1;

        a = 0;
        b = 1;

        #0 $display("%5t: a=%b, b=%b, sum=%b, cy=%b %s", $time, a, b, sum, cy, (sum==1 && cy==0)? "pass" : "fail" );
        #1;

        a = 1;
        b = 0;

        #0 $display("%5t: a=%b, b=%b, sum=%b, cy=%b %s", $time, a, b, sum, cy, (sum==1 && cy==0)? "pass" : "fail" );
        #1;

        a = 1;
        b = 1;

        #0 $display("%5t: a=%b, b=%b, sum=%b, cy=%b %s", $time, a, b, sum, cy, (sum==0 && cy==1)? "pass" : "fail" );
        #1;

        a = 0;
        b = 0;
        #0 $display("%5t: a=%b, b=%b, sum=%b, cy=%b %s", $time, a, b, sum, cy, (sum==0 && cy==0)? "pass" : "fail" );
        #2;
        
        $finish;    // The $finish 'system task' halts the simulation
    end

endmodule
