`timescale 1ns/1ps  

module tb();

    reg         clk;
    reg [7:0]   a;
    reg [7:0]   b;

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars;
        //$monitor("%5d a:%2d b:%2d clk:%b", $time, a, b, clk);
        $monitor("%5d a:%2d b:%2d", $time, a, b);
        a = 18;
        b = 00;
        clk = 0;
        #100;
        $finish;
    end

    always #1 clk = ~clk;

    // swap the values of a and b
    always @(posedge clk) begin
        b <= a;
        a <= b;
    end

endmodule
