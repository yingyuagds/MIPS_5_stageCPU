module Interface (
    input clk, rst_n, start, preload,
    input [31:0] dividend, divisor,
    input [63:0] remainder_in,
    input [31:0] quotient_in,
    input valid_in,
    output reg start_out, preload_out,
    output reg [31:0] dividend_out, divisor_out,remainder,quotient,
    output reg valid
);
    always @(posedge clk) begin
        if (!rst_n) begin
            start_out    <= 1'b0;
            preload_out  <= 1'b0;
            dividend_out <= 32'b0;
            divisor_out  <= 32'b0;
            remainder    <= 32'b0;
            quotient     <= 32'b0;
            valid        <= 1'b0;
        end
        else begin
            start_out    <= start;
            preload_out  <= preload;
            dividend_out <= dividend;
            divisor_out  <= divisor;
            remainder    <= remainder_in[63:32];
            quotient     <= quotient_in;
            valid        <= valid_in;
        end
    end
endmodule
