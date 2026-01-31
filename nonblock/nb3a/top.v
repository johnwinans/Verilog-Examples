//**************************************************************************
//
//    Copyright (C) 2024  John Winans
//
//    This library is free software; you can redistribute it and/or
//    modify it under the terms of the GNU Lesser General Public
//    License as published by the Free Software Foundation; either
//    version 2.1 of the License, or (at your option) any later version.
//
//    This library is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//    Lesser General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public
//    License along with this library; if not, write to the Free Software
//    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
//    USA
//
//**************************************************************************


/**
* This is implemented to flash 9 output pins.
**************************************************************************/
module top (
    input wire clk,             // 12MHZ clock
`ifdef TB_UPDUINO
    output wire [9:0]   led     // upduino setup uses 10 LEDs
`else
    output wire [8:0]   led
`endif
    );

    reg         reset   = 0;
    wire        onehz;
    wire [3:0]  a;
    wire [3:0]  b;

`ifdef TB_UPDUINO
    assign led = ~{a,~onehz,onehz,b};
`else
    assign led = ~{a,~onehz,b};
`endif

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

endmodule
