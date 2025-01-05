`timescale 100ns/1ps

module tb();

    reg clk;        // pixel clock
    reg reset;

    vgasync
    #(
        // artifically small screen to make easy to see waveforms
        .HVID(5),
        .HFP(2),
        .HS(3),
        .HBP(4),
        .VVID(3),
        .VFP(1),
        .VS(2),
        .VBP(3)
    ) uut (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        $dumpfile("vgasync_tb.vcd");
        $dumpvars;
        clk = 0;
    end
    
    always #1 clk = ~clk;

    initial begin
        reset = 1;
        #4;
        reset = 0;
        #10000;
        $finish;
    end

endmodule
