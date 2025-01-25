module counter #(
    parameter WIDTH = 8
    ) (
    input wire clk,
    input wire reset,
    output wire [WIDTH-1:0] out
    );

    reg [WIDTH-1:0] counter = 0;

    always @ (posedge clk) 
    begin
        if (reset)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    assign out = counter;

endmodule
