`timescale 1ns/1ps  

module tb();

    reg         clk;

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars;

        clk = 0;

        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;

        #2;             // wait a while
        $finish;        // stop the simulation 
    end

    always @(*)
        $display("%5t: @(*) clk is %b", $time, clk);

    always @(posedge clk)
        $display("%5t: @(pos) clk is %b", $time, clk);

    always @(negedge clk)
        $display("%5t: @(neg) clk is %b", $time, clk);

endmodule
