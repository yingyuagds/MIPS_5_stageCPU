module Product(
    input clk,rst_n,preload,wr_ctrl,srl_ctrl,
    input [31:0] multiplier,
    input [31:0] ALU_result,
    input ALU_carry,
    output reg [63:0] product_out
);
    reg carry;//避免ALU_carry右移時被覆蓋
    always@(posedge clk)
    begin   
        if (!rst_n)
        begin
            product_out<=64'b0;
            carry<=1'b0;
        end
        else if (preload) 
        begin
            product_out<={32'b0,multiplier};
            carry<=1'b0;
        end
        else if (wr_ctrl)
        begin
            product_out[63:32]<=ALU_result;
            carry<=ALU_carry;
        end
        else if (srl_ctrl)
        begin
            product_out<={carry,product_out[63:1]};
            carry<=1'b0;
        end
    end
endmodule