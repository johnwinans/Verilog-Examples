`timescale 100ns/1ps

module tb();

    reg         reset;
    reg         ps2d;
    reg         ps2c;
    wire [8:0]  data;
    wire        ready;

    ps2 uut (
        .reset(reset),
        .ps2_data_in(ps2d),
        .ps2_clk_in(ps2c),
        .rx_data(data),
        .rx_ready(ready)
    );

    initial begin
        $dumpfile("ps2_tb.vcd");
        $dumpvars(0,tb);
        reset = 0;
        ps2d = 1;
        ps2c = 1;
    end
    
    integer i;

    initial begin
        #1
        reset = 1;
        ps2c = 0;       // simulate the feedback from the pin
        ps2d = 0;
        #4;
        reset = 0;
        ps2c = 1;       // simulate the feedback from the pin
        #5;

        // wait the reset operation to complete
        for ( i = 0; i < 11; i = i + 1 ) begin
            ps2c = 0;
            ps2d = 1;
            #1;
            ps2c = 1;
            #1;
        end
        // fake the ACK cycle
        ps2c = 0;
        ps2d = 0;
        #1;
        ps2c = 1;
        #1;
        ps2d = 1;



        #5;

        // start bit
        ps2d = 0;
        #1;
        ps2c = 0;
        #1;
        ps2c = 1;

        // data bits
        for ( i = 0; i < 8; i = i + 1 ) begin
            ps2d = i < 6 ? 1 : 0;               // just send some 1s followed by 0s
            #1;
            ps2c = 0;
            #1;
            ps2c = 1;
        end

        // odd parity bit
        ps2d = 1;
        #1;
        ps2c = 0;
        #1;
        ps2c = 1;

        // stop bit
        ps2d = 1;
        #1;
        ps2c = 0;
        #1;
        ps2c = 1;


        #5;

        // start bit
        ps2d = 0;
        #1;
        ps2c = 0;
        #1;
        ps2c = 1;

        // data bits
        for ( i = 0; i < 8; i = i + 1 ) begin
            ps2d = i&1;         // set every othuer bit
            #1;
            ps2c = 0;
            #1;
            ps2c = 1;
        end

        // odd parity bit
        ps2d = 1;
        #1;
        ps2c = 0;
        #1;
        ps2c = 1;

        // stop bit
        ps2d = 1;
        #1;
        ps2c = 0;
        #1;
        ps2c = 1;


        #10;
        $finish;
    end

endmodule
