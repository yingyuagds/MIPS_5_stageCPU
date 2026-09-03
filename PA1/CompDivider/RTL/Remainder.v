module Remainder (
    input clk, rst_n, preload, wr_ctrl, sll_ctrl,
    input [31:0] dividend,
    input [31:0] ALU_result,
    output reg [63:0] remainder_out
);
    always @(posedge clk) begin
        if (!rst_n)
            remainder_out <= 64'b0;
        else if (preload) remainder_out <= {32'b0, dividend};
        else if (sll_ctrl) remainder_out <= remainder_out << 1;
        else if (wr_ctrl)
        begin
            remainder_out[63:32] <= ALU_result;
            remainder_out[0] <= 1'b1;
        end
    end
endmodule
