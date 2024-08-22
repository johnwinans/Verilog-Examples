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

/**
* See iCE40 Technology Library Technical Note FPGA-TN-02026-3.2
* https://www.latticesemi.com/Products/FPGAandCPLD/iCE40
**************************************************************************/
module top (
    input  wire     s1_n,
    input  wire     s2_n,
    output wire     led1,
    output wire     led2,
    inout  wire     d_out
    );

    wire driver_enable;
    wire pin_value;

`define infer_tristate
`ifdef infer_tristate
    assign d_out = driver_enable ? 1'b0 : 1'bz; // tri-state when s1 is released
    assign pin_value = d_out;
`else

    SB_IO #(
        .PIN_TYPE(6'b1010_01),
        .PULLUP(1'b1)                   // enable the pullup
    ) tri_state (
        .PACKAGE_PIN(d_out),
        .OUTPUT_ENABLE(driver_enable),  // when driver_enable is high, turn on the output driver
        .D_OUT_0(0),                    // when driver is on, force the output to go low
        .D_IN_0(pin_value)              // a peek at the physical pin's current value
    );
`endif

    assign driver_enable = ~s1_n;       // turn on driver when s1 is low

    assign led1 = driver_enable;        // LED will light when driver is enabled
    assign led2 = ~pin_value;           // LED will light when the pin is high

endmodule
