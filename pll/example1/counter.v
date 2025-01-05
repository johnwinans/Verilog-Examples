module counter (
    input wire clk,
    input wire reset,
    output wire [7:0] out
    );

    reg [31:0] counter = 32'b0;

    //assign out = ~counter[28:21];
    assign out = counter[27:20];
    //assign out = counter[30:23];

    always @ (posedge clk) 
    begin
        if (reset)
            counter <= 0;
        else
            counter <= counter + 1;
    end

endmodule
