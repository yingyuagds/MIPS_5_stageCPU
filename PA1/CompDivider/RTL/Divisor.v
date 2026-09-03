module Divisor(
    input clk,rst_n,preload,
    input [31:0] divisor,
    output reg [31:0] divisor_out
);
    always@(posedge clk)
    begin
        if (!rst_n) divisor_out<=32'b0;
        else if (preload) divisor_out<=divisor;
    end
endmodule
