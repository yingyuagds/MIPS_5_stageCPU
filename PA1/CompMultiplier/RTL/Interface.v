module Interface(
    input clk,rst_n,start,preload,
    input [31:0] multiplier,multiplicand,
    input [63:0] product_in,
    input valid_in,
    output reg start_out,preload_out,
    output reg [31:0] multiplier_out,multiplicand_out,
    output reg [63:0] product,
    output reg valid
);
    always@(posedge clk)
    begin
        if (!rst_n) 
        begin
            start_out<=1'b0;
            preload_out<=1'b0;
            multiplier_out<=32'b0;
            multiplicand_out<=32'b0;
            product<=64'b0;
            valid<=1'b0;
        end
        else
        begin
            preload_out<=preload;
            start_out<=start;
            multiplier_out<=multiplier;
            multiplicand_out<=multiplicand;
            product<=product_in;
            valid<=valid_in;
        end
    end
endmodule
