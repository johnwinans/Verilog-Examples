`timescale 100ns/1ps

module tb();

    reg clk;        // pixel clock
    reg reset;

    vgasync
    #(
        // artifically small screen to make easy to see waveforms
        .HVID(5),
        .HRB(2),
        .HFP(2),
        .HS(3),
        .HBP(4),
        .HLB(2),
        .VVID(3),
        .VBB(2),
        .VFP(4),
        .VS(2),
        .VBP(3),
        .VTB(2)
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
        #100000;
        $finish;
    end

endmodule
