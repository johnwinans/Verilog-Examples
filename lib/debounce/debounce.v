// Seen on the Internet 2024-10-12
// https://electronics.stackexchange.com/questions/505911/debounce-circuit-design-in-verilog

module debounce
#(
    parameter MAX_COUNT = 16
)
(
    input wire clock,
    input wire in,    // Synchronous and noisy input.
    output reg out,   // Debounced and filtered output.
    output reg edj,   // Goes high for 1 clock cycle on either edge of output. Note: used "edj" because "edge" is a keyword.
    output reg rise,  // Goes high for 1 clock cycle on the rising edge of output.
    output reg fall   // Goes high for 1 clock cycle on the falling edge of output.
);

    localparam COUNTER_BITS = $clog2(MAX_COUNT);

    reg [COUNTER_BITS - 1 : 0] counter;
    wire w_edj;
    wire w_rise;
    wire w_fall;

    initial
    begin
        counter = 0;
        out = 0;
    end

    always @(posedge clock)
    begin
        counter <= 0;  // Freeze counter by default to reduce switching losses when input and output are equal.
        edj <= 0;
        rise <= 0;
        fall <= 0;
        if (counter == MAX_COUNT - 1)  // If successfully debounced, notify what happened.
        begin
            out <= in;
            edj <= w_edj;    // Goes high for 1 clock cycle on either edge.
            rise <= w_rise;  // Goes high for 1 clock cycle on the rising edge.
            fall <= w_fall;  // Goes high for 1 clock cycle on the falling edge.
        end
        else if (in != out)  // Hysteresis.
        begin
            counter <= counter + 1;  // Only increment when input and output differ.
        end
    end

    // Edge detect.
    assign w_edj = in ^ out;
    assign w_rise = in & ~out;
    assign w_fall = ~in & out;

endmodule
