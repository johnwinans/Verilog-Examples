`timescale 1ns/1ps

module tb();

    reg         clk     = 0;        // the free running clock
    reg         reset   = 0;

    wire [3:0]  x;
    wire [3:0]  a;
    wire [3:0]  b;

    toggler toggler1 (
        .clk(clk),
        .x(x),
        .a(a),
        .b(b)
        );

    initial begin
        $dumpfile("toggler_tb.vcd");    // where to write the dump
        $dumpvars;                      // dump EVERYTHING

        #100;
        $finish;
    end
    
    always #1 clk <= ~clk;

endmodule
