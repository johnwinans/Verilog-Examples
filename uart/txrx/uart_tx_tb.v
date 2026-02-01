/*
*    Copyright (C) 2024,2025  John Winans
*
*    This library is free software; you can redistribute it and/or
*    modify it under the terms of the GNU Lesser General Public
*    License as published by the Free Software Foundation; either
*    version 2.1 of the License, or (at your option) any later version.
*
*    This library is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
*    Lesser General Public License for more details.
*
*    You should have received a copy of the GNU Lesser General Public
*    License along with this library; if not, write to the Free Software
*    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
*    USA
*/

`timescale 1ns/1ns

`default_nettype none

module tb ();

    localparam clk_hz       = 12000000;
    localparam clk_period   = (1.0/clk_hz)*1000000000;    // period in nsec
    localparam brg_divisor  = clk_hz/9600;
    
    reg         clk             = 0;
    reg         reset           = 1;
    reg         brg16_tick_reg  = 0;
    reg [$clog2(brg_divisor-1):0]  tx_clk_reg      = 0;
    reg [7:0]   d_reg           = 0;

    reg         d_tick          = 0;            // tick to send a byte
    wire        tx_done_tick;                   // tick by UART when a byte completes
    wire        tx_empty;                       // level from UART when TX is ready
    wire        tx;                             // UART serial data output

    always #(clk_period/2) clk = ~clk;

    // divide the system clock for a BRG close enough to 9600 X 16
    always @( posedge clk ) begin
        if ( tx_clk_reg == brg_divisor-1 ) begin
            tx_clk_reg <= 0;
            brg16_tick_reg <= 1;
        end else begin
            tx_clk_reg <= tx_clk_reg+1;
            brg16_tick_reg <= 0;
        end
    end

    uart_tx uut (
        .clk(clk),
        .reset(reset),
        .brg16_tick(brg16_tick_reg),
        .d_tick(d_tick),
        .tx_done_tick(tx_done_tick),
        .tx_empty(tx_empty),
        .tx(tx),
        .d(d_reg)
    );

    integer i;

    initial begin
        $dumpfile( { `__FILE__, "cd" } );
        $dumpvars;

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        reset <= 0;

        @(posedge tx_empty);        // note that reset will force tx_empty low for a while

        d_reg <= 0;         // send a null
        d_tick <= 1;
        @(posedge clk);
        d_tick <= 0;

        @(posedge tx_empty);
//        @(posedge tx_done_tick);

        d_reg <= 'h81;       // msb & lsb = 1
        d_tick <= 1;
        @(posedge clk);
        d_tick <= 0;
        
        @(posedge tx_done_tick);

        //wait ( tx_clk_reg == 0 );
        //@( posedge brg16_tick_reg );

        d_reg <= 'hf0;
        d_tick <= 1;
        @(posedge clk);
        d_tick <= 0;


        // special case hack to assert d_tick with brg_tick during a stop bit
`ifdef FORCE_ERROR
        wait ( uut.ctr_next == 8 );
        wait ( uut.ctr_next == 9 );
`else
        @(posedge tx_done_tick);
`endif
        d_reg <= 'h55;
        d_tick <= 1;
        @(posedge clk);
        d_tick <= 0;


        @(posedge tx_done_tick);

        // idle the line for a while 
        @(posedge brg16_tick_reg);
        @(posedge brg16_tick_reg);

        // get away from any brg_tick edges..
        wait( tx_clk_reg == brg_divisor/2 );

        d_reg <= 'haa;
        d_tick <= 1;
        @(posedge clk);
        d_tick <= 0;

        @(posedge tx_done_tick);

        // idle the line for longer than a bit period
        for ( i = 0; i<40; i = i + 1) @(posedge brg16_tick_reg);

        d_reg <= 'hbb;
        d_tick <= 1;
        @(posedge clk);
        d_tick <= 0;

        @(posedge tx_done_tick);


        for ( i = 0; i<16*9; i = i + 1) @(posedge brg16_tick_reg);

        $finish;
    end

    initial begin
        // This is useful while debugging an endless simulation.
        #200000000;         // Force stop at 200msec no matter what.
        $finish;
    end

endmodule
