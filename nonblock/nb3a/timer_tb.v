`timescale 1ns/1ns

module tb();

    reg     clk     = 0;                // the free running clock
    reg     reset   = 1;
    wire    onehz;

    timer timer1 (
        .reset(reset),
        .clk(clk),
        .Q(onehz)
    );

    initial begin
        $dumpfile("timer_tb.vcd");      // where to write the dump
        $dumpvars;                      // dump EVERYTHING
        #2;
        reset = 0;
    end
    
    always #1 clk <= ~clk;              // each invocation = 1/2 clock cycle

    initial begin
        //#27000000;
        #205;
        $finish;
    end

endmodule
