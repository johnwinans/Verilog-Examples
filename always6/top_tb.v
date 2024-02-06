`timescale 1ns/1ns  // time units & precision are both 1nsec

module tb();

    reg         en;      // enable
    reg [3:0]   D;
    wire        a,b,c,d,e,f,g;

    integer     i;      // used by the for loop

    led uut ( 
            .enable(en), 
            .D(D), 
            .a(a),
            .b(b),
            .c(c),
            .d(d),
            .e(e),
            .f(f),
            .g(g)
            );

    initial begin
        // recall that unused values will just be printed in order
        $monitor("time:%2t e=%b D=%h segs=", $time, e, D, a,b,c,d,e,f,g );

        $dumpfile("top_tb.vcd");
        $dumpvars;

        en = 1;

        for (i=0; i<='hf; i=i+1) begin
            D = i;
            #1;     // force the sim to propagate all signals before the $display calls

/*
            // creatively print the LED segments
            $display( "%s",     a ? " *** " : "     " );             // a
            $display( "%s   %s", f ? "*" : " ", b ? "*" : " " );     // f, b
            $display( "%s   %s", f ? "*" : " ", b ? "*" : " " );     // f, b
            $display( "%s",     g ? " *** " : "    " );              // g
            $display( "%s   %s", e ? "*" : " ", c ? "*" : " " );     // e, c
            $display( "%s   %s", e ? "*" : " ", c ? "*" : " " );     // e, c
            $display( "%s",     d ? " *** " : "     " );             // d
*/
        end
        #1;

        D[2] = 'bx;     // generate an unknown input value
        #1;

        en = 0;
        #1;

        D[2] = 0;       // make sure stays dusabled even when D is not unknown
        #1;
        
        $finish;
    end

endmodule
