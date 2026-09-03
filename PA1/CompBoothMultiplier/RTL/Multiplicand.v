module Multiplicand(
    input clk,rst_n,preload,
    input [31:0] multiplicand,
    output reg [31:0] multiplicand_out
);
    always@(posedge clk)
    begin
        if (!rst_n) multiplicand_out<=32'b0;
        else if (preload) multiplicand_out<=multiplicand;
    end
endmodule