// As seen on the Internet 2024-10-12
// https://electronics.stackexchange.com/questions/505911/debounce-circuit-design-in-verilog
// mods by John Winans

`timescale 1ns/1ps

module tb;

    reg clock;
    reg button;
    wire button_sync;
    wire button_sync_db;
    wire edj;
    wire rise;
    wire fall;

    sync 
    #(
        .SYNC_LEN(3)
    )
    Sync_Inst
    (
        .clk(clock),
        .in(button),
        .out(button_sync)
    );

    debounce
    #(
        .MAX_COUNT(25000)
    )
    Debounce_Inst
    (
        .clock(clock),
        .in(button_sync),
        .out(button_sync_db),
        .edj(edj),
        .rise(rise),
        .fall(fall)
    );

    initial
    begin
        $dumpfile("debounce_tb.vcd");
        $dumpvars(0,tb);            // dump all vars in entire module tree
        clock = 0;
    end

    always #5 clock = ~clock;

    always
    begin
        #2 button = 0; #20 button = 1; #20 button = 0;
        #22 button = 1; #20 button = 1; #20 button = 0; #20 button = 1;
        #22 button = 1; #20 button = 0; #20 button = 0; #20 button = 1;
        #22 button = 0; #20 button = 1; #20 button = 1; #20 button = 0;
        #80 $finish;
    end

endmodule

