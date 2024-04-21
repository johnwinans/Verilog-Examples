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
        $monitor("time:%2t en=%b D=%b segs=", $time, en, D, a,b,c,d,e,f,g );

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

        $display( "***************************************" );

        D[2] = 'bx;     // generate an unknown input value
        #1;
        en = 0;
        #1;
        D[2] = 0;       // make sure stays disabled even when D is known/valid
        #1;

        en = 1;
        D = 4'bz;       // make sure stays disabled even when D is z
        #1;
        en = 0;
        #1;

        en = 1;
        D = 4'bx;       // make sure stays disabled even when D is z
        #1;
        en = 0;
        #1;

        // what happens when SOME of the D bits are z?
        en = 1;
        D = 4'b10z0;       // make sure stays disabled even when D is z
        #1;

        // what happens when SOME of the D bits are x?
        en = 1;
        D = 4'b10x0;       // make sure stays disabled even when D is z
        #1;

        // what happens when SOME of the D bits are x and z?
        en = 1;
        D = 4'b1zx1;       // make sure stays disabled even when D is z
        #1;

        en = 1;
        D = 4'b1z01;       // make sure stays disabled even when D is z
        #1;

        $finish;
    end

endmodule
