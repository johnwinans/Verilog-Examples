`timescale 100ns/1ps

module tb();

    // Start clk with 1 or 0?  If assert reset, it is less important.
    // Else the initial clk value will impact the first counter tick time.
    reg         clk     = 0;        // the free running clock

    reg         reset   = 0;
    wire        onehz;
    wire [3:0]  a;
    wire [3:0]  b;

    timer timer1 (
        .reset(reset),
        .clk(clk),
        .Q(onehz)
    );

    toggler toggler1 (
        .clk(onehz),
        .a(a),
        .b(b)
        );

    initial begin
        $dumpfile("top_tb.vcd");    // where to write the dump
        $dumpvars;                  // dump EVERYTHING

/*
        reset = 1;
        // let at least one clk rising edge pass for the reset to finish
        //#5;                         // this can cause a race with clk
        #4;                         // this will not cause a race (easiest fix)
        reset = 0;                  // *could* resolve race with <= here ?
*/

        #1000;
        $finish;
    end

    always #1 clk <= ~clk;          // should we use = or <= here?
                                    // I use <= to know it can't change mid sim-cycle

endmodule
