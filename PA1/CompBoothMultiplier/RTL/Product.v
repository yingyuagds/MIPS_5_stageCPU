module Product(
    input clk,rst_n,preload,wr_ctrl,srl_ctrl,
    input [31:0] multiplier,
    input [31:0] ALU_result,
    output reg [64:0] product_out
);
    reg carry;
    always@(posedge clk)
    begin   
        if (!rst_n)
        begin
            product_out<=65'b0;
        end
        else if (preload) 
        begin
            product_out<={32'b0,multiplier,1'b0};
        end
        else if (wr_ctrl)
        begin
            product_out[64:33]<=ALU_result;
        end
        else if (srl_ctrl)
        begin
            product_out<={product_out[64],product_out[64:1]};
        end
    end
endmodule