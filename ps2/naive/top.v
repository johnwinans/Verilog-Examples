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

`default_nettype none

module top (
    input   wire        clk25,
    input   wire        s1_n,
    input   wire        s2_n,
    input   wire        kbclk,
    input   wire        kbdata,
    output  wire [7:0]  led
    );

    wire [7:0] data;

    ps2 kbd (
        .reset(~s1_n),
        .ps2_data(kbdata),
        .ps2_clk(kbclk),
        .rx_data(data)       // note the MSB is pruned
        );

    assign led = ~data;

endmodule
